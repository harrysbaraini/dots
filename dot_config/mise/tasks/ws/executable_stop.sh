#!/usr/bin/env bash
#MISE description="Stop a workspace's dev container"
#MISE dir="{{cwd}}"

set -e

OPTIONS=$(ls -d workspaces/*/ | xargs -n 1 basename)

if [ -z "$OPTIONS" ]; then
  gum log --level info "No workspaces found. Nothing to stop."
  exit 0
fi

export WS_ID=$(gum choose "$OPTIONS" --header "Select the workspace to stop")

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

docker compose -f .devcontainer/docker-compose.yml down --remove-orphans

if [ -f "./scripts/hook-post-stop.sh" ]; then
  gum log --level info "Running post-stop hook..."
  ./scripts/hook-post-stop.sh || true
fi

PROJECT_CONTAINERS=$(docker ps -f "name=$WS_ID-" --format "{{.Names}}")

if [ ! -n "$PROJECT_CONTAINERS" ]; then
  gum confirm "There are remaining containers starting with '$WS_ID' name. Do you want to stop them as well?" --default="No" && mise run shared:stop || echo "Shared containers left running."
fi

exit 0
