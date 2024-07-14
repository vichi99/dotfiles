#!/bin/bash

get_country_code() {
  case "$1" in
        "U.S."|"US") echo "US" ;;
    "British"|"British-PC") echo "GB" ;;
    "Czech") echo "CZ" ;;
    "Czech-QWERTY") echo "CZ" ;;
    *) echo "Unknown" ;;
  esac
}

LAYOUT=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID | sed 's/.*\.//')

COUNTRY_CODE=$(get_country_code "$LAYOUT")

sketchybar --set $NAME label="$COUNTRY_CODE"
