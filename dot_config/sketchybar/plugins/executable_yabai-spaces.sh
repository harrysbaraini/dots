#!/usr/bin/env zsh

source "$HOME/.config/sketchybar/variables.sh"

CURRENT_SPACE=$(yabai -m query --spaces --space | jq '.index' | tr -d '"')
ITEM_INDEX=${NAME#space.}

color_index=$(($ITEM_INDEX % ${#SPACE_COLORS[@]}))
color=${SPACE_COLORS[color_index]}

# Update spaces position based on the current display
display_width=$(yabai -m query --displays --display | jq '.frame.w')

if [ "$SPACE_APPS_POSITION" = "left" ]; then
  sketchybar --set cosmic_sep drawing=on
else
  sketchybar --set cosmic_sep drawing=off
fi

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# Update spaces indicator
if [ "$ITEM_INDEX" -eq "$CURRENT_SPACE" ]; then
  sketchybar --set space.$ITEM_INDEX \
    label.drawing=on \
    label.color=0xff${color} \
    background.color=0x28${color} \
    background.border_color=0x48${color}

  IS_FIRST=true

  while IFS=$'\t' read -r id app title is_visible has_focus; do
    # handle $id, $app, $title, $is_visible, $has_focus
    if [[ "$is_visible" == "true" ]]; then
      app_label_color="${OLD_WHITE:2}"

      if [[ "$has_focus" == "true" ]]; then
        app_label_color="${color}"
      fi

      if [[ "$app" == "wezterm-gui" ]]; then
          app=""
        elif [[ "$app" == "Dia" ]]; then
          app=""
        elif [[ "$app" == "Slack" ]]; then
          app=""
        elif [[ "$app" == "PhpStorm" ]]; then
          # app=""
          app=""
        elif [[ "$app" == "Code" ]]; then
          app="󰨞"
        elif [[ "$app" == "Spotify" ]]; then
          app=""
        elif [[ "$app" == "Firefox" ]]; then
          app=""
        elif [[ "$app" == "Google Chrome" ]]; then
          app=""
        elif [[ "$app" == "Proton Pass" ]]; then
          app=""
        elif [[ "$app" == "Proton Mail" ]]; then
          app=""
        fi

      if [[ "$title" != "" ]]; then
        app="$app  $title"
      fi

      app=$(echo "$app" | sed 's/\(.\{12\}\).*/\1.../')

      if [[ "$IS_FIRST" = true ]]; then
        IS_FIRST=false
      else
        sketchybar --add item "space.$ITEM_INDEX.app.$id.sep" $SPACE_APPS_POSITION \
          --set "space.$ITEM_INDEX.app.$id.sep" icon=│ \
                icon.color=0x40${OLD_WHITE:2} \
                background.drawing=off \
                label.drawing=off \
                icon.padding_left=2 \
                icon.padding_right=2
      fi

      sketchybar --add item space.$ITEM_INDEX.app.$id.label $SPACE_APPS_POSITION \
        --set space.$ITEM_INDEX.app.$id.label icon.drawing=off \
              label="${app}" \
              label.color=0xff${app_label_color} \
              label.font="${FONT_NAME}:SemiBold:13.0" \
              label.padding_left=8 \
              label.padding_right=8 \
              background.drawing=off \
              script="$PLUGIN_DIR/front_app.sh" \
        --subscribe space.$ITEM_INDEX.app.$id.label front_app_switched space_change space_windows_change display_change
  fi
  done < <(yabai -m query --windows --space $CURRENT_SPACE \
          | jq 'sort_by(.["stack-index"],.app,.title)' | jq -r '.[] | "\(.id)\t\(.app)\t\(.title)\t\(.["is-visible"])\t\(.["has-focus"])"')

  sketchybar --add bracket space.$ITEM_INDEX.container /^space.$ITEM_INDEX.app\./ \
    --set space.$ITEM_INDEX.container \
          background.color=0x10${OLD_WHITE:2} \
          background.border_color=0x28${OLD_WHITE:2} \
          background.padding_left=8 \
          background.padding_right=8 \
          background.border_width=1 \
          background.shadow.drawing=off
else
  sketchybar --set space.$ITEM_INDEX \
    label.drawing=off \
    label.color=0xff${FG_SECONDARY:2} \
    background.color=0x00000000 \
    background.border_color=0x00000000

  sketchybar --remove space.$ITEM_INDEX.container
  sketchybar --remove /^space.$ITEM_INDEX.app\./
fi
