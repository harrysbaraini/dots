#!/usr/bin/env bash
#MISE description="Work on a workspace's dev container"
#MISE dir="{{cwd}}"

set -e

OPTIONS=$(ls -d workspaces/*/ | xargs -n 1 basename)

if [ -z "$OPTIONS" ]; then
  gum log --level info "No workspaces found. Nothing to start."
  exit 0
fi

export WS_ID=$(gum choose "$OPTIONS" --header "Select the workspace to start")

if [ -z "$WS_ID" ]; then
  gum log --level error "No workspace selected."
  exit 1
fi

WS_PATH="${PWD}/workspaces/${WS_ID}"

if [ ! -d "$WS_PATH/.devcontainer" ]; then
  gum log --level error "No .devcontainer directory found in the selected workspace."
  exit 1
fi

open -na "PhpStorm.app" --args "$WS_PATH"