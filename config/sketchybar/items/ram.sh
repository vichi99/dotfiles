#!/bin/bash

sketchybar --add item ram right \
           --set ram  update_freq=10 \
                      icon=􀧖  \
                      script="$PLUGIN_DIR/ram.sh" \
           --subscribe system_woke