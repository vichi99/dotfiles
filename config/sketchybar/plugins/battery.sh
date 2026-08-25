#!/bin/sh

# Wait a bit if this is triggered by system_woke (system commands may not be ready immediately)
if [ "$SENDER" = "system_woke" ]; then
  sleep 0.3
fi

PERCENTAGE=""
CHARGING=""
DEFAULT_ICON="􀛨"

# Method 1: pmset -g batt (primary method)
if command -v pmset >/dev/null 2>&1; then
  PERCENTAGE=$(pmset -g batt 2>/dev/null | grep -Eo "\d+%" 2>/dev/null | cut -d% -f1 | head -1)
  CHARGING=$(pmset -g batt 2>/dev/null | grep 'AC Power' 2>/dev/null || echo "")
fi

# Method 2: ioreg (fallback for macOS Tahoe)
if [ -z "$PERCENTAGE" ] && command -v ioreg >/dev/null 2>&1; then
  MAX_CAP=$(ioreg -rn AppleSmartBattery 2>/dev/null | grep -i "MaxCapacity" | awk '{print $3}' | head -1)
  CURR_CAP=$(ioreg -rn AppleSmartBattery 2>/dev/null | grep -i "CurrentCapacity" | awk '{print $3}' | head -1)
  
  if [ -n "$MAX_CAP" ] && [ -n "$CURR_CAP" ] && [ "$MAX_CAP" != "0" ]; then
    PERCENTAGE=$(awk "BEGIN {printf \"%.0f\", ($CURR_CAP/$MAX_CAP)*100}" 2>/dev/null)
  fi
  
  # Check charging status via ioreg
  if [ -z "$CHARGING" ]; then
    CHARGING=$(ioreg -rn AppleSmartBattery 2>/dev/null | grep -i "IsCharging" | grep -i "true" 2>/dev/null || echo "")
  fi
fi

# Method 3: system_profiler (alternative fallback)
if [ -z "$PERCENTAGE" ] && command -v system_profiler >/dev/null 2>&1; then
  PERCENTAGE=$(system_profiler SPPowerDataType 2>/dev/null | grep -i "Charge Remaining" | grep -Eo "\d+%" 2>/dev/null | cut -d% -f1 | head -1)
fi

# Method 4: Try reading from /sys (if available, unlikely on macOS but safe to try)
if [ -z "$PERCENTAGE" ] && [ -f /sys/class/power_supply/BAT0/capacity ]; then
  PERCENTAGE=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null | head -1)
fi

# Validate PERCENTAGE is a number
if [ -z "$PERCENTAGE" ] || ! [ "$PERCENTAGE" -eq "$PERCENTAGE" ] 2>/dev/null; then
  # Set default and ensure item is visible
  sketchybar --set $NAME icon="$DEFAULT_ICON" label="?" 2>/dev/null || sketchybar --set $NAME icon="$DEFAULT_ICON" label="?"
  exit 0
fi

# Ensure PERCENTAGE is within valid range
if [ "$PERCENTAGE" -lt 0 ] 2>/dev/null; then
  PERCENTAGE=0
elif [ "$PERCENTAGE" -gt 100 ] 2>/dev/null; then
  PERCENTAGE=100
fi

# Determine icon based on percentage
case ${PERCENTAGE} in
  9[0-9]|100) ICON="􀛨"
  ;;
  [6-8][0-9]) ICON="􀺸"
  ;;
  [3-5][0-9]) ICON="􀺶"
  ;;
  [1-2][0-9]) ICON="􀛩"
  ;;
  *) ICON="􀛪"
esac

# Override icon if charging
if [ -n "$CHARGING" ] && [ "$CHARGING" != "" ]; then
  ICON="􀢋"
fi

# Always set label and icon to ensure item is visible
sketchybar --set $NAME icon="$ICON" label="${PERCENTAGE}%" 2>/dev/null || sketchybar --set $NAME icon="$ICON" label="${PERCENTAGE}%"