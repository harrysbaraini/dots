local wezterm = require("wezterm")
local mappings = require("modules.mappings")
require("modules.themes")

return {
	default_prog = { "/bin/zsh", "-l", "-c", "zellij" },
	default_cwd = wezterm.home_dir .. "/work",
	default_cursor_style = "BlinkingBar",
	cursor_blink_ease_in = "Constant",
	cursor_blink_ease_out = "Constant",
	cursor_blink_rate = 500,
	color_scheme = "Kanagawa (Gogh)",
	font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Regular" }),
	harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
	font_size = 16,
	line_height = 1.5,
	-- tab bar - Disable WezTerm's tabs since Zellij handles this
	enable_tab_bar = false,
	-- Window
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	window_decorations = "RESIZE",
	window_background_opacity = 1,
	macos_window_background_blur = 20,
	inactive_pane_hsb = {
		brightness = 0.7,
	},
	initial_rows = 30,
	initial_cols = 200,
	use_resize_increments = false,
	enable_scroll_bar = false,

	-- key bindings
	send_composed_key_when_left_alt_is_pressed = false,
	send_composed_key_when_right_alt_is_pressed = true,
	leader = mappings.leader,
	keys = mappings.keys,
	key_tables = mappings.key_tables,
	use_dead_keys = true,

	-- neovim optimizations
	enable_csi_u_key_encoding = true,
	underline_thickness = 2,
	underline_position = -2,
	scrollback_lines = 10000,
	max_fps = 240,
	enable_kitty_graphics = true,
}
