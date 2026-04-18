-- SketchyBar settings / design tokens

local settings = {
	font = "Inter",
	font_style_regular = "Regular",
	font_style_bold = "Medium",
	font_style_italic = "Italic",
	font_style_italic_bold = "SemiBold Italic",

	font_nerd = "JetBrainsMono Nerd Font",

	app_font = "sketchybar-app-font",

	bar = {
		height = 36,
		corner_radius = 12,
		border_width = 1,
		blur_radius = 8,
		y_offset = 2,
		margin = 2,
	},

	item = {
		corner_radius = 8,
		height = 26,
		border_width = 1,
	},

	paddings = 6, -- default icon/label side padding
	group_padding = 4, -- padding inside bracket groups

	-- Workspace pill display
	workspaces = {
		ids = { "1", "2", "3", "4", "5" },
		labels = { "vans.dev", "Valley Metro", "Juiced", "Kirschbaum", "Workspace 5" },
		icons = { "", "", "", "", "󰂓", "󰎳", "󰎶", "󰎹", "󰎼", "󰎡" },
		circles = { "●", "○", "◉", "◎", "◌" },
	},

	-- Window title truncation length (chars before "…")
	title_max_chars = 16,
}

return settings
