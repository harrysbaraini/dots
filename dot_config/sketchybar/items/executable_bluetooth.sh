#!/usr/bin/env zsh

sketchybar --add item bluetooth right \
  --set bluetooth icon=󰂯 \
  icon.font.size=16.0 \
  icon.color=0xff${SPRING_VIOLET:2} \
  background.color=0x00000000 \
  background.corner_radius=0 \
  background.border_width=0 \
  background.shadow.drawing=off \
  label.drawing=off \
  update_freq=5 \
  script="$PLUGIN_DIR/bluetooth.sh" \
  --subscribe bluetooth mouse.clicked
