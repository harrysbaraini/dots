package.path = package.path
	.. ";/Users/vanderlei/.config/hammerspoon/modules/?.lua;/Users/vanderlei/.config/hammerspoon/modules/?/init.lua"

local utils = require("utils")

require("yabai")
require("window-switcher")
require("phpstorm")
-- require("wezterm")

-- Auto reload config
function reloadConfig(files)
	doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.config/hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon Config Loaded!", 0.5)
