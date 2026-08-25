#!/bin/bash

sketchybar --add item btc left \
           --set btc update_freq=120 \
                    icon="₿" \
                    label="..." \
                    drawing=on \
                    script="$PLUGIN_DIR/btc.sh" \
           --subscribe btc system_woke