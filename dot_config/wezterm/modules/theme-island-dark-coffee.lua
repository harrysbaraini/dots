-- Islands Relax Dark Coffee - WezTerm Theme
-- Based on the JetBrains Islands Relax Dark Coffee theme by Panxiaoan
--
-- Usage: require this file from your wezterm.lua or copy the color_scheme
-- definition into your existing config.
--
--   local coffee = require("islands-dark-coffee")
--   config.colors = coffee.colors
--   -- optionally apply window styling:
--   coffee.apply_window_style(config)

local M = {}

M.colors = {
	-- Base colors derived from the JetBrains theme
	foreground = "#BBBBBB", -- primaryForeground
	background = "#2C2122", -- primaryBackground

	cursor_bg = "#DBAB4A", -- accentColor (gold)
	cursor_fg = "#2C2122", -- primaryBackground
	cursor_border = "#DBAB4A",

	selection_bg = "#6E4552", -- selectionBackground (dark mauve)
	selection_fg = "#BBBBBB",

	scrollbar_thumb = "#3c3031", -- mainBackground

	split = "#3c3031", -- borderColor / mainBackground

	-- ANSI colors mapped from the JetBrains icon ColorPalette & theme accents
	ansi = {
		"#2C2122", -- black        (primaryBackground)
		"#ff5554", -- red          (Actions.Red)
		"#2fc864", -- green        (Actions.Green)
		"#DBAB4A", -- yellow       (accentColor - gold)
		"#5da3f4", -- blue         (Actions.Blue)
		"#bd93f9", -- magenta      (Objects.Purple)
		"#A96F79", -- cyan         (underlineColor - muted rose)
		"#BBBBBB", -- white        (primaryForeground)
	},

	brights = {
		"#554849", -- bright black  (hover tones)
		"#ff79c6", -- bright red    (Objects.Pink)
		"#2fc864", -- bright green  (same green, already vivid)
		"#f1fa8c", -- bright yellow (Objects.Yellow)
		"#8be9fd", -- bright blue   (otherIconColor - cyan)
		"#ff79c6", -- bright magenta(Objects.Pink)
		"#DDD5D4", -- bright cyan   (checkbox foreground - warm white)
		"#DDD5D4", -- bright white  (light foreground)
	},

	-- Tab bar styling to match JetBrains editor tabs
	tab_bar = {
		background = "#201315", -- secondaryBackground

		active_tab = {
			bg_color = "#6E4552", -- tabColor / selectionBackground
			fg_color = "#BBBBBB", -- primaryForeground
			intensity = "Bold",
			underline = "Single",
		},

		inactive_tab = {
			bg_color = "#2C2122", -- primaryBackground
			fg_color = "#858994", -- Actions.Grey (dimmed)
		},

		inactive_tab_hover = {
			bg_color = "#6E4552", -- tabHoverBackground
			fg_color = "#BBBBBB",
			italic = false,
		},

		new_tab = {
			bg_color = "#201315", -- secondaryBackground
			fg_color = "#858994",
		},

		new_tab_hover = {
			bg_color = "#6E4552",
			fg_color = "#BBBBBB",
		},
	},
}

--- Apply window chrome & visual settings that complement the color scheme
function M.apply_to_config(config)
	config.colors = M.colors

	config.window_background_opacity = 1.0
	config.window_padding = {
		left = 12,
		right = 12,
		top = 8,
		bottom = 8,
	}
	config.use_fancy_tab_bar = true
	config.hide_tab_bar_if_only_one_tab = false
	config.tab_bar_at_bottom = false
	config.window_frame = {
		font_size = 12.0,
		active_titlebar_bg = "#201315", -- secondaryBackground
		inactive_titlebar_bg = "#201315",
	}
	config.inactive_pane_hsb = {
		saturation = 0.85,
		brightness = 0.7,
	}
end

return M
