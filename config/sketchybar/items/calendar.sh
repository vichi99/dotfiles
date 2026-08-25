#!/bin/bash

sketchybar --add item calendar right \
           --set calendar icon=􀧞  \
                          label.drawing=on \
                          update_freq=30 \
                          script="$PLUGIN_DIR/calendar.sh" \
           --subscribe calendar system_woke