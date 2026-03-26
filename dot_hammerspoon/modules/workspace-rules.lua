-- workspace-rules.lua
-- Automatically moves windows to the correct Aerospace workspace
-- based on app name and window title patterns.
-- Triggers on window creation, title change, and monitor changes.

local utils = require("utils")

local M = {}

-- Rules: each entry has { app = "App Name", pattern = "lua pattern" or nil, workspace = "N" }
-- Pattern is matched against the window title (case-insensitive). nil = match any window of that app.
-- Rules are evaluated top-to-bottom; first match wins.
local rules = {
	-- Brave Browser profiles (title ends with "- Brave - <Profile>")
	{ app = "Brave Browser", pattern = "brave %- personal",      workspace = "1" },
	{ app = "Brave Browser", pattern = "brave %- valley metro",   workspace = "2" },
	{ app = "Brave Browser", pattern = "brave %- juiced",         workspace = "3" },
	{ app = "Brave Browser", pattern = "brave %- kdg",            workspace = "4" },

	-- PhpStorm projects (title: "project-name – filename")
	{ app = "PhpStorm", pattern = "sirius",       workspace = "1" },
	{ app = "PhpStorm", pattern = "valleymetro",   workspace = "2" },
	{ app = "PhpStorm", pattern = "valley%-metro", workspace = "2" },
	{ app = "PhpStorm", pattern = "juiced",        workspace = "3" },
	{ app = "PhpStorm", pattern = "^jui%-",        workspace = "3" },

	-- WezTerm with Zellij sessions (title: "session-name | command")
	{ app = "WezTerm", pattern = "vans%-sirius",        workspace = "1" },
	{ app = "WezTerm", pattern = "work%-valleymetro",    workspace = "2" },
	{ app = "WezTerm", pattern = "work%-valley%-metro",  workspace = "2" },
	{ app = "WezTerm", pattern = "work%-juiced",         workspace = "3" },

	-- Always on workspace 4
	{ app = "Slack", pattern = nil, workspace = "4" },

	-- Sit-and-forget on workspace 5
	{ app = "Spotify", pattern = nil, workspace = "5" },
	{ app = "Claude",  pattern = nil, workspace = "5" },
}

-- Build a window-id → workspace cache from aerospace to avoid moving windows already in place
local function getWindowWorkspaces()
	local raw = utils.aerospace("list-windows --all --format '%{window-id} %{workspace}'")
	local map = {}
	if raw then
		for line in raw:gmatch("[^\n]+") do
			local id, ws = line:match("^(%d+)%s+(.+)$")
			if id then
				map[tonumber(id)] = ws
			end
		end
	end
	return map
end

-- Find the target workspace for a window, or nil if no rule matches
local function matchRule(appName, title)
	local titleLower = title:lower()
	for _, rule in ipairs(rules) do
		if rule.app == appName then
			if rule.pattern == nil or titleLower:find(rule.pattern) then
				return rule.workspace
			end
		end
	end
	return nil
end

-- Move a single window to its target workspace if needed
local function placeWindow(win)
	if not win or not win:isStandard() then return end

	local app = win:application()
	if not app then return end

	local appName = app:name()
	local title = win:title() or ""
	local targetWs = matchRule(appName, title)

	if not targetWs then return end

	local winId = win:id()
	local currentMap = getWindowWorkspaces()
	local currentWs = currentMap[winId]

	if currentWs == targetWs then return end

	utils.aerospace(string.format("move-node-to-workspace --window-id %d %s", winId, targetWs))
	print(string.format("[workspace-rules] Moved %s (%s) → workspace %s", appName, title:sub(1, 40), targetWs))
end

-- Re-evaluate all windows (used on screen change)
local function placeAllWindows()
	print("[workspace-rules] Re-evaluating all windows (screen change)")
	local allWindows = hs.window.allWindows()
	for _, win in ipairs(allWindows) do
		placeWindow(win)
	end
end

-- Collect unique app names from rules for targeted filtering
local watchedApps = {}
local seen = {}
for _, rule in ipairs(rules) do
	if not seen[rule.app] then
		seen[rule.app] = true
		table.insert(watchedApps, rule.app)
	end
end

-- Create a window filter for all watched apps
local wf = hs.window.filter.new(watchedApps)
wf:subscribe(hs.window.filter.windowCreated, function(win)
	-- Small delay to let the window title settle (especially Brave)
	hs.timer.doAfter(0.5, function()
		placeWindow(win)
	end)
end)
wf:subscribe(hs.window.filter.windowTitleChanged, placeWindow)

-- Watch for screen/monitor changes (plug/unplug)
M.screenWatcher = hs.screen.watcher.new(function()
	-- Delay to let macOS finish display arrangement
	hs.timer.doAfter(2, placeAllWindows)
end)
M.screenWatcher:start()

-- Export for manual triggering (e.g., from console: require("workspace-rules").placeAll())
M.placeAll = placeAllWindows
M.rules = rules

return M
