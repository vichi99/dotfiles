#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# ps reports each process as a percentage of one core, so the sum divided by the
# core count is the system-wide load. This runs ~5 points under `top`, which also
# counts kernel time that is not attributed to any process.
CORES=$(sysctl -n machdep.cpu.thread_count)
PCT=$(ps -eo pcpu= | awk -v c="$CORES" '{s+=$1} END {printf "%.0f", s/c}')

if   [ "$PCT" -gt 85 ]; then COLOR=$CRIT_COLOR
elif [ "$PCT" -gt 60 ]; then COLOR=$WARN_COLOR
else                         COLOR=$WHITE
fi

sketchybar --set "$NAME" label="$PCT%" label.color="$COLOR" icon.color="$COLOR"
