#!/bin/bash
MIHOMO_SERVICE_URL="http://127.0.0.1:7890"
MIHOMO_CONFIG_PATH="$HOME/.config/mihomo"
MIHOMO_DNS_VIRTUAL_IP="198.18.0.2"
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

    echo "mihomo started successfully with config: $runtime"
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
