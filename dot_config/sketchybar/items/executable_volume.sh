#!/usr/bin/env zsh

sketchybar --add item volume right \
  --set volume icon=󰕾 \
  icon.font.size=16.0 \
  icon.color=0xff${SAKURA_PINK:2} \
  label.color=0xff${FG_SECONDARY:2} \
  background.color=0x00000000 \
  background.corner_radius=0 \
  background.border_width=0 \
  background.padding_left=10 \
  background.padding_right=10 \
  background.shadow.drawing=off \
  script="$PLUGIN_DIR/volume.sh" \
  --subscribe volume volume_change