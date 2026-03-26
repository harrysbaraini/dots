local M = {}

M.HYPER = { "shift", "ctrl", "cmd", "option" }

function M.aerospace(args)
	local bin_path = "/opt/homebrew/bin/aerospace"
	local output, status, _, stderr = hs.execute(bin_path .. " " .. args)

	if not status then
		print("Aerospace Error: " .. stderr)
		return nil
	end

	return output
end


return M
