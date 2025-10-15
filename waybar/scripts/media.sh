#!/bin/bash

# Get the currently playing media using playerctl
song=$(playerctl metadata --format '{{ artist }} - {{ title }}' 2>/dev/null)

# If nothing is playing, show an icon
if [ -z "$song" ]; then
  echo ""
else
  # Limit the length to 40 chars for Waybar
  echo "${song:0:40}"
fi
