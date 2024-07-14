#!/bin/bash

# SSID=$(ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}' | cut -c 1-12)
SSID=$(system_profiler SPAirPortDataType -detailLevel basic | awk '/Current Network/ {getline;$1=$1;print $0 | "tr -d ':'";exit}' | cut -c 1-12)

if [ "$SSID" = "" ]; then
  sketchybar --set $NAME label="Disconnected" icon=􀙥
else
  sketchybar --set $NAME label="$SSID" icon=􀙇
fi