#!/bin/zsh
# @raycast.schemaVersion 1
# @raycast.title Go Home
# @raycast.description Unset Http(s) Proxy Globally
# @raycast.mode fullOutput
# @raycast.icon 🏠
# @raycast.packageName Network Tools
# @raycast.argument1 { "type": "dropdown", "placeholder": "Choose interface", "data": [ { "title": "Wi-Fi", "value": "Wi-Fi" }, { "title": "Ethernet", "value": "Ethernet" } ] }

INTERFACE="$1"

echo "Disabling proxy for $INTERFACE..."
networksetup -setwebproxystate "$INTERFACE" off
networksetup -setsecurewebproxystate "$INTERFACE" off
echo "✅ Proxy disabled for $INTERFACE"
