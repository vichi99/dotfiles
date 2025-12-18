#!/bin/bash

sketchybar --add item keyboard right \
           --set keyboard \
                      icon=􀺑  \
                      script="$PLUGIN_DIR/keyboard.sh" \
           --subscribe keyboard input_source_change system_woke