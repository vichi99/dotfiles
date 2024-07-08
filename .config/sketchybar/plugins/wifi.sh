#!/bin/bash

SSID=$(networksetup -getairportnetwork en0 | awk -F': ' '{print $2}' | cut -c 1-17)

if [ "$SSID" = "" ]; then
  sketchybar --set $NAME label="Disconnected" icon=􀙥
else
  sketchybar --set $NAME label="$SSID" icon=􀙇
fi