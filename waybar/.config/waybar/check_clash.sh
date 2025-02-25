#!/bin/bash
#================================
# Check if clash has been started
#================================
if pgrep -x mihomo >/dev/null; then
  echo "{\"text\":\" \", \"tooltip\":\"clash is on\"}"
fi
