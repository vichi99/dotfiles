#!/bin/bash

# Wait a bit if this is triggered by system_woke (system commands may not be ready immediately)
if [ "$SENDER" = "system_woke" ]; then
  sleep 0.3
fi

get_country_code() {
  case "$1" in
        "U.S."|"US") echo "US" ;;
    "British"|"British-PC") echo "GB" ;;
    "Czech") echo "CZ" ;;
    "Czech-QWERTY") echo "CZ" ;;
    *) echo $1 ;;
  esac
}

LAYOUT=""

# Method 1: AppleCurrentKeyboardLayoutInputSourceID (primary method)
if [ -z "$LAYOUT" ] && [ -f ~/Library/Preferences/com.apple.HIToolbox.plist ]; then
  LAYOUT=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null | sed 's/.*\.//' 2>/dev/null | head -1)
fi

# Method 2: AppleSelectedInputSources (fallback for newer macOS versions)
if [ -z "$LAYOUT" ] && [ -f ~/Library/Preferences/com.apple.HIToolbox.plist ]; then
  LAYOUT=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null | grep "KeyboardLayout Name" | sed 's/.*= "\(.*\)";/\1/' 2>/dev/null | head -1)
fi

# Method 3: plutil (alternative parser for macOS Tahoe)
if [ -z "$LAYOUT" ] && [ -f ~/Library/Preferences/com.apple.HIToolbox.plist ] && command -v plutil >/dev/null 2>&1; then
  LAYOUT=$(plutil -p ~/Library/Preferences/com.apple.HIToolbox.plist 2>/dev/null | grep -A 10 "AppleSelectedInputSources" | grep "KeyboardLayout Name" | head -1 | sed 's/.*"\(.*\)".*/\1/' 2>/dev/null)
fi

# Method 4: Try reading from AppleCurrentKeyboardLayoutInputSourceID using plutil
if [ -z "$LAYOUT" ] && [ -f ~/Library/Preferences/com.apple.HIToolbox.plist ] && command -v plutil >/dev/null 2>&1; then
  LAYOUT=$(plutil -p ~/Library/Preferences/com.apple.HIToolbox.plist 2>/dev/null | grep "AppleCurrentKeyboardLayoutInputSourceID" | head -1 | sed 's/.*"\(.*\)".*/\1/' | sed 's/.*\.//' 2>/dev/null)
fi

# Method 5: Try using osascript as last resort (for macOS Tahoe)
if [ -z "$LAYOUT" ] && command -v osascript >/dev/null 2>&1; then
  LAYOUT=$(osascript -e 'tell application "System Events" to tell process "SystemUIServer" to get value of menu bar item 1 of menu bar 1' 2>/dev/null || echo "")
fi

COUNTRY_CODE=$(get_country_code "$LAYOUT")

# Always set label to ensure item is visible, even if empty
if [ -n "$COUNTRY_CODE" ] && [ "$COUNTRY_CODE" != "" ] && [ "$COUNTRY_CODE" != "null" ]; then
  sketchybar --set $NAME label="$COUNTRY_CODE" 2>/dev/null || sketchybar --set $NAME label="$COUNTRY_CODE"
else
  # Set default label to ensure visibility
  sketchybar --set $NAME label="??" 2>/dev/null || sketchybar --set $NAME label="??"
fi