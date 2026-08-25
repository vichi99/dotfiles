#!/bin/bash

sketchybar --add item volume right \
           --set volume update_freq=10 \
                      icon=􀊩 \
                      label="?" \
                      drawing=on \
                      script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change system_woke