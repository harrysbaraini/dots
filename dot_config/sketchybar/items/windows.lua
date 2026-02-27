-- items/windows.lua
-- Displays the windows of the currently focused AeroSpace workspace.
-- • Non-focused windows: icon only (sketchybar-app-font)
-- • Focused window:      icon + truncated title
-- • Clicking a window focuses it via `aerospace focus --window-id <id>`
-- Updates on aerospace_workspace_change and front_app_switched.

local colors   = require("colors")
local settings = require("settings")
local icon_map = require("helpers.icon_map")

-- Track currently rendered windows so we can diff/highlight efficiently
local current_ws       = nil
local current_items    = {}   -- { [window_id] = item_ref }
local focused_win_id   = nil

-- Truncate a string to max_len chars, appending "…" if truncated
local function truncate(str, max_len)
  if not str or str == "" then return "" end
  if #str <= max_len then return str end
  return str:sub(1, max_len) .. "…"
end

-- Remove all existing window items and the container bracket
local function clear_windows()
  if next(current_items) ~= nil then
    sbar.remove("/win\\.item\\./")
    sbar.remove("/win\\.sep\\./")
    sbar.remove("win.container")
    current_items = {}
  end
end

-- Rebuild the entire window list for a given workspace ID
local function build_windows(ws_id, new_focused_win_id)
  clear_windows()

  -- aerospace list-windows outputs JSON; sbar.exec auto-parses JSON → Lua table
  local cmd = string.format(
    "aerospace list-windows --workspace %s --json 2>/dev/null",
    ws_id
  )

  -- determine colors from workspace
  local accent = colors.workspace_accents[tonumber(ws_id)] or colors.wave_blue
  local accent_bg = colors.with_alpha(accent, 0.15)
  local accent_border = colors.with_alpha(accent, 0.30)
  local accent_fg = colors.with_alpha(colors.old_white, 0.9)
  local accent_fg_muted = colors.with_alpha(accent, 0.60)

  sbar.exec(cmd, function(result)
    -- SbarLua auto-parses JSON output into a Lua table
    if type(result) ~= "table" then return end
    local windows = result
    if #windows == 0 then return end

    -- Determine the focused window for this workspace
    local fwd = tostring(new_focused_win_id or focused_win_id or "")

    local member_names = {}
    local is_first = true

    for _, win in ipairs(windows) do
      local win_id  = tostring(win["window-id"] or "")
      local app     = win["app-name"]    or ""
      local title   = win["window-title"] or ""
      local item_name = "win.item." .. win_id

      local is_focused = (win_id == tostring(fwd or ""))
      local app_icon   = icon_map.get(app)

      -- Separator between window items
      if not is_first then
        local sep_name = "win.sep." .. win_id
        sbar.add("item", sep_name, {
          position = "left",
          padding_left  = 0,
          padding_right = 0,
          icon = {
            string        = "│",
            color         = accent_border,
            padding_left  = 1,
            padding_right = 1,
          },
          label      = { drawing = false },
          background = { drawing = false },
        })
        table.insert(member_names, sep_name)
      end
      is_first = false

      local label_str   = ""
      local label_draw  = false

      if is_focused then
        label_str  = truncate(title, settings.title_max_chars)
        label_draw = (label_str ~= "")
      end

      local label_color = is_focused
        and accent_fg
        or  accent_fg_muted

      local item = sbar.add("item", item_name, {
        position = "left",
        padding_left  = 6,
        padding_right = 6,
        icon = {
          string        = app_icon,
          font          = {
            family = settings.app_font,
            style  = "Regular",
            size   = 14.0,
          },
          color         = is_focused and accent_fg or accent_fg_muted,
          padding_left  = 6,
          padding_right = is_focused and 4 or 6,
        },
        label = {
          string        = label_str,
          drawing       = label_draw,
          color         = label_color,
          font          = { family = settings.font, style = "Medium", size = 13.0 },
          padding_left  = 2,
          padding_right = 6,
        },
        background = { drawing = false },
        click_script = "aerospace focus --window-id " .. win_id,
      })

      current_items[win_id] = item
      table.insert(member_names, item_name)
    end

    -- Wrap in an "island" bracket if we have items
    if #member_names > 0 then
      sbar.add("bracket", "win.container", member_names, {
        background = {
          color         = accent_bg,
          border_color  = accent_border,
          border_width  = 1,
          corner_radius = settings.item.corner_radius,
          height        = settings.item.height,
        },
      })
    end
  end)
end

-- Fast re-highlight when only the focused window changes (no full rebuild)
local function rehighlight(new_focused_id)
  local old_id = tostring(focused_win_id or "")
  local new_id = tostring(new_focused_id or "")
  if old_id == new_id then return end

  -- De-highlight old focused window
  if old_id ~= "" and current_items[old_id] then
    current_items[old_id]:set({
      icon  = { color = accent_fg_muted },
      label = { drawing = false },
    })
  end

  -- Highlight new focused window
  if new_id ~= "" and current_items[new_id] then
    -- Need app title for the label; do a quick query
    sbar.exec(
      "aerospace list-windows --focused --format '%{window-title}' 2>/dev/null",
      function(title)
        local t = truncate((title or ""):gsub("%s+$", ""), settings.title_max_chars)
        current_items[new_id]:set({
          icon  = { color = accent_fg },
          label = { string = t, drawing = t ~= "" },
        })
      end
    )
  end

  focused_win_id = new_id
end

-- ─────────────────────────────────────────────
-- Sentinel item: invisible, used purely as an
-- event subscription anchor for workspace/focus
-- ─────────────────────────────────────────────
local sentinel = sbar.add("item", "win.event_sentinel", "left", {
  drawing = false,
  updates = true,   -- must be true so hidden item still receives events
})

sentinel:subscribe("aerospace_workspace_change", function(env)
  local ws = env.FOCUSED_WORKSPACE or ""
  current_ws = ws
  focused_win_id = nil
  build_windows(ws, nil)
end)

-- front_app_switched carries the new app name in env.INFO
-- We use it as an opportunity to re-highlight cheaply
sentinel:subscribe("front_app_switched", function(_)
  sbar.exec("aerospace list-windows --focused --format '%{window-id}' 2>/dev/null", function(id)
    local new_id = (id or ""):gsub("%s+", "")
    -- Try fast path first; if the window isn't in our map, do a full rebuild
    if current_items[new_id] then
      rehighlight(new_id)
    elseif current_ws then
      focused_win_id = new_id
      build_windows(current_ws, new_id)
    end
  end)
end)

-- Initial population
sbar.exec("aerospace list-workspaces --focused 2>/dev/null", function(ws)
  current_ws = (ws or ""):gsub("%s+", "")
  sbar.exec("aerospace list-windows --focused --format '%{window-id}' 2>/dev/null", function(id)
    focused_win_id = (id or ""):gsub("%s+", "")
    build_windows(current_ws, focused_win_id)
  end)
end)
