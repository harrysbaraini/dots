#!/bin/sh

source "$HOME/.config/sketchybar/variables.sh"

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [[ $NAME =~ ^space\.([^.]*)\.app\.(.*)\.label$ ]]; then
  SPACE_ID=${BASH_REMATCH[1]}
  APP_ID=${BASH_REMATCH[2]}

  CURRENT_SPACE=$(yabai -m query --spaces --space | jq '.index' | tr -d '"')
  CURRENT_APP=$(yabai -m query --windows --window | jq -r '.id')

  COLOR_INDEX=$((($CURRENT_SPACE - 1) % ${#SPACE_COLORS[@]}))
  LABEL_COLOR=${SPACE_COLORS[COLOR_INDEX]}

  if [ "$SPACE_ID" = "$CURRENT_SPACE" ] && [ "$APP_ID" = "$CURRENT_APP" ]; then
    sketchybar --set "$NAME" label.color=0xff${LABEL_COLOR}
  else
    sketchybar --set "$NAME" label.color=0xff${OLD_WHITE:2}
  fi
fi
