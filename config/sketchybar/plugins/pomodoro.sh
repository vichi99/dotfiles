#!/bin/bash

# Pomodoro timer. Invoked without arguments as the item script (update_freq tick,
# system_woke, forced update) and with an action argument from the popup click scripts.

source "$CONFIG_DIR/colors.sh"

ITEM="pomodoro"
STATE_DIR="$HOME/.cache/sketchybar"
STATE_FILE="$STATE_DIR/pomodoro.state"

ICON_RUN=􀐫
ICON_PAUSED=􀊗
IDLE_LABEL="∞"

# State file holds a single line, absent file means idle:
#   running <deadline_epoch> <total_min>
#   paused  <remaining_sec>  <total_min>
read_state() {
  STATE="idle"; VALUE=0; TOTAL=0
  [ -f "$STATE_FILE" ] || return
  read -r STATE VALUE TOTAL < "$STATE_FILE"
  case "$STATE" in
    running|paused) ;;
    *) STATE="idle" ;;
  esac
}

write_state() {
  mkdir -p "$STATE_DIR"
  echo "$1 $2 $3" > "$STATE_FILE"
}

remaining() {
  rem=$(( VALUE - $(date +%s) ))
  [ "$rem" -lt 0 ] && rem=0
  echo "$rem"
}

# Round up to a multiple of 5s so the display steps 5:00, 4:55, 4:50, ...
# regardless of where the 5s tick falls relative to the start.
fmt() {
  disp=$(( ($1 + 4) / 5 * 5 ))
  printf "%d:%02d" $((disp / 60)) $((disp % 60))
}

render() {
  case "$STATE" in
    running) sketchybar --set $ITEM icon="$ICON_RUN"    label="$(fmt "$(remaining)")" ;;
    paused)  sketchybar --set $ITEM icon="$ICON_PAUSED" label="$(fmt "$VALUE")" ;;
    *)       sketchybar --set $ITEM icon="$ICON_RUN"    label="$IDLE_LABEL" ;;
  esac
}

render_menu() {
  case "$STATE" in
    running) on="pause stop";  off="5 10 15 20 25 resume" ;;
    paused)  on="resume stop"; off="5 10 15 20 25 pause" ;;
    *)       on="5 10 15 20 25"; off="pause resume stop" ;;
  esac

  # Also clears any leftover hover highlight: mouse.exited does not fire on an
  # entry that was under the cursor when the popup closed.
  args=()
  for i in $on;  do args+=(--set "$ITEM.$i" drawing=on  background.drawing=off label.color=$WHITE); done
  for i in $off; do args+=(--set "$ITEM.$i" drawing=off background.drawing=off label.color=$WHITE); done
  sketchybar "${args[@]}"
}

close_and_refresh() {
  sketchybar --set $ITEM popup.drawing=off
  read_state
  render
}

finish() {
  rm -f "$STATE_FILE"
  STATE="idle"
  render
  # The overlay plays the sound itself, so there is no afplay here — two would
  # fire at once. Backgrounded: it lives for 5s and this runs from a 5s tick.
  "$CONFIG_DIR/plugins/overlay.sh" "Time is up" &
  osascript -e 'display notification "Time is up" with title "Pomodoro"'
}

read_state

case "$1" in
  menu)
    render_menu
    sketchybar --set $ITEM popup.drawing=toggle
    ;;
  start)
    write_state running $(( $(date +%s) + $2 * 60 )) "$2"
    close_and_refresh
    ;;
  pause)
    [ "$STATE" = "running" ] && write_state paused "$(remaining)" "$TOTAL"
    close_and_refresh
    ;;
  resume)
    [ "$STATE" = "paused" ] && write_state running $(( $(date +%s) + VALUE )) "$TOTAL"
    close_and_refresh
    ;;
  stop)
    rm -f "$STATE_FILE"
    close_and_refresh
    ;;
  hover)
    case "$SENDER" in
      mouse.entered) sketchybar --set "$NAME" background.drawing=on  label.color=$BAR_COLOR ;;
      mouse.exited)  sketchybar --set "$NAME" background.drawing=off label.color=$WHITE ;;
    esac
    ;;
  *)
    if [ "$SENDER" = "mouse.exited.global" ]; then
      sketchybar --set $ITEM popup.drawing=off
      exit 0
    fi
    if [ "$STATE" = "running" ] && [ "$(remaining)" -eq 0 ]; then
      finish
      exit 0
    fi
    render
    ;;
esac
