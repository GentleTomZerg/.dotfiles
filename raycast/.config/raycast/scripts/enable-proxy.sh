#!/bin/zsh
# @raycast.schemaVersion 1
# @raycast.title Go Abroad
# @raycast.description Set Http(s) Proxy Globally
# @raycast.mode fullOutput
# @raycast.icon 🪜
# @raycast.packageName Network Tools
# @raycast.argument1 { "type": "dropdown", "placeholder": "Choose interface", "data": [ { "title": "Wi-Fi", "value": "Wi-Fi" }, { "title": "Ethernet", "value": "Ethernet" } ] }

INTERFACE="$1"
HOST="127.0.0.1"
PORT="7890"

echo "Setting proxy for $INTERFACE..."
echo "Proxy -> $HOST:$PORT"
networksetup -setwebproxy "$INTERFACE" $HOST $PORT
networksetup -setsecurewebproxy "$INTERFACE" $HOST $PORT
echo "✅ Proxy enabled for $INTERFACE"
