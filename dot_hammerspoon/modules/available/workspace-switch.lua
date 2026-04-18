local utils = require("utils")
local spaces = require("hs.spaces")

local keys = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

for i, key in ipairs(keys) do
	hs.hotkey.bind(utils.HYPER, key, function()
		local screen = hs.screen.mainScreen()
		local screenSpaces = spaces.spacesForScreen(screen:getUUID())
		if screenSpaces and screenSpaces[i] then
			spaces.gotoSpace(screenSpaces[i])
		else
			hs.alert.show("No Space " .. i, 0.5)
		end
	end)
end
