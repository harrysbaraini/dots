-- Yabai Window Manager Integration for Hammerspoon
-- Author: Vanderlei Sbaraini
-- Keymap:
-- HYPER + S: Space mode
-- HYPER + (h / j / k / l): Window Navigation mode
-- HYPER + M: Window Move mode
-- HYPER + R: Window Resize mode
-- HYPER + X: Toggle window float
-- HYPER + Z: Toggle window zoom
-- HYPER + G: Grid layout
-- HYPER + F: Stack layout

local utils = require("utils")

-- Space labels

local spaces = {
	["1"] = "VSA",
	["2"] = "VLM",
	["3"] = "JUI",
	["4"] = "MSW",
	["5"] = "KDG",
	["6"] = "XYZ",
}

-----------------------------------------------------
-- Space Mode
-- HYPER + S + [Number] to focus space
-- HYPER + Shift + [Number] to move window to space
-----------------------------------------------------

local spaceMode = hs.hotkey.modal.new(utils.HYPER, "s")

function spaceMode:entered()
	hs.alert.show("Space", { textSize = 20 }, 999)
end

function spaceMode:exited()
	hs.alert.closeAll()
end

spaceMode:bind({}, "escape", function()
	spaceMode:exit()
end)

local resizeStep = 20

for key, label in pairs(spaces) do
	-- Focus on space - HYPER + [Number]
	spaceMode:bind({}, key, nil, function()
		utils.yabai("-m space --focus " .. label)
		spaceMode:exit()
	end)

	-- HYPER + Shift + [Number]
	spaceMode:bind({ "shift" }, key, nil, function()
		utils.yabai("-m window --space " .. label)
		utils.yabai("-m space --focus " .. label)

		spaceMode:exit()
	end)
end

-----------------------------------------------------
-- Window Navigation Mode
-----------------------------------------------------

-- Navigate windows - HYPER + (h, j, k, l)

hs.hotkey.bind(utils.HYPER, "h", function()
	utils.yabai("-m window --focus stack.prev")
	utils.yabai("-m window --focus west")
end)

hs.hotkey.bind(utils.HYPER, "j", function()
	utils.yabai("-m window --focus stack.next")
	utils.yabai("-m window --focus south")
end)

hs.hotkey.bind(utils.HYPER, "k", function()
	utils.yabai("-m window --focus stack.prev")
	utils.yabai("-m window --focus north")
end)

hs.hotkey.bind(utils.HYPER, "l", function()
	utils.yabai("-m window --focus stack.next")
	utils.yabai("-m window --focus east")
end)

--- Toggle float
hs.hotkey.bind(utils.HYPER, "x", function()
	utils.yabai("-m window --toggle float")
	utils.yabai("-m window --grid 6:6:1:1:4:4")
end)

-- Toggle zoom
hs.hotkey.bind(utils.HYPER, "z", function()
	utils.yabai("-m window --toggle zoom-parent")
end)

--- Grid layout
hs.hotkey.bind(utils.HYPER, "g", function()
	utils.yabai("-m space --layout bsp")
end)

--- Stack layout
hs.hotkey.bind(utils.HYPER, "f", function()
	utils.yabai("-m space --layout stack")
end)

-----------------------------------------------------
-- Move Window Mode - HYPER + M + (h, j, k, l)
-----------------------------------------------------

local moveMode = hs.hotkey.modal.new(utils.HYPER, "m")

function moveMode:entered()
	hs.alert.show("Move", { textSize = 20 }, 999)
end

function moveMode:exited()
	hs.alert.closeAll()
end

moveMode:bind({}, "escape", function()
	moveMode:exit()
end)

moveMode:bind({}, "h", function()
	utils.yabai("-m window --swap west")
end)

moveMode:bind({}, "j", function()
	utils.yabai("-m window --swap south")
end)

moveMode:bind({}, "k", function()
	utils.yabai("-m window --swap north")
end)

moveMode:bind({}, "l", function()
	utils.yabai("-m window --swap east")
end)

-----------------------------------------------------
-- Window Resizing Mode - HYPER + R + (h, j, k, l)
-----------------------------------------------------

local resizeMode = hs.hotkey.modal.new(utils.HYPER, "r")

function resizeMode:entered()
	hs.alert.show("Resize", { textSize = 20 }, 999)
end

function resizeMode:exited()
	hs.alert.closeAll()
end

resizeMode:bind({}, "escape", function()
	resizeMode:exit()
end)

resizeMode:bind({}, "h", nil, function()
	utils.yabai("-m window --resize right:-" .. resizeStep .. ":0")
	utils.yabai("-m window --resize left:-" .. resizeStep .. ":0")
end)

resizeMode:bind({}, "j", nil, function()
	utils.yabai("-m window --resize bottom:0:" .. resizeStep)
	utils.yabai("-m window --resize top:0:" .. resizeStep)
end)

resizeMode:bind({}, "k", nil, function()
	utils.yabai("-m window --resize bottom:0:-" .. resizeStep)
	utils.yabai("-m window --resize top:0:-" .. resizeStep)
end)

resizeMode:bind({}, "l", nil, function()
	utils.yabai("-m window --resize right:" .. resizeStep .. ":0")
	utils.yabai("-m window --resize left:" .. resizeStep .. ":0")
end)
