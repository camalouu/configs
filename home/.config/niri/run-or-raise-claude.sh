#!/bin/bash
APP_ID=$1
SPAWN_CMD=$2  # Keep as single string

# Get all window IDs for the app
INSTANCES=($(niri msg -j windows | jq -r ".[] | select(.app_id==\"$APP_ID\") | .id"))

# If no instances exist, launch the app
if [ ${#INSTANCES[@]} -eq 0 ]; then
    if [ -n "$SPAWN_CMD" ]; then
        eval "$SPAWN_CMD"
    else
        niri msg action spawn -- "$APP_ID"
    fi
    exit 0
fi

# If only one instance, focus it
if [ ${#INSTANCES[@]} -eq 1 ]; then
    niri msg action focus-window --id "${INSTANCES[0]}"
    exit 0
fi

# Multiple instances: sort them
ISORTED=($(printf "%s\n" "${INSTANCES[@]}" | sort -n))

# Get currently focused window ID
FOCUSED=$(niri msg -j focused-window | jq -r '.id')

# Check if any instance of our app is focused
FOUND_INDEX=-1
for i in "${!ISORTED[@]}"; do
    if [ "${ISORTED[$i]}" -eq "$FOCUSED" ]; then
        FOUND_INDEX=$i
        break
    fi
done

# If no instance is focused, focus the first one
if [ $FOUND_INDEX -eq -1 ]; then
    niri msg action focus-window --id "${ISORTED[0]}"
else
    # Focus next instance (wrap around to 0 if at the end)
    NEXT_INDEX=$(( (FOUND_INDEX + 1) % ${#ISORTED[@]} ))
    niri msg action focus-window --id "${ISORTED[$NEXT_INDEX]}"
fi
