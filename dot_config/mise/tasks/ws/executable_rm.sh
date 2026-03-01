#!/usr/bin/env bash
#MISE description="Remove a workspace and all associated resources"
#MISE dir="{{cwd}}"

set -e

OPTIONS=$(ls -d workspaces/*/ | xargs -n 1 basename)

if [ -z "$OPTIONS" ]; then
  gum log --level info "No workspaces found. Nothing to remove."
  exit 0
fi

export WS_ID=$(gum choose $OPTIONS --header "Select the workspace to remove")

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

gum confirm "You are destroying the workspace $WS_ID. Are you sure?" --default="No" || exit 0

docker compose -f .devcontainer/docker-compose.yml down --rmi local --remove-orphans -v

if [ -f "./scripts/hook-post-destroy.sh" ]; then
  gum log --level info "Running post-destroy hook..."
  ./scripts/hook-post-destroy.sh || true
fi

cd ${PWD}
rm -rf $WS_PATH

gum log --level info "Workspace $WS_PATH removed successfully!"
