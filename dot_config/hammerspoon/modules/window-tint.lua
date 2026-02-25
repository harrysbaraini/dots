local wf = hs.window.filter.new()
local overlays = {}
local pending = false

local function clearOverlays()
	for _, drawing in pairs(overlays) do
		drawing:delete()
	end
	overlays = {}
end

local function tintInactiveWindows()
	pending = false
	clearOverlays()

	local focused = hs.window.focusedWindow()
	if not focused then
		return
	end

	for _, win in ipairs(hs.window.visibleWindows()) do
		if win ~= focused and win:isStandard() then
			local f = win:frame()
			local c = hs.canvas.new(f)
			c[1] = {
				type = "rectangle",
				action = "fill",
				fillColor = { red = 0, green = 0, blue = 0, alpha = 0.45 },
			}

			c:level(hs.canvas.windowLevels.overlay)
			-- c:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
			c:clickActivating(false)
			c:show()

			overlays[win:id()] = c
		end
	end
end

local function scheduleTint()
	if pending then
		return
	end
	pending = true
	hs.timer.doAfter(0.03, tintInactiveWindows) -- 30ms debounce
end

wf:subscribe({
	hs.window.filter.windowFocused,
	hs.window.filter.windowUnfocused,
	hs.window.filter.windowMoved,
	hs.window.filter.windowDestroyed,
}, scheduleTint)

hs.timer.doAfter(0.5, tintInactiveWindows)
