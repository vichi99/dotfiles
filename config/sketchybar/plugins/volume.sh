#!/bin/sh

# Wait a bit if this is triggered by system_woke (system commands may not be ready immediately)
if [ "$SENDER" = "system_woke" ]; then
  sleep 0.2
fi

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "volume_change" ]; then
  VOLUME=$INFO
else
  VOLUME=$(osascript -e "output volume of (get volume settings)" 2>/dev/null)
fi

# If volume is empty or invalid, try alternative method
if [ -z "$VOLUME" ] || ! [ "$VOLUME" -eq "$VOLUME" ] 2>/dev/null; then
  VOLUME=$(osascript -e "tell application \"System Events\" to get value of slider 1 of group 1 of window 1 of application process \"ControlCenter\"" 2>/dev/null || echo "")
fi

# If still empty, set default and exit
if [ -z "$VOLUME" ] || ! [ "$VOLUME" -eq "$VOLUME" ] 2>/dev/null; then
  sketchybar --set $NAME icon="􀊩" label="?"
  exit 0
fi

case $VOLUME in
  [6-9][0-9]|100) ICON="􀊩"
  ;;
  [3-5][0-9]) ICON="􀊥"
  ;;
  [1-9]|[1-2][0-9]) ICON="􀊡"
  ;;
  *) ICON="􀊣"
esac

sketchybar --set $NAME icon="$ICON" label="$VOLUME%"