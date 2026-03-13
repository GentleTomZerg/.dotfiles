#!/bin/bash
MIHOMO_SERVICE_URL="http://127.0.0.1:7890"
MIHOMO_CONFIG_PATH="$HOME/.config/clash"
MIHOMO_SUBSCRIBE_URL_PATH="$MIHOMO_CONFIG_PATH/subscribe_url.txt"
MIHOMO_CONFIG_TEMPLATE="$MIHOMO_CONFIG_PATH/mihomo.yaml"
MIHOMO_CONFIG_RUNTIME="$MIHOMO_CONFIG_PATH/mihomo_runtime.yaml"


function setproxy() {
    export {http,https,ftp,all}_proxy="$MIHOMO_SERVICE_URL"
    export {HTTP,HTTPS,FTP,ALL}_PROXY="$MIHOMO_SERVICE_URL"
}

function unsetproxy() {
    unset {http,https,ftp,all}_proxy
    unset {HTTP,HTTPS,FTP,ALL}_PROXY
}

function startproxy() {
    # 1. Check if mihomo is already running (check must be first and robust)
    if pgrep -x mihomo > /dev/null; then
        echo "mihomo has already started."
        return 1
    fi

    # 2. Safety check for the URL file
    if [[ ! -f "$MIHOMO_SUBSCRIBE_URL_PATH" ]]; then
        echo "Error: Subscription URL file not found at $MIHOMO_SUBSCRIBE_URL_PATH" >&2
        return 1
    fi

    # 3. Copy config template and check for failure
    if ! cp "$MIHOMO_CONFIG_TEMPLATE" "$MIHOMO_CONFIG_RUNTIME"; then
        echo "Error: Failed to copy template to runtime config." >&2
        return 1
    fi
        
    # 4. Use yq to do safely URL injection
    # If yq fails, remove the newly created runtime config before returning.
    SUBSCRIBE_URL=$(< "$MIHOMO_SUBSCRIBE_URL_PATH")
    if ! yq eval ".\"proxy-providers\".provider1.url = \"$SUBSCRIBE_URL\"" -i "$MIHOMO_CONFIG_RUNTIME"; then
        echo "Error: yq failed to inject subscription URL." >&2
        rm -f "$MIHOMO_CONFIG_RUNTIME" # Clean up failed config
        return 1
    fi

    # 5. Start mihomo in the background
    sudo -b mihomo -f "$MIHOMO_CONFIG_RUNTIME" > /dev/null 2>&1 &

    echo "mihomo started successfully with config: $MIHOMO_CONFIG_RUNTIME"
    return 0
}

function stopproxy() {
  if [[ -z $(pgrep -x mihomo) ]]; then
    echo "mihomo is not running"
    return 1
  fi

  sudo kill "$(sudo pgrep -x mihomo)"
}
