#!/usr/bin/env bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
ITEMS_DIR="$CONFIG_DIR/items"
PLUGIN_DIR="$CONFIG_DIR/plugins"

#########################################
#  KANAGAWA WAVE – Muted Elegance Theme #
#########################################
# Inspired by Kanagawa & Catppuccin
# Soft, earthy tones with subtle accents

# Base colors (Kanagawa-inspired)
BG_BASE="0x1f1f28"    # Deep background
BG_SURFACE="0x2a2a37" # Surface layer
BG_OVERLAY="0x363646" # Overlay/highlight

# Muted accent colors
WAVE_BLUE="0x7e9cd8"     # Soft wave blue
SPRING_VIOLET="0x957fb8" # Gentle violet
AUTUMN_RED="0xc34043"    # Muted red
WAVE_AQUA="0x7fb4ca"     # Calm aqua
SPRING_GREEN="0x98bb6c"  # Soft green
AUTUMN_YELLOW="0xdca561" # Warm yellow
SAKURA_PINK="0xd27e99"   # Gentle pink
OLD_WHITE="0xdcd7ba"     # Aged white

# Text colors
FG_PRIMARY="0xdcd7ba"   # Main text
FG_SECONDARY="0xc8c093" # Secondary text
FG_DIM="0x727169"       # Dimmed text

###############################
# CONFIGURATION AND VARIABLES #
###############################

MODULE_BG_ALPHA="d0"     # More opaque for visibility
MODULE_BORDER_ALPHA="40" # Subtle borders

SPACE_POSITION="left"
SPACE_APPS_POSITION="center"

SPACE_ICONS=("" "" "" "" "" "󰂓" "󰎶" "󰎹" "󰎼" "󰎡")
SPACE_COLORS=(
  "${SPRING_VIOLET:2}"
  "${WAVE_BLUE:2}"
  "${SAKURA_PINK:2}"
  "${WAVE_AQUA:2}"
  "${SPRING_GREEN:2}"
  "${AUTUMN_YELLOW:2}"
  "${AUTUMN_RED:2}"
  "${WAVE_BLUE:2}"
  "${SPRING_VIOLET:2}"
  "${SAKURA_PINK:2}"
)

