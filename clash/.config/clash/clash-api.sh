#!/bin/bash

URL_FILE="$HOME/.config/clash/urls.txt" # subscribed url
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

function updateproxy() {
    [ -s "$URL_FILE" ] || { touch "$URL_FILE" && echo "No url in '$URL_FILE'" && return 1; }

    # List all URLs in the file and prompt the user to choose one
    echo "Choose a URL from the list below:"
    select URL in $(cat "$URL_FILE"); do
        if [[ -z $URL ]]; then
            echo "Invalid selection. Please try again."
            continue
        fi
        
        ~/.config/clash/subconverter.sh clash "$URL" ||  return 1
        break
    done
}

function startproxy() {
# Check if clash is already running
  if [[ $(pidof clash) ]]; then
    echo "clash has already started."
    return 1;
  fi

  echo "Choose the configuration file:"

  select filename in $CLASH_CONFIG_PATH/*.yaml; do
    # Check if the user entered a valid selection
    if [[ -n "$filename" ]]; then
      nohup clash -f "$filename" > /dev/null &
      echo "Starting clash with configuration file: $filename"
      break
    else
      # Display an error message and prompt the user to choose a valid selection
      echo "Invalid selection. Please try again."
    fi
  done
}  

function stopproxy() {
  if [[ -z $(pidof clash) ]]; then
    echo "clash is not running"
    return 1
  fi

  kill "$(pidof clash)"
}

