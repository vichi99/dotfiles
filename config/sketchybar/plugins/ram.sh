#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Activity Monitor's "Memory Used": app memory (anonymous pages that are not
# purgeable) plus wired plus what the compressor holds. memory_pressure's
# "free percentage" was used here before, but it counts inactive and speculative
# pages as free, so it reads far lower than what the machine is actually using.
PCT=$(vm_stat | awk -v total="$(sysctl -n hw.memsize)" '
  /page size of/ { for (i = 1; i < NF; i++) if ($i == "of") psize = $(i + 1) }
  { gsub(/\./, "", $NF) }
  /^Pages wired down/             { wired = $NF }
  /^Pages purgeable/              { purgeable = $NF }
  /^Anonymous pages/              { anon = $NF }
  /^Pages occupied by compressor/ { compressed = $NF }
  END {
    used = (anon - purgeable + wired + compressed) * psize
    printf "%.0f", used / total * 100
  }')

if   [ "$PCT" -gt 88 ]; then COLOR=$CRIT_COLOR
elif [ "$PCT" -gt 70 ]; then COLOR=$WARN_COLOR
else                         COLOR=$WHITE
fi

sketchybar --set "$NAME" label="$PCT%" label.color="$COLOR" icon.color="$COLOR"
