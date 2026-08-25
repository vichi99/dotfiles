#!/bin/bash

# Shows a full-screen centred message. Compiled on first use and cached, because
# interpreting the source with `swift` costs 269ms only while its module cache is
# warm — cold it took 38s, which would be unusable from a timer callback.
# Resolved from this script's own location rather than $CONFIG_DIR, so it also
# works when invoked by hand from a shell.
SRC="$(cd "$(dirname "$0")" && pwd)/overlay.swift"
BIN="$HOME/.cache/sketchybar/overlay"

if [ ! -x "$BIN" ] || [ "$SRC" -nt "$BIN" ]; then
  mkdir -p "$(dirname "$BIN")"
  swiftc -O -o "$BIN" "$SRC" 2>/dev/null || exit 0
fi

afplay /System/Library/Sounds/Ping.aiff &

# The border follows whichever scheme is active this session; colors.sh reads the
# cached pick rather than rolling a new one.
source "$(dirname "$SRC")/../colors.sh"

exec "$BIN" "${1:-Time is up}" "$ACCENT_COLOR"
