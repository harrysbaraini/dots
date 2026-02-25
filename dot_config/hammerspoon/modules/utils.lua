local M = {}

M.HYPER = { "shift", "ctrl", "cmd", "option" }

function M.yabaiSync(args)
	local yabai_path = "/opt/homebrew/bin/yabai"
	local output, status, _, stderr = hs.execute(yabai_path .. " " .. args)

	if not status then
		print("Yabai Error: " .. stderr)
		return nil
	end

	return output
end

function M.yabai(args)
	local yabai_path = "/opt/homebrew/bin/yabai"
	hs.task
		.new(yabai_path, nil, function(err, stdout, stderr)
			if err ~= 0 then
				print("Yabai Error: " .. stderr)
			end
		end, hs.fnutils.split(args, " "))
		:start()
end

return M
