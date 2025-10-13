#!/bin/bash
MIHOMO_SERVICE_URL="http://127.0.0.1:7890"
MIHOMO_CONFIG_PATH="$HOME/.config/clash"
MIHOMO_SUBSCRIBE_URL=$(cat "$MIHOMO_CONFIG_PATH"/subscribe_url.txt)
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

# Set Git Proxy
function gsetproxy() {
  git config --global http.proxy $MIHOMO_SERVICE_URL
  git config --global https.proxy $MIHOMO_SERVICE_URL
}

# Unset Git Proxy
function gunsetproxy() {
  git config --global --unset http.proxy
  git config --global --unset https.proxy
}

# Check Git Proxy Status
function ggetproxy() {
  git config --global --get http.proxy
  git config --global --get https.proxy
}

function startproxy() {
# Check if clash is already running
  if [[ $(pgrep -x mihomo) ]]; then
    echo "mihomo has already started."
    return 1;
  fi

  yq eval '.["proxy-providers"].provider1.url = env(MIHOMO_SUBSCRIBE_URL)' -i "$MIHOMO_CONFIG_RUNTIME"

  if [[ -f "$MIHOMO_CONFIG_RUNTIME" ]];then
      nohup mihomo -f "$MIHOMO_CONFIG_RUNTIME" > /dev/null &
      echo "Starting mihomo with configuration file: $MIHOMO_CONFIG_RUNTIME"
  else
      echo "$MIHOMO_CONFIG_RUNTIME not found"
      return 1
  fi
}  

function stopproxy() {
  if [[ -z $(pgrep -x mihomo) ]]; then
    echo "mihomo is not running"
    return 1
  fi

  kill "$(pgrep -x mihomo)"
}
