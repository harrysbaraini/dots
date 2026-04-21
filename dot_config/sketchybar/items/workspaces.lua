-- items/workspaces.lua
-- PaperWM (Hammerspoon) workspace indicator pills (left side)
-- 5 fixed slots; focused one gets an accent-coloured pill background.
-- Clicking a pill switches to that PaperWM space via a hammerspoon:// URL.

local colors = require("colors")
local settings = require("settings")

local STATE_FILE = "/tmp/paperwm-sketchybar.json"

local ws_ids = settings.workspaces.ids
local ws_labels = settings.workspaces.labels
local ws_icons = settings.workspaces.icons

local ws_pill = sbar.add("item", "space_pill", {
	position = "left",
	padding_left = 2,
	padding_right = 4,
	label = {
		drawing = true,
		string = "Workspace",
		font = { family = settings.font, style = settings.font_style_bold, size = 12.0 },
		color = settings.bracket.text,
		padding_left = 8,
		padding_right = 8,
	},
	icon = {
		drawing = true,
		string = " ",
		color = settings.bracket.text,
		font = { family = settings.font_nerd, style = settings.font_style_bold, size = 12.0 },
		padding_left = 8,
		padding_right = 0,
	},
	background = {
		drawing = true,
		color = settings.bracket.bg,
		border_color = settings.bracket.border,
		border_width = 1,
		height = settings.item.height,
	},
})

-- ── Build pill items ──────────────────────────────────────────────────────────
local pills = {}

for i, id in ipairs(ws_ids) do
	local label = ws_labels[i] or id
	local icon = ws_icons[i] or id
	local accent = colors.workspace_accents[i] or colors.wave_blue

	pills[id] = { accent = accent, label = label, icon = icon }
end

-- ── Highlight logic ───────────────────────────────────────────────────────────
local function update_pills(focused_id)
	ws_pill:set({
		label = {
			string = pills[focused_id].label or "Workspace",
		},
		icon = {
			string = pills[focused_id].icon,
		},
	})
end

-- ── Separator ─────────────────────────────────────────────────────────────────
-- sbar.add("item", "ws_sep", {
--	position = "left",
--	padding_left = 0,
--	padding_right = 8,
--	icon = {
--		string = "│",
--		color = colors.with_alpha(colors.fg_dim, 0.30),
--		padding_left = 2,
--		padding_right = 2,
--	},
---	label = { drawing = false },
--	background = { drawing = false },
-- })

-- ── Event subscription via a single visible sentinel ──────────────────────────
-- IMPORTANT: must NOT be drawing=false with updates=when_shown, or events die.
local ws_sentinel = sbar.add("item", "ws.sentinel", {
	position = "left",
	drawing = false,
	updates = true, -- must be true so the hidden item still receives events
})

ws_sentinel:subscribe("paperwm_workspace_change", function(env)
	local focused_id = env.FOCUSED_WORKSPACE or ""
	update_pills(focused_id)
end)

-- ── Initial state ─────────────────────────────────────────────────────────────
sbar.exec("cat " .. STATE_FILE .. " 2>/dev/null", function(result)
	if type(result) == "table" and result.focused_space then
		update_pills(tostring(result.focused_space))
	end
end)

return { pill = ws_pill, update = update_pills }
