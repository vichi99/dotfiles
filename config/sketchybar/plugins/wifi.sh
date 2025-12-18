#!/bin/bash

# Get WiFi interface name and SSID
en="$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $NF}')"
SSID=$(ipconfig getsummary "$en" | grep -Fxq "  Active : FALSE" || networksetup -listpreferredwirelessnetworks "$en" | sed -n '2s/^\t//p')

# Truncate SSID to 12 characters
SSID=$(echo "$SSID" | cut -c 1-12)

if [ -z "$SSID" ]; then
  sketchybar --set $NAME label="Disconnected" icon=􀙥
else
  sketchybar --set $NAME label="$SSID" icon=􀙇
fi