#!/bin/bash
#================================
# Check if mihomo has been started
#================================
if pgrep -x mihomo >/dev/null; then
  echo "{\"text\":\" \", \"tooltip\":\"mihomo is on\"}"
fi
