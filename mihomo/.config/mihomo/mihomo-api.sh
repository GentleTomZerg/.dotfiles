#!/bin/bash
# NOTE: despite the shebang, this file is *sourced* (from ~/.zshrc), so every function
# here must run in both bash and zsh. Two traps that have already bitten:
#   - `path` is a special zsh parameter tied to $PATH: never `read -r path`
#   - zsh arrays are 1-indexed, bash's are 0-indexed: prefer plain scalars
MIHOMO_PROXY_URL="http://127.0.0.1:7890"
MIHOMO_HOME="${MIHOMO_HOME:-$HOME/.config/mihomo}"
MIHOMO_DNS_VIRTUAL_IP="198.18.0.2"
MIHOMO_CONTROLLER_URL="http://127.0.0.1:9090" # matches external-controller in templates/base.yaml
MIHOMO_NETWORK_SERVICE="Wi-Fi"                       # Consider making this dynamic in the future

# All rooted at MIHOMO_HOME and fixed at load time; export it before sourcing to
# relocate the tree. templates/ committed, user/ yours, generated/ derived —
# see README.md for what lives where.
MIHOMO_BASE_PATH="$MIHOMO_HOME/templates/base.yaml"
MIHOMO_PROVIDERS_PATH="$MIHOMO_HOME/user/providers.yaml"
MIHOMO_PROVIDERS_SEED="$MIHOMO_HOME/templates/providers.example.yaml"
MIHOMO_LIFT_RULE="$MIHOMO_HOME/user/provider-lift.yq"
MIHOMO_LIFT_SEED="$MIHOMO_HOME/templates/provider-lift.example.yq"
MIHOMO_OVERLAY_PATH="$MIHOMO_HOME/generated/provider-overlay.yaml"
MIHOMO_RUNTIME_PATH="$MIHOMO_HOME/generated/mihomo-runtime.yaml"

function _is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

# ---------------------------------------------------------------------------
# Provider lift: apply MIHOMO_LIFT_RULE (user/provider-lift.yq) to a provider
# cache and write what it returns to MIHOMO_OVERLAY_PATH, which _build_runtime
# merges last. The rule names what may be lifted; this function only finds the
# cache, applies the rule and reports the keys.
# ---------------------------------------------------------------------------
function _build_overlay() {
    # NOT `path`: in zsh `path` is tied to $PATH, so assigning it would break
    # every later `yq` in this function.
    local f keys

    if [[ ! -f "$MIHOMO_LIFT_RULE" ]]; then
        echo "Error: lift rule not found at $MIHOMO_LIFT_RULE" >&2
        echo "       cp $MIHOMO_LIFT_SEED $MIHOMO_LIFT_RULE" >&2
        return 1
    fi

    # Paths come from user/providers.yaml, not a glob: a cache left by a removed
    # subscription cannot leak in. The first existing cache wins.
    f=$(yq -r '.proxy-providers[].path // ""' "$MIHOMO_PROVIDERS_PATH" 2>/dev/null |
        while IFS= read -r p; do
            [[ -n "$p" ]] || continue
            [[ "$p" == /* ]] || p="$MIHOMO_HOME/${p#./}"
            [[ -f "$p" ]] && { printf '%s\n' "$p"; break; }
        done)

    # No cache yet: nothing to lift. `{}` merges as a no-op, so base's dns: answers.
    if [[ -z "$f" ]]; then
        printf '{}\n' >"$MIHOMO_OVERLAY_PATH"
        echo "lift: nothing - no provider cache yet. Restart (stopproxy; startproxy)"
        echo "      once the subscription has been fetched, to lift the airport's own."
        return 0
    fi

    # The rule is hand-edited, so a yq failure is a real error, not a silent no-op.
    if ! yq --from-file "$MIHOMO_LIFT_RULE" "$f" >"$MIHOMO_OVERLAY_PATH" 2>/dev/null; then
        echo "Error: lift rule $MIHOMO_LIFT_RULE failed on $f" >&2
        echo "       run: yq --from-file $MIHOMO_LIFT_RULE $f" >&2
        return 1
    fi

    # Report the overridden keys only; the values are in MIHOMO_OVERLAY_PATH.
    keys=$(yq -r '[.dns // {} | to_entries[] | "dns." + .key] + (if has("hosts") then ["hosts"] else [] end) | join(", ")' "$MIHOMO_OVERLAY_PATH")
    if [[ -n "$keys" ]]; then
        echo "lift: $keys -> $MIHOMO_OVERLAY_PATH"
    else
        echo "lift: nothing - $f had nothing to lift."
    fi
}

# Merge templates/base.yaml, user/providers.yaml, then generated/provider-overlay.yaml
# (later wins; lists replace, not append). Rejected unless `mihomo -t` accepts it.
function _build_runtime() {
    if [[ ! -f "$MIHOMO_PROVIDERS_PATH" ]]; then
        echo "Error: providers file not found at $MIHOMO_PROVIDERS_PATH" >&2
        echo "       cp $MIHOMO_PROVIDERS_SEED $MIHOMO_PROVIDERS_PATH" >&2
        echo "       then fill in the subscription URL." >&2
        return 1
    fi

    mkdir -p "$MIHOMO_HOME/generated"
    _build_overlay || return 1

    if ! yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1) * select(fileIndex == 2)' \
        "$MIHOMO_BASE_PATH" "$MIHOMO_PROVIDERS_PATH" "$MIHOMO_OVERLAY_PATH" >"$MIHOMO_RUNTIME_PATH"; then
        echo "Error: failed to build runtime config." >&2
        rm -f "$MIHOMO_RUNTIME_PATH" # Clean up partial output.
        return 1
    fi

    # `mihomo -t` parses the whole config, so a malformed lifted dns: is caught
    # here. It does not check resolvers: an unresolvable nameserver passes.
    local test_output
    if ! test_output=$(mihomo -t -d "$MIHOMO_HOME" -f "$MIHOMO_RUNTIME_PATH" 2>&1); then
        echo "Error: runtime config failed 'mihomo -t'; not starting." >&2
        printf '%s\n' "$test_output" >&2
        rm -f "$MIHOMO_RUNTIME_PATH"
        return 1
    fi

    echo "Runtime config written to $MIHOMO_RUNTIME_PATH"
}

function setproxy() {
    export {http,https,ftp,all}_proxy="$MIHOMO_PROXY_URL"
    export {HTTP,HTTPS,FTP,ALL}_PROXY="$MIHOMO_PROXY_URL"
}

function unsetproxy() {
    unset {http,https,ftp,all}_proxy
    unset {HTTP,HTTPS,FTP,ALL}_PROXY
}

# Verify the running mihomo: controller up, a blocked site reachable through the
# mixed port, the dashboard served, and (macOS) system DNS pointed at the virtual
# IP. The probes retry inside curl, so mihomo may still be settling here.
function statusproxy() {
    local failures=0

    # 1. Controller (readiness). curl waits out a port that is not open yet: 10
    # retries, one second apart, on a refused connection. pgrep only names the
    # failure once curl gives up - asked first, it races startproxy's launch.
    if ! curl -fs --retry 10 --retry-delay 1 --retry-connrefused \
        -o /dev/null "$MIHOMO_CONTROLLER_URL/version" 2>/dev/null; then
        if pgrep -x mihomo >/dev/null; then
            echo "status: FAIL - API controller not responding on $MIHOMO_CONTROLLER_URL"
        else
            echo "status: FAIL - mihomo is not running"
        fi
        return 1
    fi
    echo "status: ok - mihomo running, API controller up"

    # 2. A blocked site must be reachable through the mixed port. --retry-all-errors
    # also covers a :7890 that accepts and then fails the request.
    if ! curl -fs --retry 10 --retry-delay 1 --retry-all-errors \
        -o /dev/null -x "$MIHOMO_PROXY_URL" https://www.youtube.com 2>/dev/null; then
        echo "status: FAIL - blocked site not reachable through $MIHOMO_PROXY_URL"
        failures=$((failures + 1))
    else
        echo "status: ok - proxy forwards to the open internet"
    fi

    # 3. Dashboard (external-ui, downloaded on first start via external-ui-url).
    if ! curl -fsS -o /dev/null "$MIHOMO_CONTROLLER_URL/ui/" 2>/dev/null; then
        echo "status: FAIL - dashboard not served at $MIHOMO_CONTROLLER_URL/ui/"
        failures=$((failures + 1))
    else
        echo "status: ok - dashboard served"
    fi

    # 4. macOS only: system DNS pointed at mihomo's virtual IP.
    if _is_macos; then
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

function startproxy() {
    if pgrep -x mihomo >/dev/null; then
        echo "mihomo has already started."
        return 1
    fi

    # 2. Build the runtime config the launch step below reads.
    if ! _build_runtime; then
        return 1
    fi

    # 3. Require sudo; on macOS, point DNS at mihomo.
    if ! sudo -v; then
        echo "sudo authentication failed."
        return 1
    fi

    if _is_macos; then
        sudo networksetup -setdnsservers "$MIHOMO_NETWORK_SERVICE" "$MIHOMO_DNS_VIRTUAL_IP"
    fi
    # -d sets Home Dir to MIHOMO_HOME: relative provider `path:`, cache.db and
    # external-ui all live under it.
    sudo -b mihomo -d "$MIHOMO_HOME" -f "$MIHOMO_RUNTIME_PATH" >/dev/null 2>&1 &

    echo "mihomo started with config: $MIHOMO_RUNTIME_PATH"

    # Full checks, so startproxy returns 0 only when mihomo is fully working;
    # statusproxy's first step already gates on the process and controller.
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

    sudo kill "$(sudo pgrep -x mihomo)"
    if _is_macos; then
        sudo networksetup -setdnsservers "$MIHOMO_NETWORK_SERVICE" Empty
    fi
}
