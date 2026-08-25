#!/bin/bash

# Wait a bit if this is triggered by system_woke (system commands may not be ready immediately)
if [ "$SENDER" = "system_woke" ]; then
  sleep 0.3
fi

# Set default values to ensure item is always visible
DEFAULT_ICON="􀙥"
CONNECTED_ICON="􀙇"

# Get WiFi interface name with error handling
en=""
if command -v networksetup >/dev/null 2>&1; then
  en="$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi|AirPort/{getline; print $NF}' 2>/dev/null)"
fi

# If interface not found, show disconnected and exit
if [ -z "$en" ]; then
  sketchybar --set "$NAME" label="No WiFi" icon="$DEFAULT_ICON" 2>/dev/null || true
  exit 0
fi

# Check if WiFi is active (powered on and associated) with error handling
WIFI_ACTIVE=true
if command -v ipconfig >/dev/null 2>&1; then
  if ipconfig getsummary "$en" 2>/dev/null | grep -Fxq "  Active : FALSE" 2>/dev/null; then
    WIFI_ACTIVE=false
  fi
fi

if [ "$WIFI_ACTIVE" = false ]; then
  sketchybar --set "$NAME" label="Off" icon="$DEFAULT_ICON" 2>/dev/null || true
  exit 0
fi

# --- Get the SSID of the CURRENTLY CONNECTED network ---
# NOTE: do NOT use `networksetup -listpreferredwirelessnetworks` here: it lists
# SAVED networks, not the connected one, and will show a wrong name.
SSID=""

# Method 1: ipconfig getsummary (reliable current-network source on macOS 15+/26)
if command -v ipconfig >/dev/null 2>&1; then
  SSID=$(ipconfig getsummary "$en" 2>/dev/null | awk -F' SSID : ' '/ SSID : /{print $2; exit}')
fi

# Method 2: networksetup -getairportnetwork (older macOS fallback)
if [ -z "$SSID" ] && command -v networksetup >/dev/null 2>&1; then
  out=$(networksetup -getairportnetwork "$en" 2>/dev/null)
  case "$out" in
    *"not associated"*|*"not currently"*) : ;;  # not connected
    "Current Wi-Fi Network: "*) SSID="${out#Current Wi-Fi Network: }" ;;
  esac
fi

# Method 3: system_profiler (last resort; current network is the key after the header)
if [ -z "$SSID" ] && command -v system_profiler >/dev/null 2>&1; then
  SSID=$(system_profiler SPAirPortDataType 2>/dev/null | \
    awk '/Current Network Information:/{getline; gsub(/^[ \t]+|:[ \t]*$/,""); print; exit}')
fi

# macOS redacts the SSID unless the calling process has Location Services
# permission. The "SB Wifi" Shortcut (Get Network Details -> Wi-Fi Network Name)
# runs in Shortcuts.app, which holds that permission, so it returns the real name.
if [ -z "$SSID" ] || [ "$SSID" = "<redacted>" ]; then
  if command -v shortcuts >/dev/null 2>&1; then
    tmp="${TMPDIR:-/tmp}/sketchybar_ssid.txt"
    if shortcuts run "SB Wifi" -o "$tmp" >/dev/null 2>&1; then
      real=$(tr -d '\n\r' <"$tmp" 2>/dev/null)
      [ -n "$real" ] && [ "$real" != "<redacted>" ] && SSID="$real"
    fi
    rm -f "$tmp" 2>/dev/null
  fi
fi

# Still redacted -> connected but name unreadable; show neutral label.
if [ "$SSID" = "<redacted>" ]; then
  sketchybar --set "$NAME" label="WiFi" icon="$CONNECTED_ICON" 2>/dev/null || true
  exit 0
fi

# Truncate SSID to 12 characters and set label
if [ -n "$SSID" ]; then
  SSID=$(echo "$SSID" | cut -c 1-14)
  sketchybar --set "$NAME" label="$SSID" icon="$CONNECTED_ICON" 2>/dev/null || true
else
  sketchybar --set "$NAME" label="Disconnected" icon="$DEFAULT_ICON" 2>/dev/null || true
fi
