#!/bin/bash

sketchybar --add item gpu right \
           --set gpu  update_freq=10 \
                      icon=GPU \
                      script="$PLUGIN_DIR/gpu.sh" \
                      click_script="open -a 'Activity Monitor'" \
           --subscribe gpu system_woke
