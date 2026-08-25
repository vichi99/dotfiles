#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set "$NAME" label="$INFO" icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "$INFO")"
elif [ "$SENDER" = "system_woke" ]; then
  APP="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)"
  if [ -n "$APP" ]; then
    sketchybar --set "$NAME" label="$APP" icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "$APP")"
  fi
fi