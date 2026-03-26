-- dark-mode-watcher.lua
-- Watches for macOS dark/light mode changes and flips theme symlinks.
-- Instant switching — no chezmoi apply needed.

local M = {}

local function switchTheme()
	hs.task.new("/bin/bash", function(exitCode, stdOut, stdErr)
		if exitCode == 0 then
			hs.alert.show("Theme updated", 0.5)
		else
			hs.alert.show("Theme update failed", 1)
			print("theme-reload failed: " .. (stdErr or ""))
		end
	end, { os.getenv("HOME") .. "/.config/theme-reload.sh" }):start()
end

M.watcher = hs.distributednotifications.new(function(name, object, userInfo)
	-- Small delay to let macOS finish the transition
	hs.timer.doAfter(0.5, switchTheme)
end, "AppleInterfaceThemeChangedNotification")

M.watcher:start()

return M
