-- Create a filter specifically for PhpStorm
local utils = require("utils")

local phpStormFilter = hs.window.filter.new("PhpStorm")

-- Function to move the window via yabai
local function movePhpStormToSpace(win)
	if not win:isStandard() then
		return nil
	end

	local title = win:title():lower()

	local space = "-"

	-- Check for "juiced" or "jui-" (case-insensitive)
	if title:find("^juiced") or title:find("^jui%-") then
		space = "JUI"
	end

	if space ~= "-" then
		local winID = win:id()

		-- 1. Get window info via your utils (assuming it returns JSON or a table)
		-- If your utils.yabai returns a string, we decode it here
		local winInfoCmd = string.format("-m query --windows --window %s", winID)
		local winInfoRaw = utils.yabaiSync(winInfoCmd)

		local winInfo = hs.json.decode(winInfoRaw)

		-- 2. Get target space info
		local targetSpaceRaw = utils.yabaiSync("-m query --spaces --space " .. space)
		local targetSpace = hs.json.decode(targetSpaceRaw)

		-- 3. Compare current space vs target space
		-- Using .index is usually safer than comparing labels directly
		if winInfo and targetSpace and winInfo.space ~= targetSpace.index then
			utils.yabai(string.format("-m window %s --space %s", winID, space))

			hs.timer.doAfter(0.2, function()
				utils.yabai(string.format("-m window --focus %s", winID))
			end)

			hs.alert.show(string.format("Moving %s to %s", win:title(), space))
		end
	end
end

-- Trigger when a window is created OR focused (to catch title updates)
phpStormFilter:subscribe(hs.window.filter.windowFocused, movePhpStormToSpace)
phpStormFilter:subscribe(hs.window.filter.windowCreated, movePhpStormToSpace)
