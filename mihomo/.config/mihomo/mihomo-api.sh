#!/bin/bash
# NOTE: despite the shebang, this file is *sourced* (from ~/.zshrc), so every function
# here must run in both bash and zsh. Two traps that have already bitten:
#   - `path` is a special zsh parameter tied to $PATH: never `read -r path`
#   - zsh arrays are 1-indexed, bash's are 0-indexed: prefer plain scalars
MIHOMO_PROXY_URL="http://127.0.0.1:7890"
MIHOMO_HOME="${MIHOMO_HOME:-$HOME/.config/mihomo}"
MIHOMO_DNS_VIRTUAL_IP="198.18.0.2"
MIHOMO_CONTROLLER_URL="http://127.0.0.1:9090" # matches external-controller in templates/mihomo.yaml
MIHOMO_NETWORK_SERVICE="Wi-Fi"                       # Consider making this dynamic in the future

# Derived config paths, all rooted at MIHOMO_HOME and fixed at load time.
# To relocate the config tree, set MIHOMO_HOME (or any of these) before sourcing
# this file. render_config and startproxy all read these globals.
#
#   templates/  tracked, shareable, no secrets
#   user/       untracked, your real config
#   generated/  untracked, derived — safe to delete and rebuild
MIHOMO_BASE_PATH="$MIHOMO_HOME/templates/mihomo.yaml"
MIHOMO_PROVIDERS_PATH="$MIHOMO_HOME/user/providers.yaml"
MIHOMO_OVERRIDE_RULE="$MIHOMO_HOME/templates/template-override.yq"
MIHOMO_OVERRIDE_PATH="$MIHOMO_HOME/generated/template-override.yaml"
MIHOMO_RUNTIME_PATH="$MIHOMO_HOME/generated/mihomo-runtime.yaml"
# Where the runtime's DNS resolver came from: "provider" (lifted from the provider
# cache) or "fallback" (user/providers.yaml — e.g. before the first subscription
# fetch). startproxy nudges a restart while it is "fallback".
MIHOMO_DNS_SOURCE="fallback"

# Single retry budget for every poll in the script (readiness, blocked site,
# and connection checks). Change here to tune how long mihomo is allowed to settle.
MIHOMO_RETRY_TRIES=10
MIHOMO_RETRY_DELAY=1

function is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

# ---------------------------------------------------------------------------
# Template override
#
# A subscription is a full Clash config, but mihomo reads only `proxies:` out of
# a proxy-provider document (adapter/provider/provider.go: ProxySchema). The
# provider's `dns:` block — notably its own resolver — is discarded.
# render_override() lifts the few keys that matter into
# MIHOMO_OVERRIDE_PATH, which render_config merges last so it wins.
#
#   lifted : dns.nameserver -> dns.nameserver (the airport's resolver becomes ours)
#            dns.use-hosts, dns.fake-ip-filter
#            root `hosts`, if a provider ships one
#   dropped: listen, enable, enhanced-mode, fake-ip-range, default-nameserver
#
# The keys and their mapping live in templates/template-override.yq; this function
# only finds the provider cache and applies the spec. The fresh-machine fallback
# (the airport's resolvers, used before the subscription has ever been fetched)
# lives in user/providers.yaml like the rest of the provider-specific spec —
# templates/mihomo.yaml stays a shareable template.
#
# Rationale and sources: docs/research/mihomo-provider-dns.md
# ---------------------------------------------------------------------------
function render_override() {
    # NOT `path`: this file is sourced from .zshrc, and in zsh `path` is a special
    # parameter tied to $PATH — `read -r path` would replace $PATH with the file
    # path and every later `yq` in this function would be "command not found".
    local f
    MIHOMO_DNS_SOURCE="fallback"

    # Cache paths come from user/providers.yaml rather than a glob, so a cache file
    # left behind by a removed subscription cannot leak into the runtime config. The
    # first provider whose cache exists wins.
    f=$(yq -r '.proxy-providers[].path // ""' "$MIHOMO_PROVIDERS_PATH" 2>/dev/null |
        while IFS= read -r p; do
            [[ -n "$p" ]] || continue
            [[ "$p" == /* ]] || p="$MIHOMO_HOME/${p#./}"
            [[ -f "$p" ]] && { printf '%s\n' "$p"; break; }
        done)

    # No cache, no dns:, a bad spec or a yq failure all fall through to an empty
    # overlay, which merges as a no-op and leaves the user/providers.yaml fallback
    # in charge. Only a non-empty overlay means the airport's resolver is now in use.
    if [[ -n "$f" ]] && yq --from-file "$MIHOMO_OVERRIDE_RULE" "$f" >"$MIHOMO_OVERRIDE_PATH" 2>/dev/null; then
        [[ "$(cat "$MIHOMO_OVERRIDE_PATH")" == "{}" ]] || MIHOMO_DNS_SOURCE="provider"
    else
        printf '{}\n' >"$MIHOMO_OVERRIDE_PATH"
    fi
}

# Render the runtime config: deep-merge templates/mihomo.yaml, user/providers.yaml
# (providers win), then generated/template-override.yaml (wins over both; arrays
# replace, not append). The base stays a shareable skeleton; the real subscription
# URL and the fallback live in user/providers.yaml. The rendered file is rejected
# unless `mihomo -t` accepts it, so a bad merge never reaches the routing path.
function render_config() {
    if [[ ! -f "$MIHOMO_PROVIDERS_PATH" ]]; then
        echo "Error: providers file not found at $MIHOMO_PROVIDERS_PATH" >&2
        echo "       cp $MIHOMO_HOME/templates/providers.yaml $MIHOMO_PROVIDERS_PATH" >&2
        echo "       then fill in the subscription URL." >&2
        return 1
    fi

    mkdir -p "$MIHOMO_HOME/generated"
    render_override

    if ! yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1) * select(fileIndex == 2)' \
        "$MIHOMO_BASE_PATH" "$MIHOMO_PROVIDERS_PATH" "$MIHOMO_OVERRIDE_PATH" >"$MIHOMO_RUNTIME_PATH"; then
        echo "Error: Failed to render runtime config." >&2
        rm -f "$MIHOMO_RUNTIME_PATH" # Clean up partial output.
        return 1
    fi

    # `mihomo -t` parses the whole config, so a malformed lifted dns: (invalid YAML,
    # a wrong type, a field the core rejects) is caught here rather than at start.
    # It does NOT check that the resolvers answer: an unresolvable
    # nameserver host still passes `-t` and only fails at dial time.
    local test_output
    if ! test_output=$(mihomo -t -d "$MIHOMO_HOME" -f "$MIHOMO_RUNTIME_PATH" 2>&1); then
        echo "Error: rendered config failed 'mihomo -t'; not starting." >&2
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

# Verify the running mihomo on demand: API controller up, a blocked site reachable
# through the mixed port, the dashboard served, and (macOS) system DNS pointed at
# mihomo's virtual IP. Retries briefly so mihomo can settle and providers/health-
# checks warm up. The runbook's proxy-phase CHECKs call this directly.
function statusproxy() {
    local failures=0 tries="$MIHOMO_RETRY_TRIES" delay="$MIHOMO_RETRY_DELAY"

    # 1. Process + API controller (readiness).
    if ! wait_for "$tries" "$delay" pgrep -x mihomo; then
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
        curl -fs -o /dev/null -x "$MIHOMO_PROXY_URL" https://www.youtube.com; then
        echo "status: FAIL - blocked site not reachable through $MIHOMO_PROXY_URL"
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
        if "$@" >/dev/null 2>&1; then
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
        sudo networksetup -setdnsservers "$MIHOMO_NETWORK_SERVICE" "$MIHOMO_DNS_VIRTUAL_IP"
    fi
    # -d sets Home Dir to the config dir: relative provider `path:` (./proxy_providers/...),
    # cache.db and external-ui all live under MIHOMO_HOME. Since the config dir
    # matches mihomo's default home dir, -d is technically redundant — kept for explicitness.
    sudo -b mihomo -d "$MIHOMO_HOME" -f "$MIHOMO_RUNTIME_PATH" >/dev/null 2>&1 &

    echo "mihomo started with config: $MIHOMO_RUNTIME_PATH"

    # Run the full statusproxy checks (readiness, blocked site, dashboard, DNS) so
    # startproxy only returns 0 when mihomo is fully working. statusproxy's first
    # step waits for the process + controller, so no separate boot gate is needed.
    if ! statusproxy; then
        echo "startproxy: FAILED - verify the statusproxy lines above" >&2
        return 1
    fi

    # Fresh machine: render_config ran before mihomo had ever fetched the
    # subscription, so no provider dns: existed to lift. Startup is still good
    # (the user/providers.yaml fallback handles node DNS) — an action, not a failure.
    if [[ "$MIHOMO_DNS_SOURCE" == "fallback" ]]; then
        echo "startproxy: note - no provider dns: was available to lift, so the fallback"
        echo "            in user/providers.yaml is in use. Restart the proxy"
        echo "            (stopproxy; startproxy) once the subscription has been fetched,"
        echo "            to pick up the airport's own."
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
        sudo networksetup -setdnsservers "$MIHOMO_NETWORK_SERVICE" Empty
    fi
}
