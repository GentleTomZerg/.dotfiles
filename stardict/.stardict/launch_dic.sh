#!/bin/bash
# Get the word from rofi and directly pass it to sdcv
word=$(rofi -dmenu -p "Dictionary")
if [ -n "$word" ]; then
  alacritty -e zsh -c "sdcv \"$word\"; read"
fi
