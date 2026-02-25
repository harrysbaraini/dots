#!/usr/bin/env zsh

sketchybar --remove '/space\./'

yabai -m query --spaces | jq -r '.[] | "\(.index) \(.label)"' | while read -r index label; do
  icon_index=$(($index - 1))
  color_index=$((($index - 1) % ${#SPACE_COLORS[@]}))
  space_color="${SPACE_COLORS[color_index]}"
  space_name="${label:-$index}"

  space=(
    associated_space=$index
    label="$space_name"
    label.drawing=off
    label.color=0xff${FG_SECONDARY:2}
    label.font="${FONT_NAME}:Medium:12.0"
    label.padding_left=8
    label.padding_right=8
    icon.drawing=on
    icon="${SPACE_ICONS[icon_index]}"
    icon.color=0xb0$space_color
    icon.highlight_color=0xff${FG_PRIMARY:2}
    icon.font.size=15.0
    background.color=0x00000000
    background.border_color=0x00000000
    background.padding_left=8
    background.padding_right=8
    background.border_width=1
    background.shadow.drawing=off
    background.shadow.drawing=off
    script="$PLUGIN_DIR/yabai-spaces.sh"
    click_script="yabai -m space --focus $space_namex"
  )

  sketchybar --add space space.$index $SPACE_POSITION \
    --set space.$index "${space[@]}" \
    --subscribe space.$index space_change display_change
done

draw_cosmic_sep="off"

if [ "$SPACE_POSITION" == "left" && "$SPACE_APPS_POSITION" == "left" ]; then
  draw_cosmic_sep="on"
fi

sketchybar --add item cosmic_sep $SPACE_POSITION \
  --set cosmic_sep icon=│ \
    drawing=$draw_cosmic_sep \
    icon.color=0x80${FG_DIM:2} \
    background.drawing=off \
    label.drawing=off \
    icon.padding_left=4 \
    icon.padding_right=16