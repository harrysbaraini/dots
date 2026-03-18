#!/usr/bin/env bash
set -euo pipefail
TARGET_DIR="$HOME"
SESSION_NAME=""

if [ $# -ge 1 ]; then
  TARGET_DIR="$1"
fi

if [ $# -ge 2 ]; then
  SESSION_NAME="$2"
fi

if [ -n "$SESSION_NAME" ]; then
  nohup wezterm start --always-new-process --cwd "$TARGET_DIR" -- /bin/zsh -l -c "zellij attach -c $SESSION_NAME" &>/dev/null 2>&1 &
else
  nohup wezterm start --always-new-process --cwd "$TARGET_DIR" &>/dev/null 2>&1 &
fi

sleep 0.5

osascript <<EOF
tell application "WezTerm"
  activate
end tell
EOF
