#!/bin/bash
# pactl-only volume indicator that actually works

SINK=$(pactl get-default-sink)
VOL=$(pactl get-sink-volume "$SINK" | grep -m1 -oP '\d+(?=%)' | head -1)
MUTE=$(pactl get-sink-mute "$SINK" | awk '{print $2}')

if [ "$MUTE" = "yes" ] || [ "$VOL" -eq 0 ]; then
    ICON=""
elif [ "$VOL" -lt 50 ]; then
    ICON=""; notify-send aaaaa;
else
    ICON=""
fi

echo "$ICON"
