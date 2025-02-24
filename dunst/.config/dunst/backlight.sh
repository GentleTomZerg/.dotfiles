#!/bin/bash

# Brightness Control
if [[ "$1" == "increase" ]]; then
  # Increase brightness by 10%
  brightnessctl s 10%+
  brightness=$(brightnessctl g)
  max_brightness=$(brightnessctl m)
  brightness_percentage=$((brightness * 100 / max_brightness))
  dunstify -h string:x-canonical-private-synchronous:brightness "Brightness: " -h int:value:"$brightness_percentage" -t 1500 --icon display-brightness-off-symbolic

elif [[ "$1" == "decrease" ]]; then
  # Decrease brightness by 10%
  brightnessctl s 10%-
  brightness=$(brightnessctl g)
  max_brightness=$(brightnessctl m)
  brightness_percentage=$((brightness * 100 / max_brightness))
  dunstify -h string:x-canonical-private-synchronous:brightness "Brightness: " -h int:value:"$brightness_percentage" -t 1500 --icon display-brightness-off-symbolic
fi
