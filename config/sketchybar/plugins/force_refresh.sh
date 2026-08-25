#!/bin/bash

# Apple Silicon Homebrew first (M-series), then Intel — ensures `command -v` works when GUI runs minimal PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

LOG_FILE="/tmp/sketchybar_refresh.log"

# React only to genuine wake / display change events.
# `sketchybar --update` runs ALL item scripts with $SENDER=forced (routine ticks use
# "routine"); without this guard the --update below would re-trigger this script in a loop.
if [ "$SENDER" != "system_woke" ] && [ "$SENDER" != "display_change" ]; then
  exit 0
fi

# Waking the laptop fires a burst of system_woke + display_change events (display
# reconfiguration happens in several steps). Trailing-edge debounce: every invocation
# records a unique token, waits, then only the LAST one in the burst proceeds — so the
# bar is recovered exactly once instead of flashing for every event.
STAMP="/tmp/sketchybar_refresh.stamp"
token="$$-$RANDOM"
echo "$token" > "$STAMP"
sleep 1.5
[ "$(cat "$STAMP" 2>/dev/null)" = "$token" ] || exit 0

SKETCHYBAR_BIN="$(command -v sketchybar 2>/dev/null)"
if [ -z "$SKETCHYBAR_BIN" ]; then
  echo "$(date): sketchybar not found in PATH" >> "$LOG_FILE"
  exit 1
fi

echo "$(date): refresh (Event: $SENDER)" >> "$LOG_FILE"

# After wake / display reconfiguration the bar window can get lost even though sketchybar
# still reports drawing=on / hidden=off — so --update alone does NOT bring it back.
# Toggling hidden forces the window to be re-presented (lightweight, no teardown/flicker
# like --reload), then --update refreshes all item values.
"$SKETCHYBAR_BIN" --bar hidden=on
sleep 0.2
"$SKETCHYBAR_BIN" --bar hidden=off
"$SKETCHYBAR_BIN" --update
