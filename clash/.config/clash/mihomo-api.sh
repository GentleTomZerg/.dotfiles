#!/bin/bash
CLASH_URL="http://127.0.0.1:7890"
CLASH_CONFIG_PATH="$HOME/.config/clash"


function setproxy() {
    export {http,https,ftp,all}_proxy="$CLASH_URL"
    export {HTTP,HTTPS,FTP,ALL}_PROXY="$CLASH_URL"
}

function unsetproxy() {
    unset {http,https,ftp,all}_proxy
    unset {HTTP,HTTPS,FTP,ALL}_PROXY
}

# Set Git Proxy
function gsetproxy() {
  git config --global http.proxy $CLASH_URL
  git config --global https.proxy $CLASH_URL
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

function backup_yaml() {
  echo "$CLASH_CONFIG_PATH/"
  find "$CLASH_CONFIG_PATH/" -type f -name "*.yaml" -exec cp {} {}.bak \;
}

function startproxy() {
# Check if clash is already running
  if [[ $(pidof mihomo) ]]; then
    echo "mihomo has already started."
    return 1;
  fi

  echo "Choose the configuration file:"

  select filename in $CLASH_CONFIG_PATH/*.yaml; do
    # Check if the user entered a valid selection
    if [[ -n "$filename" ]]; then
      nohup mihomo -f "$filename" > /dev/null &
      echo "Starting mihomo with configuration file: $filename"
      break
    else
      # Display an error message and prompt the user to choose a valid selection
      echo "Invalid selection. Please try again."
    fi
  done
}  

function stopproxy() {
  if [[ -z $(pidof mihomo) ]]; then
    echo "mihomo is not running"
    return 1
  fi

  kill "$(pidof mihomo)"
}

