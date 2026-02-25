local utils = require("utils")

local M = {}

-- Helper to query yabai and get JSON output
local function queryYabai(args)
	local yabai_path = "/opt/homebrew/bin/yabai"
	local handle = io.popen(yabai_path .. " " .. args)
	local result = handle:read("*a")
	handle:close()

	if result and result ~= "" then
		return hs.json.decode(result)
	end
	return nil
end

-- Configuration
local SWITCHER_WIDTH = 600
local SWITCHER_HEIGHT = 400
local SWITCHER_PADDING = 20
local ITEM_HEIGHT = 60
local FONT_SIZE = 16
local ICON_SIZE = 48

-- State
local switcher = {
	windows = {},
	currentIndex = 1,
	canvas = nil,
	modal = nil,
	isActive = false,
	modifierWatcher = nil,
}

-- Get current yabai space
local function getCurrentSpace()
	local json = queryYabai("-m query --spaces --space")
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
	local yabaiWindows = queryYabai("-m query --windows --space " .. currentSpace) or {}

	-- Get Hammerspoon windows and match with yabai data
	local windows = {}
	local allHSWindows = hs.window.orderedWindows()

	for _, yabaiWin in ipairs(yabaiWindows) do
		-- Skip minimized and hidden windows
		if yabaiWin["is-minimized"] == false and yabaiWin["is-hidden"] == false then
			-- Find matching Hammerspoon window by title and app
			for _, hsWin in ipairs(allHSWindows) do
				if hsWin:isStandard() and hsWin:title() == yabaiWin.title then
					local app = hsWin:application()
					if app and app:name() == yabaiWin.app then
						table.insert(windows, {
							hsWindow = hsWin,
							yabaiWindow = yabaiWin,
							title = yabaiWin.title,
							app = yabaiWin.app,
						})
						break
					end
				end
			end
		end
	end

	return windows
end

-- Draw the switcher UI
local function drawSwitcher()
	if not switcher.canvas then
		return
	end

	-- Clear all previous canvas elements
	for i = #switcher.canvas, 1, -1 do
		switcher.canvas[i] = nil
	end

	local screen = hs.screen.mainScreen()
	local screenFrame = screen:frame()
	local x = (screenFrame.w - SWITCHER_WIDTH) / 2
	local y = (screenFrame.h - SWITCHER_HEIGHT) / 2

	switcher.canvas:frame({
		x = x,
		y = y,
		w = SWITCHER_WIDTH,
		h = SWITCHER_HEIGHT,
	})

	switcher.canvas[1] = {
		type = "rectangle",
		action = "fill",
		fillColor = { red = 0.1, green = 0.1, blue = 0.1, alpha = 0.95 },
		roundedRectRadii = { xRadius = 10, yRadius = 10 },
	}

	-- Draw windows
	local visibleItems = math.floor((SWITCHER_HEIGHT - SWITCHER_PADDING * 2) / ITEM_HEIGHT)
	local startIndex = math.max(1, switcher.currentIndex - math.floor(visibleItems / 2))
	local endIndex = math.min(#switcher.windows, startIndex + visibleItems - 1)

	local currentY = SWITCHER_PADDING
	local canvasIndex = 2

	for i = startIndex, endIndex do
		local win = switcher.windows[i]
		local isSelected = i == switcher.currentIndex

		-- Background for selected item
		if isSelected then
			switcher.canvas[canvasIndex] = {
				type = "rectangle",
				action = "fill",
				fillColor = { red = 0.3, green = 0.5, blue = 0.8, alpha = 0.5 },
				roundedRectRadii = { xRadius = 5, yRadius = 5 },
				frame = {
					x = SWITCHER_PADDING,
					y = currentY,
					w = SWITCHER_WIDTH - SWITCHER_PADDING * 2,
					h = ITEM_HEIGHT,
				},
			}
			canvasIndex = canvasIndex + 1
		end

		-- App icon
		local app = win.hsWindow:application()
		if app then
			local bundleID = app:bundleID()
			if bundleID then
				local icon = hs.image.imageFromAppBundle(bundleID)
				if icon then
					switcher.canvas[canvasIndex] = {
						type = "image",
						image = icon,
						frame = {
							x = SWITCHER_PADDING + 10,
							y = currentY + (ITEM_HEIGHT - ICON_SIZE) / 2,
							w = ICON_SIZE,
							h = ICON_SIZE,
						},
					}
					canvasIndex = canvasIndex + 1
				end
			end
		end

		-- App name
		switcher.canvas[canvasIndex] = {
			type = "text",
			text = win.app,
			textColor = { red = 1, green = 1, blue = 1, alpha = 1 },
			textSize = FONT_SIZE,
			textFont = "Helvetica Bold",
			frame = {
				x = SWITCHER_PADDING + 10 + ICON_SIZE + 10,
				y = currentY + 8,
				w = SWITCHER_WIDTH - SWITCHER_PADDING * 2 - ICON_SIZE - 30,
				h = 20,
			},
		}
		canvasIndex = canvasIndex + 1

		-- Window title
		local title = win.title
		if #title > 50 then
			title = title:sub(1, 47) .. "..."
		end

		switcher.canvas[canvasIndex] = {
			type = "text",
			text = title,
			textColor = { red = 0.7, green = 0.7, blue = 0.7, alpha = 1 },
			textSize = FONT_SIZE - 2,
			textFont = "Helvetica",
			frame = {
				x = SWITCHER_PADDING + 10 + ICON_SIZE + 10,
				y = currentY + 30,
				w = SWITCHER_WIDTH - SWITCHER_PADDING * 2 - ICON_SIZE - 30,
				h = 20,
			},
		}
		canvasIndex = canvasIndex + 1

		currentY = currentY + ITEM_HEIGHT
	end
end

-- Forward declarations
local hideSwitcher

-- Setup modifier key watcher to detect Ctrl/Cmd release
local function setupModifierWatcher()
	if switcher.modifierWatcher then
		switcher.modifierWatcher:stop()
	end

	-- Check current modifier state immediately
	local currentFlags = hs.eventtap.checkKeyboardModifiers()
	if not currentFlags.ctrl or not currentFlags.cmd then
		-- Keys already released, close immediately
		hideSwitcher(true)
		return
	end

	switcher.modifierWatcher = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(event)
		if not switcher.isActive then
			return false
		end

		local flags = event:getFlags()
		-- If either ctrl or cmd is released, close switcher and focus
		if not flags.ctrl or not flags.cmd then
			hideSwitcher(true)
			if switcher.modifierWatcher then
				switcher.modifierWatcher:stop()
			end
			return true
		end
		return false
	end)

	switcher.modifierWatcher:start()
end

-- Show the switcher
local function showSwitcher()
	switcher.windows = getWindowsInCurrentSpace()

	if #switcher.windows == 0 then
		hs.alert.show("No windows in current space")
		return
	end

	-- Find the current focused window and set index
	local focusedWindow = hs.window.focusedWindow()
	switcher.currentIndex = 1

	for i, win in ipairs(switcher.windows) do
		if focusedWindow and win.hsWindow:id() == focusedWindow:id() then
			-- Start at next window (like CMD+Tab behavior)
			switcher.currentIndex = (i % #switcher.windows) + 1
			break
		end
	end

	-- Create canvas if needed
	if not switcher.canvas then
		switcher.canvas = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })
	end

	switcher.isActive = true
	drawSwitcher()
	switcher.canvas:show()
	switcher.modal:enter()
	setupModifierWatcher()
end

-- Hide the switcher
hideSwitcher = function(focusWindow)
	-- Guard against double-hiding
	if not switcher.isActive then
		return
	end

	-- Set inactive immediately to prevent race conditions
	switcher.isActive = false

	if switcher.modifierWatcher then
		switcher.modifierWatcher:stop()
		switcher.modifierWatcher = nil
	end

	if switcher.canvas then
		switcher.canvas:hide()
	end

	if switcher.modal then
		switcher.modal:exit()
	end

	if focusWindow and switcher.windows and switcher.windows[switcher.currentIndex] then
		local win = switcher.windows[switcher.currentIndex].hsWindow
		if win then
			win:focus()
		end
	end
end

-- Navigate to next window
local function nextWindow()
	if not switcher.isActive or #switcher.windows == 0 then
		return
	end

	switcher.currentIndex = switcher.currentIndex + 1
	if switcher.currentIndex > #switcher.windows then
		switcher.currentIndex = 1
	end

	drawSwitcher()
end

-- Navigate to previous window
local function previousWindow()
	if not switcher.isActive or #switcher.windows == 0 then
		return
	end

	switcher.currentIndex = switcher.currentIndex - 1
	if switcher.currentIndex < 1 then
		switcher.currentIndex = #switcher.windows
	end

	drawSwitcher()
end

-- Setup modal and hotkeys
local function setup()
	-- Create modal
	switcher.modal = hs.hotkey.modal.new()

	-- Tab to cycle forward
	switcher.modal:bind({}, "tab", function()
		nextWindow()
	end)

	-- HYPER+Tab to cycle forward (when switcher is already open)
	switcher.modal:bind(utils.HYPER, "tab", function()
		nextWindow()
	end)

	-- Shift+Tab to cycle backward
	switcher.modal:bind({ "shift" }, "tab", function()
		previousWindow()
	end)

	-- Escape to cancel
	switcher.modal:bind({}, "escape", function()
		hideSwitcher(false)
	end)

	-- HYPER+Tab to trigger switcher (Karabiner maps CMD+Tab to this)
	hs.hotkey.bind(utils.HYPER, "tab", function()
		showSwitcher()
	end)
end

-- Initialize the module
setup()

return M
