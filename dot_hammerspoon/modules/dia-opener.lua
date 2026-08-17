local create_profile_wait_time = 500000 -- 0.5 seconds

local function createProfileWindow(app, existingWindows, profileKey)
	hs.eventtap.keyStroke({ "cmd" }, "n", 0, app)
	hs.timer.usleep(create_profile_wait_time)

	for _, win in ipairs(app:allWindows()) do
		if win:isStandard() and not existingWindows[win:id()] then
			win:focus()
			hs.eventtap.keyStroke({ "ctrl" }, profileKey, 0, app)
			break
		end
	end
end

local function openProfileWindow(app, profileName, profileKey)
	local existingWindows = {}
	local targetWindow = nil

	for _, win in ipairs(app:allWindows()) do
		if win:isStandard() then
			existingWindows[win:id()] = win
			local title = win:title()

			if string.sub(title, 1, #profileName) == profileName then
				targetWindow = win
				break
			end
		end
	end

	if targetWindow then
		print("Found existing window for profile: " .. profileName)
		targetWindow:focus()
	else
		print("Creating new window for profile: " .. profileName)
		createProfileWindow(app, existingWindows, profileKey)
	end
end

local Dia = {}

function Dia.openProfile(profileName, profileKey)
    local app = hs.application.get("Dia")

    if not app then
        print("Dia application is not running. Launching Dia...")
        hs.application.launchOrFocus("Dia")
    end

    while not app do
        hs.timer.usleep(500000)
        app = hs.application.get("Dia")
    end

    print("Dia application is running.")
    openProfileWindow(app, profileName, profileKey)
end

return Dia
