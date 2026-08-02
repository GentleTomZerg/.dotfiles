#!/bin/bash
MIHOMO_SERVICE_URL="http://127.0.0.1:7890"
MIHOMO_CONFIG_PATH="$HOME/.config/mihomo"
MIHOMO_DNS_VIRTUAL_IP="198.18.0.2"
MIHOMO_CONTROLLER_URL="http://127.0.0.1:9090" # matches external-controller in mihomo.yaml
NETWORK_SERVICE="Wi-Fi" # Consider making this dynamic in the future

# Provider/template/runtime paths are derived from MIHOMO_CONFIG_PATH inside each
# function so an override of that variable takes effect everywhere (and is testable).

function is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

# Render the runtime config: deep-merge the template with providers.yaml (providers win).
# Template stays a shareable skeleton; real subscription URLs/specs live in providers.yaml.
function render_config() {
    local providers="$MIHOMO_CONFIG_PATH/providers.yaml"
    local template="$MIHOMO_CONFIG_PATH/mihomo.yaml"
    local runtime="$MIHOMO_CONFIG_PATH/mihomo_runtime.yaml"

    if [[ ! -f "$providers" ]]; then
        echo "Error: Providers file not found at $providers" >&2
        return 1
    fi

    if ! yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
        "$template" "$providers" > "$runtime"; then
        echo "Error: Failed to render runtime config." >&2
        rm -f "$runtime" # Clean up partial output.
        return 1
    fi

    echo "Runtime config written to $runtime"
}

function setproxy() {
    export {http,https,ftp,all}_proxy="$MIHOMO_SERVICE_URL"
    export {HTTP,HTTPS,FTP,ALL}_PROXY="$MIHOMO_SERVICE_URL"
}

function unsetproxy() {
    unset {http,https,ftp,all}_proxy
    unset {HTTP,HTTPS,FTP,ALL}_PROXY
}

# Smoke-test the running mihomo: API controller up, a blocked site reachable through
# the mixed port, the dashboard served, and (macOS) system DNS pointed at mihomo's
# virtual IP. Retries briefly so mihomo can settle and providers/health-checks warm up.
# startproxy runs this after launching; the runbook's proxy-phase CHECKs call it directly.
function smoke_test() {
    local failures=0 tries=10 delay=2

    # 1. Process + API controller (readiness).
    if ! pgrep -x mihomo > /dev/null; then
        echo "smoke: FAIL - mihomo is not running"
        return 1
    fi
    if ! wait_for_controller "$tries" "$delay"; then
        echo "smoke: FAIL - API controller not responding on $MIHOMO_CONTROLLER_URL"
        return 1
    fi
    echo "smoke: ok - mihomo running, API controller up"

    # 2. A blocked site must be reachable through the mixed port.
    if ! smoke_retry "$tries" "$delay" \
        "curl -fsS -x $MIHOMO_SERVICE_URL https://www.youtube.com > /dev/null 2>&1"; then
        echo "smoke: FAIL - blocked site not reachable through $MIHOMO_SERVICE_URL"
        failures=$((failures + 1))
    else
        echo "smoke: ok - proxy forwards to the open internet"
    fi

    # 3. Dashboard (external-ui, auto-downloaded via external-ui-url on first run).
    if ! curl -fsS -o /dev/null "$MIHOMO_CONTROLLER_URL/ui/" 2>/dev/null; then
        echo "smoke: FAIL - dashboard not served at $MIHOMO_CONTROLLER_URL/ui/"
        failures=$((failures + 1))
    else
        echo "smoke: ok - dashboard served"
    fi

    # 4. macOS only: system DNS pointed at mihomo's virtual IP.
    if is_macos; then
        if scutil --dns 2>/dev/null | grep -q "$MIHOMO_DNS_VIRTUAL_IP"; then
            echo "smoke: ok - system DNS routed to mihomo"
        else
            echo "smoke: FAIL - system DNS not pointed at $MIHOMO_DNS_VIRTUAL_IP"
            failures=$((failures + 1))
        fi
    fi

    if (( failures > 0 )); then
        echo "smoke: $failures check(s) failed"
        return 1
    fi
    echo "smoke: all checks passed"
    return 0
}

# Retry a command string until it succeeds or the budget is exhausted.
function smoke_retry() {
    local tries="$1" delay="$2" cmd="$3" i
    for (( i = 1; i <= tries; i++ )); do
        if eval "$cmd"; then
            return 0
        fi
        sleep "$delay"
    done
    return 1
}

# Wait for the external controller to answer (first readiness signal after launch).
function wait_for_controller() {
    local tries="$1" delay="$2" i
    for (( i = 1; i <= tries; i++ )); do
        if curl -fsS -o /dev/null "$MIHOMO_CONTROLLER_URL/version" 2>/dev/null; then
            return 0
        fi
        sleep "$delay"
    done
    return 1
}

function startproxy() {
    # 1. Guard against duplicate mihomo instances.
    if pgrep -x mihomo > /dev/null; then
        echo "mihomo has already started."
        return 1
    fi

    # 2. Render the runtime config from the template + providers.
    if ! render_config; then
        return 1
    fi
    local runtime="$MIHOMO_CONFIG_PATH/mihomo_runtime.yaml"

    # 3. Require sudo; on macOS, point DNS to mihomo virtual ip.
    if ! sudo -v; then
        echo "sudo authentication failed."
        return 1
    fi
    
    if is_macos; then
        sudo networksetup -setdnsservers "$NETWORK_SERVICE" "$MIHOMO_DNS_VIRTUAL_IP"
    fi
    # -d sets Home Dir to the config dir: relative provider `path:` (./proxy_providers/...),
    # cache.db and external-ui all live under MIHOMO_CONFIG_PATH. Since the config dir
    # matches mihomo's default home dir, -d is technically redundant — kept for explicitness.
    sudo -b mihomo -d "$MIHOMO_CONFIG_PATH" -f "$runtime" > /dev/null 2>&1 &

    echo "mihomo started with config: $runtime"
    if smoke_test; then
        echo "startproxy: mihomo up, smoke test passed"
        return 0
    fi
    echo "startproxy: mihomo started but the smoke test FAILED (see smoke: lines above)" >&2
    return 1
}

function stopproxy() {
  if [[ -z $(pgrep -x mihomo) ]]; then
    echo "mihomo is not running"
    return 1
  fi

  # kill mihomo process. On macOs, reset system dns config to default
  sudo kill "$(sudo pgrep -x mihomo)"
  if is_macos; then
        sudo networksetup -setdnsservers "$NETWORK_SERVICE" Empty
  fi
}
