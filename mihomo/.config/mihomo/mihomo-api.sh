#!/bin/bash
MIHOMO_SERVICE_URL="http://127.0.0.1:7890"
MIHOMO_CONFIG_PATH="${MIHOMO_CONFIG_PATH:-$HOME/.config/mihomo}"
MIHOMO_DNS_VIRTUAL_IP="198.18.0.2"
MIHOMO_CONTROLLER_URL="http://127.0.0.1:9090" # matches external-controller in mihomo.yaml
NETWORK_SERVICE="Wi-Fi"                       # Consider making this dynamic in the future

# Derived config paths, all rooted at MIHOMO_CONFIG_PATH and fixed at load time.
# To relocate the config tree, set MIHOMO_CONFIG_PATH (or any of these) before
# sourcing this file. render_config and startproxy all read these globals.
MIHOMO_TEMPLATE_PATH="$MIHOMO_CONFIG_PATH/mihomo.yaml"
MIHOMO_PROVIDERS_PATH="$MIHOMO_CONFIG_PATH/providers.yaml"
MIHOMO_RUNTIME_PATH="$MIHOMO_CONFIG_PATH/mihomo_runtime.yaml"

# Single retry budget for every poll in the script (readiness, blocked site,
# and connection checks). Change here to tune how long mihomo is allowed to settle.
MIHOMO_RETRY_TRIES=10
MIHOMO_RETRY_DELAY=1

function is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

# Render the runtime config: deep-merge the template with providers.yaml (providers win).
# Template stays a shareable skeleton; real subscription URLs/specs live in providers.yaml.
function render_config() {
    if [[ ! -f "$MIHOMO_PROVIDERS_PATH" ]]; then
        echo "Error: Providers file not found at $MIHOMO_PROVIDERS_PATH" >&2
        return 1
    fi

    if ! yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
        "$MIHOMO_TEMPLATE_PATH" "$MIHOMO_PROVIDERS_PATH" >"$MIHOMO_RUNTIME_PATH"; then
        echo "Error: Failed to render runtime config." >&2
        rm -f "$MIHOMO_RUNTIME_PATH" # Clean up partial output.
        return 1
    fi

    echo "Runtime config written to $MIHOMO_RUNTIME_PATH"
}

function setproxy() {
    export {http,https,ftp,all}_proxy="$MIHOMO_SERVICE_URL"
    export {HTTP,HTTPS,FTP,ALL}_PROXY="$MIHOMO_SERVICE_URL"
}

function unsetproxy() {
    unset {http,https,ftp,all}_proxy
    unset {HTTP,HTTPS,FTP,ALL}_PROXY
}

# Verify the running mihomo on demand: API controller up, a blocked site reachable
# through the mixed port, the dashboard served, and (macOS) system DNS pointed at
# mihomo's virtual IP. Retries briefly so mihomo can settle and providers/health-
# checks warm up. The runbook's proxy-phase CHECKs call this directly.
function statusproxy() {
    local failures=0 tries="$MIHOMO_RETRY_TRIES" delay="$MIHOMO_RETRY_DELAY"

    # 1. Process + API controller (readiness).
    if ! wait_for "$tries" "$delay" pgrep -xq mihomo; then
        echo "status: FAIL - mihomo is not running"
        return 1
    fi
    if ! wait_for "$tries" "$delay" \
        curl -fs -o /dev/null "$MIHOMO_CONTROLLER_URL/version"; then
        echo "status: FAIL - API controller not responding on $MIHOMO_CONTROLLER_URL"
        return 1
    fi
    echo "status: ok - mihomo running, API controller up"

    # 2. A blocked site must be reachable through the mixed port.
    if ! wait_for "$tries" "$delay" \
        curl -fs -o /dev/null -x "$MIHOMO_SERVICE_URL" https://www.youtube.com; then
        echo "status: FAIL - blocked site not reachable through $MIHOMO_SERVICE_URL"
        failures=$((failures + 1))
    else
        echo "status: ok - proxy forwards to the open internet"
    fi

    # 3.  (external-ui, auto-downloaded via external-ui-url on first run).
    if ! curl -fsS -o /dev/null "$MIHOMO_CONTROLLER_URL/ui/" 2>/dev/null; then
        echo "status: FAIL - dashboard not served at $MIHOMO_CONTROLLER_URL/ui/"
        failures=$((failures + 1))
    else
        echo "status: ok - dashboard served"
    fi

    # 4. macOS only: system DNS pointed at mihomo's virtual IP.
    if is_macos; then
        if scutil --dns 2>/dev/null | grep -q "$MIHOMO_DNS_VIRTUAL_IP"; then
            echo "status: ok - system DNS routed to mihomo"
        else
            echo "status: FAIL - system DNS not pointed at $MIHOMO_DNS_VIRTUAL_IP"
            failures=$((failures + 1))
        fi
    fi

    if ((failures > 0)); then
        echo "status: $failures check(s) failed"
        return 1
    fi
    echo "status: all checks passed"
    return 0
}

# Run a probe until it succeeds or the budget is exhausted. The probe is a command
# (no eval): pass it as the remaining arguments, e.g. `wait_for 10 2 pgrep -x mihomo`.
# One retry loop serves every wait in the script — process, controller, blocked site.
function wait_for() {
    local tries="$1" delay="$2" i
    shift 2
    for ((i = 1; i <= tries; i++)); do
        if "$@" 2>/dev/null; then
            return 0
        fi
        sleep "$delay"
    done
    return 1
}

function startproxy() {
    # 1. Guard against duplicate mihomo instances.
    if pgrep -x mihomo >/dev/null; then
        echo "mihomo has already started."
        return 1
    fi

    # 2. Render the runtime config from the template + providers into the shared
    # MIHOMO_RUNTIME_PATH (derived at load) that the launch step uses.
    if ! render_config; then
        return 1
    fi

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
    sudo -b mihomo -d "$MIHOMO_CONFIG_PATH" -f "$MIHOMO_RUNTIME_PATH" >/dev/null 2>&1 &

    echo "mihomo started with config: $MIHOMO_RUNTIME_PATH"

    # Run the full statusproxy checks (readiness, blocked site, dashboard, DNS) so
    # startproxy only returns 0 when mihomo is fully working. statusproxy's first
    # step waits for the process + controller, so no separate boot gate is needed.
    if ! statusproxy; then
        echo "startproxy: FAILED - verify the statusproxy lines above" >&2
        return 1
    fi

    echo "startproxy: mihomo fully working (all statusproxy checks passed)"
    return 0
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
