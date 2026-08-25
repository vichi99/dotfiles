#!/bin/bash

sketchybar --set "$NAME" \
  label="PRG $(TZ="Europe/Prague" date +'%H:%M') · UTC $(date -u +'%H:%M')"
