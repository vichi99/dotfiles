#!/bin/bash

sketchybar --add item worldclock left \
           --set worldclock update_freq=30 \
                    icon=􀆪 \
                    script="$PLUGIN_DIR/worldclock.sh" \
           --subscribe worldclock system_woke
