-- items/windows.lua
-- Displays the windows of the currently focused PaperWM space.
-- • Non-focused windows: icon only (sketchybar-app-font)
-- • Focused window:      icon + truncated title
-- • Clicking a window focuses it via `hammerspoon://paperwm-focus-window?id=<id>`
-- State is sourced from /tmp/paperwm-sketchybar.json, written by the Hammerspoon
-- sketchybar bridge. We refresh on every `paperwm_workspace_change` event.

local colors = require("colors")
local settings = require("settings")
local icon_map = require("helpers.icon_map")

local STATE_FILE = "/tmp/paperwm-sketchybar.json"

local current_items = {} -- { [window_id] = item_ref }
local focused_win_id = nil
local current_ws = nil

local function truncate(str, max_len)
	if not str or str == "" then
		return ""
	end
	if #str <= max_len then
		return str
	end
	return str:sub(1, max_len) .. "…"
end

local function clear_windows()
	if next(current_items) ~= nil then
		sbar.remove("/win\\.item\\./")
		sbar.remove("win.container")
		current_items = {}
	end
end

local function render(state)
	clear_windows()
	if type(state) ~= "table" then
		return
	end

	local ws_idx = tonumber(state.focused_space) or 0
	current_ws = ws_idx
	focused_win_id = tostring(state.focused_window or "")

	local windows = state.windows or {}
	if #windows == 0 then
		return
	end

	-- Stable left-to-right order by window id
	table.sort(windows, function(a, b)
		return (tonumber(a.id) or 0) < (tonumber(b.id) or 0)
	end)

	local accent = colors.workspace_accents[ws_idx] or colors.wave_blue
	local accent_bg = colors.with_alpha(colors.bg_base, 0.85)
	local accent_border = colors.with_alpha(colors.bg_surface, 0.85)
	local accent_fg = colors.with_alpha(colors.fg_primary, 1)
	local accent_fg_muted = colors.with_alpha(colors.old_white, 0.80)

	local member_names = {}

	for _, win in ipairs(windows) do
		local win_id = tostring(win.id or "")
		if win_id ~= "" then
			local app = win.app or ""
			local title = win.title or ""
			local item_name = "win.item." .. win_id

			local is_focused = (win_id == focused_win_id)
			local app_icon = icon_map.get(app)

			local label_str = is_focused and truncate(title, settings.title_max_chars) or ""
			local label_draw = is_focused and (label_str ~= "")

			local item = sbar.add("item", item_name, {
				position = "left",
				padding_left = 4,
				padding_right = 4,
				icon = {
					string = app_icon,
					font = {
						family = settings.app_font,
						style = settings.font_style_regular,
						size = 12.0,
					},
					color = is_focused and accent_fg or accent_fg_muted,
					padding_left = 4,
					padding_right = is_focused and 2 or 4,
				},
				label = {
					string = label_str,
					drawing = label_draw,
					color = is_focused and accent_fg or accent_fg_muted,
					font = { family = settings.font, style = settings.font_style_bold, size = 12.0 },
					padding_left = 2,
					padding_right = 4,
				},
				background = { drawing = false },
				click_script = string.format("open -g 'hammerspoon://paperwm-focus-window?id=%s'", win_id),
			})

			current_items[win_id] = item
			table.insert(member_names, item_name)
		end
	end

	if #member_names > 0 then
		sbar.add("bracket", "win.container", member_names, {
			background = {
				color = accent_bg,
				border_color = accent_border,
				border_width = 0,
				corner_radius = settings.item.corner_radius,
				height = settings.item.height,
			},
		})
	end
end

local function refresh()
	sbar.exec("cat " .. STATE_FILE .. " 2>/dev/null", function(result)
		render(result)
	end)
end

-- ─────────────────────────────────────────────
-- Sentinel item: invisible, used purely as an
-- event subscription anchor for workspace/focus
-- ─────────────────────────────────────────────
local sentinel = sbar.add("item", "win.event_sentinel", "left", {
	drawing = false,
	updates = true, -- must be true so hidden item still receives events
})

sentinel:subscribe("paperwm_workspace_change", function(_)
	refresh()
end)

-- Initial population
refresh()
