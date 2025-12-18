#!/bin/bash

get_country_code() {
  case "$1" in
        "U.S."|"US") echo "US" ;;
    "British"|"British-PC") echo "GB" ;;
    "Czech") echo "CZ" ;;
    "Czech-QWERTY") echo "CZ" ;;
    *) echo $1 ;;
  esac
}

LAYOUT=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null | sed 's/.*\.//')

if [ -z "$LAYOUT" ]; then
  # Fallback method for newer macOS versions
  LAYOUT=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null | grep "KeyboardLayout Name" | sed 's/.*= "\(.*\)";/\1/')
fi

COUNTRY_CODE=$(get_country_code "$LAYOUT")

if [ -n "$COUNTRY_CODE" ]; then
  sketchybar --set $NAME label="$COUNTRY_CODE"
fi