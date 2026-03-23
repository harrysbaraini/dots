#!/bin/bash
# Create theme symlinks based on current macOS appearance.
# Runs after chezmoi apply to ensure symlinks exist and point correctly.

MODE="$(defaults read -g AppleInterfaceStyle 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo light)"

create_symlink() {
    local link="$1"
    local dark_target="$2"
    local light_target="$3"

    if [ "$MODE" = "dark" ]; then
        target="$dark_target"
    else
        target="$light_target"
    fi

    # Only update if missing, broken, or pointing to wrong target
    if [ ! -L "$link" ] || [ "$(readlink "$link")" != "$target" ]; then
        ln -sf "$target" "$link"
    fi
}

# WezTerm uses native appearance detection (wezterm.gui.get_appearance),
# no symlink needed.

create_symlink "$HOME/.config/zellij/config.kdl" \
    "config-dark.kdl" "config-light.kdl"

create_symlink "$HOME/.config/zellij/layouts/default.kdl" \
    "default-dark.kdl" "default-light.kdl"

create_symlink "$HOME/.config/sketchybar/colors.lua" \
    "colors-dark.lua" "colors-light.lua"

create_symlink "$HOME/.aerospace.toml" \
    "$HOME/.config/aerospace/aerospace-dark.toml" \
    "$HOME/.config/aerospace/aerospace-light.toml"
