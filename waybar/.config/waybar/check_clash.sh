#!/bin/bash
#================================
# Check if clash has been started
#================================
if pgrep -x clash >/dev/null; then
  echo "{\"text\":\" \", \"tooltip\":\"clash is on\"}"
fi
