#!/usr/bin/env zsh

source "$HOME/.config/sketchybar/variables.sh"

CURRENT_SPACE=$(yabai -m query --spaces --space | jq '.index')
LABELS=()

while IFS=$'\t' read -r id app title is_visible has_focus; do
    if [[ "$is_visible" == "true" ]]; then
      color="${OLD_WHITE:2}"

      if [[ "$has_focus" == "true" ]]; then
        color="${FG_PRIMARY:2}"

        if [[ "$app" == "wezterm-gui" ]]; then
          app="WezTerm"
        fi
      fi

      if [[ "$title" != "" ]]; then
        app="$app > $title"
      fi

      echo $app >> "$ITEMS_DIR/test.txt"
      LABELS+=("%{F#${color}}$app%{F-}")
    fi
  done < <(yabai -m query --windows --space "$CURRENT_SPACE" \
            | jq -r '.[] | "\(.id)\t\(.app)\t\(.title)\t\(.["is-visible"])\t\(.["has-focus"])"')

echo "${(j: :)LABELS}"