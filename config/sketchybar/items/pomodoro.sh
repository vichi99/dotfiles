#!/bin/bash

sketchybar --add item pomodoro left \
           --set pomodoro update_freq=5 \
                    icon=􀐫 \
                    label="∞" \
                    script="$PLUGIN_DIR/pomodoro.sh" \
                    click_script="$PLUGIN_DIR/pomodoro.sh menu" \
                    popup.background.color=$BAR_COLOR \
                    popup.background.corner_radius=5 \
                    popup.background.border_width=2 \
                    popup.background.border_color=$ITEM_BG_COLOR \
                    popup.align=left \
                    popup.y_offset=5 \
           --subscribe pomodoro system_woke mouse.exited.global

# Duration choices, shown when the timer is idle
for min in 5 10 15 20 25; do
  sketchybar --add item pomodoro.$min popup.pomodoro \
             --set pomodoro.$min label="$min min" \
                      icon.drawing=off \
                      background.color=$ACCENT_COLOR \
                      background.drawing=off \
                      label.padding_left=10 \
                      label.padding_right=10 \
                      script="$PLUGIN_DIR/pomodoro.sh hover" \
                      click_script="$PLUGIN_DIR/pomodoro.sh start $min" \
             --subscribe pomodoro.$min mouse.entered mouse.exited
done

# Controls, shown while a timer is running (pause/stop) or paused (resume/stop)
sketchybar --add item pomodoro.pause popup.pomodoro \
           --set pomodoro.pause label="Pause" \
                    icon.drawing=off \
                    background.color=$ACCENT_COLOR \
                    background.drawing=off \
                    label.padding_left=10 \
                    label.padding_right=10 \
                    drawing=off \
                    script="$PLUGIN_DIR/pomodoro.sh hover" \
                    click_script="$PLUGIN_DIR/pomodoro.sh pause" \
           --subscribe pomodoro.pause mouse.entered mouse.exited \
           --add item pomodoro.resume popup.pomodoro \
           --set pomodoro.resume label="Continue" \
                    icon.drawing=off \
                    background.color=$ACCENT_COLOR \
                    background.drawing=off \
                    label.padding_left=10 \
                    label.padding_right=10 \
                    drawing=off \
                    script="$PLUGIN_DIR/pomodoro.sh hover" \
                    click_script="$PLUGIN_DIR/pomodoro.sh resume" \
           --subscribe pomodoro.resume mouse.entered mouse.exited \
           --add item pomodoro.stop popup.pomodoro \
           --set pomodoro.stop label="Stop" \
                    icon.drawing=off \
                    background.color=$ACCENT_COLOR \
                    background.drawing=off \
                    label.padding_left=10 \
                    label.padding_right=10 \
                    drawing=off \
                    script="$PLUGIN_DIR/pomodoro.sh hover" \
                    click_script="$PLUGIN_DIR/pomodoro.sh stop" \
           --subscribe pomodoro.stop mouse.entered mouse.exited
