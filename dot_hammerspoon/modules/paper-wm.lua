-- NOTE: do not name this file `paperwm.lua`. macOS's case-insensitive filesystem
-- makes Hammerspoon's Spoon searcher resolve `require("paperwm")` to the
-- `PaperWM.spoon/init.lua` bundle, so your module file never executes.

local utils = require("utils")

local M = {}

PaperWM = hs.loadSpoon("PaperWM")
local actions = PaperWM.actions.actions()

PaperWM.default_width = 0.98
PaperWM.external_bar = { top = 28 }
PaperWM.window_gap = 4
PaperWM.window_ratios = { 0.25, 0.50, 0.75, 0.98 }

-- Warp the mouse cursor from the edge of one screen to the edge of another screen to simulate external monitors being placed side by side.
WarpMouse = hs.loadSpoon("WarpMouse")
WarpMouse.margin = 2
WarpMouse.reverseScreens = false
WarpMouse:start()

-- switch to a new focused window in tiled grid
hs.hotkey.bind(utils.HYPER, "h", actions.focus_left)
hs.hotkey.bind(utils.HYPER, "l", actions.focus_right)
hs.hotkey.bind(utils.HYPER, "k", actions.focus_up)
hs.hotkey.bind(utils.HYPER, "j", actions.focus_down)

-- focus the leftmost / rightmost window in the current space
hs.hotkey.bind(utils.HYPER, "home", actions.focus_window_first)
hs.hotkey.bind(utils.HYPER, "end", actions.focus_window_last)

-- position and resize focused window
hs.hotkey.bind(utils.HYPER, "c", actions.center_window)
hs.hotkey.bind(utils.HYPER, "f", actions.full_width)
hs.hotkey.bind(utils.HYPER, "r", actions.cycle_width)
hs.hotkey.bind(utils.HYPER, "e", actions.cycle_height)

-- increase/decrease width (HYPER already includes shift, so "=" produces "+")
hs.hotkey.bind(utils.HYPER, "=", actions.increase_width)
hs.hotkey.bind(utils.HYPER, "-", actions.decrease_width)

-- move focused window into / out of a column
hs.hotkey.bind(utils.HYPER, "]", actions.slurp_in)
hs.hotkey.bind(utils.HYPER, "[", actions.barf_out)

-- split screen focused window with left window
hs.hotkey.bind(utils.HYPER, "s", actions.split_screen)

-- move the focused window into / out of the tiling layer
hs.hotkey.bind(utils.HYPER, "x", actions.toggle_floating)

-- raise all floating windows on top of tiled windows
hs.hotkey.bind(utils.HYPER, "z", actions.focus_floating)

-- focus the first / second / etc window in the current space
hs.hotkey.bind(utils.HYPER, "1", actions.focus_window_1)
hs.hotkey.bind(utils.HYPER, "2", actions.focus_window_2)
hs.hotkey.bind(utils.HYPER, "3", actions.focus_window_3)
hs.hotkey.bind(utils.HYPER, "4", actions.focus_window_4)
hs.hotkey.bind(utils.HYPER, "5", actions.focus_window_5)
hs.hotkey.bind(utils.HYPER, "6", actions.focus_window_6)
hs.hotkey.bind(utils.HYPER, "7", actions.focus_window_7)
hs.hotkey.bind(utils.HYPER, "8", actions.focus_window_8)
hs.hotkey.bind(utils.HYPER, "9", actions.focus_window_9)

-- set to a table of modifier keys to enable window dragging, default is nil
PaperWM.drag_window = { "alt", "cmd" }

-- set to a table of modifier keys to enable window lifting, default is nil
PaperWM.lift_window = { "alt", "cmd", "ctrl" }

-- Remember the last focused window per Mission Control space, so switching
-- back to a space restores focus instead of jumping to the first window.
local lastFocusedIdBySpace = {}

local function rememberFocus(win)
	if not win then
		return
	end
	local id = win:id()
	if not id then
		return
	end
	local spaces = hs.spaces.windowSpaces(win)
	if spaces and spaces[1] then
		lastFocusedIdBySpace[spaces[1]] = id
	end
end

local focusWatcher = hs.window.filter.new()
focusWatcher:subscribe(hs.window.filter.windowFocused, function(win)
	rememberFocus(win)
end)

local function switchToSpace(index)
	-- Capture current focus before leaving the space, in case the last
	-- windowFocused event hasn't been delivered yet.
	rememberFocus(hs.window.focusedWindow())

	local space_id = PaperWM.space.MissionControl:getSpaceID(index)
	if not space_id then
		actions["switch_space_" .. index]()
		return
	end

	local remembered_id = lastFocusedIdBySpace[space_id]
	local remembered_win = remembered_id and hs.window.get(remembered_id) or nil

	if remembered_win then
		local wspaces = hs.spaces.windowSpaces(remembered_win)
		local on_space = false
		if wspaces then
			for _, s in ipairs(wspaces) do
				if s == space_id then
					on_space = true
					break
				end
			end
		end
		if not on_space then
			remembered_win = nil
		end
	end

	if remembered_win then
		PaperWM.space.MissionControl:focusSpace(space_id, remembered_win)
	else
		actions["switch_space_" .. index]()
	end
end

-- switch to a new Mission Control space
local switchToSpaceModal = hs.hotkey.modal.new(utils.HYPER, "space")

for i = 1, 9 do
	switchToSpaceModal:bind({}, tostring(i), nil, function()
		switchToSpace(i)
		switchToSpaceModal:exit()
	end)
end

switchToSpaceModal:bind({}, "escape", function()
	switchToSpaceModal:exit()
end)

----------------------------------------------
-- Move modal
----------------------------------------------
local moveToSpaceModal = hs.hotkey.modal.new(utils.HYPER, "m")

-- move focused window to a new space and tile
moveToSpaceModal:bind({}, "1", nil, actions.move_window_1)
moveToSpaceModal:bind({}, "2", nil, actions.move_window_2)
moveToSpaceModal:bind({}, "3", nil, actions.move_window_3)
moveToSpaceModal:bind({}, "4", nil, actions.move_window_4)
moveToSpaceModal:bind({}, "5", nil, actions.move_window_5)
moveToSpaceModal:bind({}, "6", nil, actions.move_window_6)
moveToSpaceModal:bind({}, "7", nil, actions.move_window_7)
moveToSpaceModal:bind({}, "8", nil, actions.move_window_8)
moveToSpaceModal:bind({}, "9", nil, actions.move_window_9)

-- move windows around in tiled grid
moveToSpaceModal:bind({}, "h", nil, actions.swap_left)
moveToSpaceModal:bind({}, "l", nil, actions.swap_right)
moveToSpaceModal:bind({}, "k", nil, actions.swap_up)
moveToSpaceModal:bind({}, "j", nil, actions.swap_down)

moveToSpaceModal:bind({}, "escape", function()
	moveToSpaceModal:exit()
end)

-- Start PaperWM
PaperWM:start()

return M
