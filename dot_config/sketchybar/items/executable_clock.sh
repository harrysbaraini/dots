#!/usr/bin/env zsh

sketchybar --add item clock right \
  --set clock icon=󰥔 \
  icon.font.size=16.0 \
  icon.color=0xff${WAVE_BLUE:2} \
  label.color=0xff${FG_PRIMARY:2} \
  label.font="${FONT_NAME}:SemiBold:13.0" \
  background.color=0x00000000 \
  background.corner_radius=0 \
  background.padding_left=10 \
  background.padding_right=10 \
  background.border_width=0 \
  background.shadow.drawing=off \
  label.padding_left=8 \
  label.padding_right=12 \
  update_freq=1 \
  script="$PLUGIN_DIR/clock.sh"