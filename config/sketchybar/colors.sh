#!/bin/bash

export WHITE=0xffffffff

# Fill in a scheme name from the table below to pin it, leave empty to pick a
# random one on every sketchybar start / --reload.
PINNED_SCHEME=""

# name        BAR_COLOR  ITEM_BG_COLOR  ACCENT_COLOR
# ACCENT_COLOR is painted as a background with BAR_COLOR text (items/front_app.sh,
# plugins/space.sh), so keep it light enough to carry the dark tone on top.
SCHEMES=(
  "teal       0xff001f30 0xff003547 0xff2cf9ed"
  "gray       0xff101314 0xff353c3f 0xffffffff"
  "blue       0xff021254 0xff093aa8 0xff15bdf9"
  "google     0xff202124 0xff303134 0xff8ab4f8"
  "tokyo      0xff1a1b26 0xff24283b 0xff7aa2f7"
  "nord       0xff2e3440 0xff3b4252 0xff88c0d0"
  "gruvbox    0xff1d2021 0xff32302f 0xffd8a657"
  "everforest 0xff2d353b 0xff3d484d 0xffa7c080"
)

# This file is sourced once by sketchybarrc but also on every plugin invocation
# (plugins/space.sh, plugins/pomodoro.sh). Rolling the dice on every source would
# leave plugins painting their item in a different scheme than the bar was built
# with, so the pick is cached for the whole session and only sketchybarrc — which
# runs exactly once per start / --reload — asks for a new roll.
_scheme_cache="$HOME/.cache/sketchybar/scheme"
_scheme_name=""

_scheme_row() { # $1 = name -> matching table row, empty if there is none
  local row
  for row in "${SCHEMES[@]}"; do
    case "$row" in "$1 "*) echo "$row"; return ;; esac
  done
}

if [ -n "$PINNED_SCHEME" ]; then
  _scheme_name="$PINNED_SCHEME"
elif [ "$SKETCHYBAR_ROLL_SCHEME" != "1" ] && [ -f "$_scheme_cache" ]; then
  _scheme_name="$(cat "$_scheme_cache")"
fi

# Roll when asked to, and also when the cached or pinned name is no longer in the
# table (scheme renamed or removed).
_scheme_line="$(_scheme_row "$_scheme_name")"
if [ -z "$_scheme_line" ]; then
  _scheme_line="${SCHEMES[$RANDOM % ${#SCHEMES[@]}]}"
  mkdir -p "$(dirname "$_scheme_cache")"
  echo "${_scheme_line%% *}" > "$_scheme_cache"
fi

# Note: deliberately not `set -- $_scheme_line`, which would clobber the
# positional parameters of whoever sourced this file — plugins/pomodoro.sh
# dispatches on "$1" after sourcing us.
read -r _scheme_name BAR_COLOR ITEM_BG_COLOR ACCENT_COLOR <<< "$_scheme_line"
export BAR_COLOR ITEM_BG_COLOR ACCENT_COLOR

unset _scheme_cache _scheme_name _scheme_line
unset -f _scheme_row
