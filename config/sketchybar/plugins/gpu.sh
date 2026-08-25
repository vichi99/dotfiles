#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# IOAccelerator exposes the GPU busy percentage without root; powermetrics would
# need sudo and, on Apple Silicon, no longer carries the smc sampler.
PCT=$(ioreg -r -d 1 -c IOAccelerator 2>/dev/null \
      | grep -o '"Device Utilization %"=[0-9]*' | head -1 | cut -d= -f2)
PCT=${PCT:-0}

if   [ "$PCT" -gt 85 ]; then COLOR=$CRIT_COLOR
elif [ "$PCT" -gt 60 ]; then COLOR=$WARN_COLOR
else                         COLOR=$WHITE
fi

sketchybar --set "$NAME" label="$PCT%" label.color="$COLOR" icon.color="$COLOR"
