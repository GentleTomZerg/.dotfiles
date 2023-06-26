#!/usr/bin/env bash

# Terminate already running bar instances
killall polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

interface=$(ip link | awk '/wl/ {print $2}' | cut -d':' -f1)

sed -i "1s/.*/[global]/" "$(dirname "$0")/config.ini"
sed -i "2s/.*/wifi-interface=$interface/" "$(dirname "$0")/config.ini"
# Launch polybar
polybar main -c $(dirname $0)/config.ini &

if [[ $(xrandr -q | grep 'DP-2 connected') ]]; then
	polybar external -c $(dirname $0)/config.ini &
fi


# Hide all the modules below when startup polybar
# i3wm has $mod+Shift+t keymappings to toggle the modules
polybar-msg action "#cpu.module_toggle"
polybar-msg action "#memory.module_toggle"
polybar-msg action "#filesystem.module_toggle"
