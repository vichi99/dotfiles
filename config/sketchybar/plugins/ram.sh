#!/bin/bash

USED_PCT="$(memory_pressure 2>/dev/null | grep "System-wide memory free percentage:" | awk '{ printf "%02.0f", 100 - $5 }')"
sketchybar --set "$NAME" label="${USED_PCT}%"