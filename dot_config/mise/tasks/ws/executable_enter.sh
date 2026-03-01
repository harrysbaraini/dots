#!/usr/bin/env bash
#MISE description="Access the dev container of a workspace"
#MISE dir="{{cwd}}"

set -e

OPTIONS=$(ls -d workspaces/*/ | xargs -n 1 basename)

if [ -z "$OPTIONS" ]; then
  gum log --level info "No workspaces found."
  exit 0
fi

export WS_ID=$(gum choose "$OPTIONS" --header "Select the workspace")

if [ -z "$WS_ID" ]; then
  gum log --level error "No workspace selected."
  exit 1
fi

WS_PATH="${PWD}/workspaces/${WS_ID}"

cd $WS_PATH

if [ ! -d ".devcontainer" ]; then
  gum log --level error "No .devcontainer directory found in the selected workspace."
  exit 1
fi

devcontainer --workspace-folder exec bash
