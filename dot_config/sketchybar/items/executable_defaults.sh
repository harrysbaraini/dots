#!/usr/bin/env zsh

default=(
  padding_left=8
  padding_right=8

  icon.font="${FONT_NAME}:Bold:16.0"
  label.font="${FONT_NAME}:Medium:13.0"

  icon.font.size=16.0
  label.font.size=13.0

  icon.color=0xff${WAVE_BLUE:2}
  label.color=0xff${FG_PRIMARY:2}

  icon.padding_left=8
  icon.padding_right=6
  label.padding_left=6
  label.padding_right=8

  background.color=0x${MODULE_BG_ALPHA}${BG_SURFACE:2}
  background.corner_radius=8
  background.height=26
  background.border_width=1
  background.border_color=0x${MODULE_BORDER_ALPHA}${WAVE_BLUE:2}
  background.shadow.drawing=off
)

sketchybar --default "${default[@]}"