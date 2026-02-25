local wezterm = require("wezterm")
local act = wezterm.action

return {
	leader = { key = "Space", mods = "SHIFT" },

	keys = {
		-- Release the following key bindings to Zellij:
		{ key = "Space", mods = "CTRL", action = act.SendString("\x00") },
		{ key = "h", mods = "ALT", action = wezterm.action.SendKey({ key = "h", mods = "ALT" }) },
		{ key = "j", mods = "ALT", action = wezterm.action.SendKey({ key = "j", mods = "ALT" }) },
		{ key = "k", mods = "ALT", action = wezterm.action.SendKey({ key = "k", mods = "ALT" }) },
		{ key = "l", mods = "ALT", action = wezterm.action.SendKey({ key = "l", mods = "ALT" }) },

		-- Cmd+T sends Ctrl+a then c (new Zellij tab)
		{
			key = "t",
			mods = "CMD",
			action = act.Multiple({
				act.SendKey({ key = "a", mods = "CTRL" }),
				act.SendKey({ key = "c" }),
			}),
		},

		-- Support Claude code SHIFT+Enter --
		{
			key = "Enter",
			mods = "SHIFT",
			action = wezterm.action({ SendString = "\x1b\r" }),
		},

		-- Toogle theme
		{
			key = "t",
			mods = "LEADER",
			action = wezterm.action({ EmitEvent = "toggle-color-scheme" }),
		},

		-- Copy selection with Cmd+C
		-- {
		--	key = "c",
		--	mods = "CMD",
		--	action = wezterm.action.CopyTo("Clipboard"),
		-- },
	},
}
