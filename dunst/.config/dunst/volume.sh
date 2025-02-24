#!/bin/bash

# Volume Control
if [[ "$1" == "raise_volume" ]]; then
  # Raise volume by 5%
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
  volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
  dunstify -h string:x-canonical-private-synchronous:audio "Volume: " -h int:value:"$volume" -t 1500 --icon audio-volume-low

elif [[ "$1" == "lower_volume" ]]; then
  # Lower volume by 5%
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
  volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
  dunstify -h string:x-canonical-private-synchronous:audio "Volume: " -h int:value:"$volume" -t 1500 --icon audio-volume-low

elif [[ "$1" == "mute_volume" ]]; then
  # Toggle mute
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

  # Check if muted
  muted=$(wpctl get-mute @DEFAULT_AUDIO_SINK@ | awk '{print $2}')

  if [[ "$muted" == "true" ]]; then
    dunstify -h string:x-canonical-private-synchronous:audio "Muted" -h int:value:"$volume" -t 1500 --icon audio-volume-muted
  else
    volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
    dunstify -h string:x-canonical-private-synchronous:audio "Unmuted - Volume: $volume%" -h int:value:"$volume" -t 1500 --icon audio-volume-low
  fi

# Mic Control
elif [[ "$1" == "mute_mic" ]]; then
  # Toggle mic mute
  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

  # Check if mic is muted
  mic_muted=$(wpctl get-mute @DEFAULT_AUDIO_SOURCE@ | awk '{print $2}')

  if [[ "$mic_muted" == "true" ]]; then
    dunstify -h string:x-canonical-private-synchronous:audio "Microphone Muted" -h int:value:"$volume" -t 1500 --icon audio-volume-muted
  else
    dunstify -h string:x-canonical-private-synchronous:audio "Microphone Unmuted" -h int:value:"$volume" -t 1500 --icon audio-volume-low
  fi
fi
