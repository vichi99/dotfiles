#!/bin/bash

sketchybar --add item ram right \
           --set ram  update_freq=10 \
                      icon=􀧖  \
                      script="$PLUGIN_DIR/ram.sh" \
                      click_script="open -a 'Activity Monitor'" \
           --subscribe ram system_woke
