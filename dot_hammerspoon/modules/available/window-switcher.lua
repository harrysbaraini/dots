local utils = require("utils")

local M = {}

-- Helper to query yabai and get JSON output
local function queryYabai(args)
	local yabaiResult = utils.yabaiSync(args)

	if yabaiResult and yabaiResult ~= "" then
		local result = hs.execute(string.format("jq 'sort_by(.\"stack-index\",.app,.title)' <<< '%s'", yabaiResult))
		
		if result and result ~= "" then
			return hs.json.decode(result)
		end
	end

	return nil
end

-- State
local switcher = {
	windows = {},
	currentIndex = 1,
	modifierWatcher = nil,
}

-- Get current yabai space
local function getCurrentSpace()
	local yabaiResult = utils.yabaiSync("-m query --spaces --space")
	local json = nil

	if yabaiResult and yabaiResult ~= "" then
		json = hs.json.decode(yabaiResult)
	end

	if not json then
		hs.alert.show("Error: Unable to query yabai")
		return nil
	end
	
	return json.index
end

-- Get windows in current yabai space
local function getWindowsInCurrentSpace()
	local currentSpace = getCurrentSpace()

	if not currentSpace then
		return {}
	end

	-- Get all windows from yabai in the current space
	local yabaiResult = utils.yabaiSync("-m query --windows --space " .. currentSpace)
	local yabaiWindows = {}
	
	if yabaiResult and yabaiResult ~= "" then
		local jqResult = hs.execute(string.format("jq 'sort_by(.\"stack-index\",.app,.title)' <<< '%s'", yabaiResult))
		
		if jqResult and jqResult ~= "" then
			yabaiWindows = hs.json.decode(jqResult)
		end
	end

	local windows = {}
	
	for _, yabaiWin in ipairs(yabaiWindows) do
		-- Skip minimized and hidden windows
		if yabaiWin["subrole"] == "AXStandardWindow" and yabaiWin["is-minimized"] == false and yabaiWin["is-hidden"] == false then
			table.insert(windows, yabaiWin)
		end
	end

	return windows
end

function switchToWindow(index)
	local winData = switcher.windows[index]

	if winData then
		utils.yabai(string.format("-m window --focus %s", winData.id))
	end

	M.switchMode:exit()
end

-- Navigate to next window
local function nextWindow()
	if #switcher.windows == 0 then
		return
	end

	switcher.currentIndex = switcher.currentIndex + 1
	if switcher.currentIndex > #switcher.windows then
		switcher.currentIndex = 1
	end

	switchToWindow(switcher.currentIndex)
end

-- Navigate to previous window
local function previousWindow()
	if #switcher.windows == 0 then
		return
	end

	switcher.currentIndex = switcher.currentIndex - 1
	if switcher.currentIndex < 1 then
		switcher.currentIndex = #switcher.windows
	end

	switchToWindow(switcher.currentIndex)
end

--- Bind HYPER + W to enter window switcher mode
--- Keys 1+9 to switch to specific windows

M.switchMode = hs.hotkey.modal.new(utils.HYPER, "w")

function M.switchMode:entered()
	switcher.windows = getWindowsInCurrentSpace()
	hs.alert.show("Window", { textSize = 20 }, 999)
end

function M.switchMode:exited()
	hs.alert.closeAll()
end

M.switchMode:bind({}, "escape", function()
	M.switchMode:exit()
end)

M.switchMode:bind({}, "1", function()
	switchToWindow(1)
	M.switchMode:exit()
end)

M.switchMode:bind({}, "2", function()
	switchToWindow(2)
	M.switchMode:exit()
end)

M.switchMode:bind({}, "3", function()
	switchToWindow(3)
	M.switchMode:exit()
end)

M.switchMode:bind({}, "4", function()
	switchToWindow(4)
	M.switchMode:exit()
end)

M.switchMode:bind({}, "5", function()
	switchToWindow(5)
	M.switchMode:exit()
end)

M.switchMode:bind({}, "6", function()
	switchToWindow(6)
	M.switchMode:exit()
end)

M.switchMode:bind({}, "7", function()
	switchToWindow(7)
	M.switchMode:exit()
end)

M.switchMode:bind({}, "8", function()
	switchToWindow(8)
	M.switchMode:exit()
end)

M.switchMode:bind({}, "9", function()
	switchToWindow(9)
	M.switchMode:exit()
end)