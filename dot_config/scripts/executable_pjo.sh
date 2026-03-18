#!/usr/bin/env bash
original_dir="$PWD"
dir name

# Find projects (git repos)
dir=$(find ~/dev ~/work ~/vans -maxdepth 3 -name ".git" 2>/dev/null | xargs -I{} dirname {} | fzf --preview 'ls -la {}')

[[ -z "$dir" ]] && return

# Run the project's mise task (if it has one) or default layout
if (cd "$dir" && mise tasks 2>/dev/null | grep -q "^terminal-workspace"); then
  (cd "$dir" && mise run terminal-workspace)
else
  # Fallback: create tab with default layout
  # Determine project name
  if [[ -f "$dir/.git" ]]; then
    # Git worktree: use {project}-{branch}
    branch=$(git -C "$dir" branch --show-current)
    main_repo=$(git -C "$dir" rev-parse --show-superproject-working-tree 2>/dev/null)
    main_repo=${main_repo:-$(cat "$dir/.git" | grep gitdir | sed 's|gitdir: ||; s|/.bare/worktrees/.*||')}
    name="$(basename "$main_repo")-${branch}"
  else
    # Regular repo: just basename
    name=$(basename "$dir")
  fi

  zellij action new-tab --name "$name" --cwd "$dir"
fi
