#!/bin/bash

sketchybar --add item wifi right \
           --set wifi update_freq=30 \
                      icon=􀙇 \
                      label="..." \
                      drawing=on \
                      script="$PLUGIN_DIR/wifi.sh" \
           --subscribe wifi wifi_change system_woke