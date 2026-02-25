#!/usr/bin/env zsh

SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"
POPUP_SCRIPT="sketchybar -m --set \$NAME popup.drawing=toggle"

sketchybar --add event spotify_change $SPOTIFY_EVENT \
  --add item spotify.name right \
  --set spotify.name icon=󰓇 \
  icon.font.size=17.0 \
  label="Not Playing" \
  label.color=0xff${FG_PRIMARY:2} \
  label.font="${FONT_NAME}:SemiBold:13.0" \
  icon.color=0xff${SPRING_VIOLET:2} \
  background.color=0x00000000 \
  background.corner_radius=0 \
  background.border_width=0 \
  background.shadow.drawing=off \
  padding_left=12 \
  padding_right=12 \
  click_script="$POPUP_SCRIPT" \
  popup.horizontal=on \
  popup.align=center \
  popup.background.color=0xf0${BG_SURFACE:2} \
  popup.background.corner_radius=12 \
  popup.background.border_width=1 \
  popup.background.border_color=0x60${SPRING_VIOLET:2} \
  popup.background.shadow.drawing=off

controls=("back:󰒮:${WAVE_AQUA:2}" "play:󰐊:${SPRING_GREEN:2}" "next:󰒭:${WAVE_AQUA:2}" "shuffle:󰒝:${SPRING_VIOLET:2}" "repeat:󰑖:${AUTUMN_YELLOW:2}")

for ctrl in "${controls[@]}"; do
  IFS=':' read -r name icon color <<<"$ctrl"

  sketchybar --add item "spotify.$name" popup.spotify.name \
    --set "spotify.$name" icon="$icon" \
    icon.font.size=17.0 \
    icon.color=0xff$color \
    icon.highlight_color=0xff${SPRING_GREEN:2} \
    background.color=0x50${BG_OVERLAY:2} \
    background.corner_radius=8 \
    background.border_width=1 \
    background.border_color=0x30$color \
    background.shadow.drawing=off \
    label.drawing=off \
    updates=on \
    script="$PLUGIN_DIR/spotify.sh" \
    --subscribe "spotify.$name" mouse.clicked spotify_change
done