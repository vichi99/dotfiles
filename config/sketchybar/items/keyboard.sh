#!/bin/bash

sketchybar --add event input_source_change 'AppleSelectedInputSourcesChangedNotification' \
           --add item keyboard right \
           --set keyboard update_freq=30 \
                      icon=􀺑  \
                      label="??" \
                      drawing=on \
                      script="$PLUGIN_DIR/keyboard.sh" \
           --subscribe keyboard input_source_change system_woke