-- Bridges PaperWM state to SketchyBar.
--
-- Writes focused-workspace/window info to /tmp/paperwm-sketchybar.json and
-- triggers the `paperwm_workspace_change` custom event on sketchybar whenever
-- the focused space, focused window, or window list changes. Also registers
-- `hammerspoon://paperwm-switch-space` and `hammerspoon://paperwm-focus-window`
-- URL handlers so sketchybar click scripts can invoke PaperWM actions.

local Spaces <const> = hs.spaces
local Screen <const> = hs.screen
local Window <const> = hs.window
local Timer <const> = hs.timer
local WindowFilter <const> = hs.window.filter

local M = {}

local SKETCHYBAR = "/opt/homebrew/bin/sketchybar"
local STATE_FILE = "/tmp/paperwm-sketchybar.json"
local DEBOUNCE_SECONDS = 0.1

local prev_focused_workspace = 0

local function run_sketchybar(args)
	hs.task.new(SKETCHYBAR, nil, args):start()
end

local function workspace_index_for_space(space_id)
	if not space_id then
		return 0
	end
	local layout = Spaces.allSpaces()
	local idx = 0
	for _, screen in ipairs(Screen.allScreens()) do
		local uuid = screen:getUUID()
		for _, id in ipairs(layout[uuid] or {}) do
			idx = idx + 1
			if id == space_id then
				return idx
			end
		end
	end
	return 0
end

local function windows_in_space(space_id)
	local list = {}
	if not space_id or not PaperWM or not PaperWM.state then
		return list
	end
	local columns = PaperWM.state.windowList(space_id)
	if not columns then
		return list
	end
	for _, column in ipairs(columns) do
		for _, win in ipairs(column) do
			local id = win and win.id and win:id()
			if id then
				local app = win:application()
				table.insert(list, {
					id = id,
					app = (app and app:name()) or "",
					title = win:title() or "",
				})
			end
		end
	end
	return list
end

local function compute_state()
	local focused_space = Spaces.focusedSpace()
	local focused_win = Window.focusedWindow()
	return {
		focused_space = workspace_index_for_space(focused_space),
		focused_window = (focused_win and focused_win:id()) or 0,
		windows = windows_in_space(focused_space),
	}
end

local function push_state()
	local state = compute_state()
	local encoded = hs.json.encode(state) or "{}"

	local f = io.open(STATE_FILE, "w")
	if f then
		f:write(encoded)
		f:close()
	end

	run_sketchybar({
		"--trigger",
		"paperwm_workspace_change",
		"FOCUSED_WORKSPACE=" .. tostring(state.focused_space),
		"PREV_WORKSPACE=" .. tostring(prev_focused_workspace),
		"FOCUSED_WINDOW=" .. tostring(state.focused_window),
	})

	prev_focused_workspace = state.focused_space
end

local pending_timer = nil
local function schedule_push()
	if pending_timer then
		pending_timer:stop()
	end
	pending_timer = Timer.doAfter(DEBOUNCE_SECONDS, function()
		pending_timer = nil
		push_state()
	end)
end

M.space_watcher = Spaces.watcher.new(function()
	schedule_push()
end)
M.space_watcher:start()

M.window_filter = WindowFilter.new()
M.window_filter:subscribe({
	WindowFilter.windowCreated,
	WindowFilter.windowDestroyed,
	WindowFilter.windowFocused,
	WindowFilter.windowTitleChanged,
	WindowFilter.windowVisible,
	WindowFilter.windowNotVisible,
}, function()
	schedule_push()
end)

hs.urlevent.bind("paperwm-switch-space", function(_, params)
	local idx = tonumber(params and params.index)
	if idx and PaperWM and PaperWM.space then
		PaperWM.space.switchToSpace(idx)
	end
end)

hs.urlevent.bind("paperwm-focus-window", function(_, params)
	local id = tonumber(params and params.id)
	local win = id and Window.get(id)
	if win then
		win:focus()
	end
end)

-- Delay first push so PaperWM.refreshWindows has populated state.
Timer.doAfter(1.0, push_state)

return M
