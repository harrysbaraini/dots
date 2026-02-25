#!/usr/bin/env zsh

sketchybar --add item battery right \
  --set battery icon=󰁹 \
  icon.font.size=16.0 \
  icon.color=0xff${SPRING_GREEN:2} \
  label.color=0xff${FG_SECONDARY:2} \
  background.color=0x00000000 \
  background.corner_radius=0 \
  background.padding_left=10 \
  background.padding_right=10 \
  background.border_width=0 \
  background.shadow.drawing=off \
  update_freq=60 \
  script="$PLUGIN_DIR/battery.sh" \
  --subscribe battery system_woke power_source_change