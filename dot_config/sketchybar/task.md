# SketchyBar + AeroSpace Configuration

## Context

I'm migrating from yabai to AeroSpace on macOS. I use SketchyBar as my menu bar replacement. I need you to update my SketchyBar config to integrate properly with AeroSpace, showing workspaces and current workspace's windows.

## My setup

- **macOS** with the native menu bar set to auto-hide (`Always`)
- **AeroSpace** as tiling window manager (already installed and configured)
- **SketchyBar** installed via `brew install sketchybar`
- **Fonts installed**: `font-sketchybar-app-font`, `font-hack-nerd-font`
- **Config location**: `~/.config/sketchybar/`
- I am using sh for config, but we can migrate to use **Lua** for SketchyBar config (via SbarLua)
- I manage dotfiles with **chezmoi**, so everything must live in `~/.config/sketchybar/`

## Hardware context

I switch between:
1. **MacBook Pro** (has a notch) — single display, often with 5-6 windows per workspace in accordion or fullscreen mode
2. **Dual 27" monitors** — one horizontal, one vertical

The bar must work well on all three scenarios. On the MacBook, space is tight due to the notch — window names get truncated fast.

## What I want in the bar

### Left section
- AeroSpace workspace indicators
- Show first 6 workspaes, only. Regardless of having windows or not.
- Highlight the focused workspace clearly
- Clicking a workspace should switch to it (`aerospace workspace <id>`)

- List of windows in the **currently focused workspace only**
- Each window should show only its **app icon** (using `sketchybar-app-font`), except the focused window that should show its **app icon** (using `sketchybar-app-font`) and a **truncated window title**
- Highlight the currently focused window
- Clicking a window should focus it

### Right section
- Clock (time in ampm format)
- Battery (with percentage)

## AeroSpace integration details

AeroSpace communicates with SketchyBar via the `exec-on-workspace-change` callback. The relevant aerospace.toml config is:

```toml
exec-on-workspace-change = ['/bin/bash', '-c',
  'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE'
]
```

Useful AeroSpace CLI commands:
- `aerospace list-workspaces --all` — list all workspaces
- `aerospace list-workspaces --focused` — get focused workspace
- `aerospace list-workspaces --monitor focused` — workspaces on current monitor
- `aerospace list-windows --workspace <id>` — list windows in a workspace
- `aerospace list-windows --workspace <id> --format '%{app-name}'` — just app names
- `aerospace list-windows --workspace <id> --format '%{window-id} %{app-name} %{window-title}'` — full details
- `aerospace list-windows --focused` — get focused window info

## Multi-monitor behavior

- Each monitor should show its **own bar** with only the workspaces assigned to that monitor
- The window list should reflect the focused workspace on **that specific monitor**
- SketchyBar supports `associated_display` for per-monitor items — use this where needed

## Notch handling

SketchyBar has `notch_offset` and `notch_width` bar properties, plus positions `q` (left of notch) and `e` (right of notch). Use these to avoid content being hidden behind the MacBook notch.

## Performance considerations

- Batch SketchyBar commands into single calls where possible
- Use event-driven updates (subscribe to `aerospace_workspace_change`) rather than polling
- Set `updates=when_shown` for items not always visible
- The window list should update on workspace change and on window focus change — but avoid unnecessary redraws

## File structure

Please organize the config as:

```
~/.config/sketchybar/
├── sketchybarrc          # Entry point, loads init.lua
├── init.lua              # Main Lua config
├── colors.lua            # Color definitions
├── icons.lua             # Icon mappings
├── settings.lua          # Font sizes, paddings, etc.
├── items/
│   ├── workspaces.lua    # AeroSpace workspace indicators
│   ├── windows.lua       # Current workspace window list
│   ├── clock.lua         # Date/time
│   ├── battery.lua       # Battery indicator
│   └── volume.lua        # Volume indicator
└── helpers/
    └── icon_map.lua      # From sketchybar-app-font (auto-generated)
```

- Don't remove existing sh scripts. You can use them for reference.

## Style preferences

- Dark background with slight transparency/blur
- Rounded "island" style containers grouping related items (similar to Dynamic Island aesthetic)
- Subtle highlight for focused workspace/window (color accent, not just bold)
- Compact — the bar should not be taller than ~32-36px
- Use current sh scripts as reference for colors and styles (variables.sh contains the colors)

## What NOT to do

- Don't use bash scripts for the main logic — Lua only (small shell one-liners for data fetching are fine)
- Don't poll on a timer for workspace/window changes — use events
- Don't hardcode workspace IDs — dynamically discover them from AeroSpace
- Don't assume a fixed number of monitors
