local utils = require("utils")


local M = {}

local function chooseWindow()
	local aerospaceWindows = hs.json.decode(utils.aerospace("list-windows --workspace focused --json") or "[]")
	local focusedWin = hs.window.focusedWindow()
	local choices = {}

	for _, win in ipairs(aerospaceWindows) do
		local hsWin = hs.window.get(win["window-id"])
	
		if hsWin and hsWin:isStandard() and hsWin ~= focusedWin then
			local app = hsWin:application()
			local image = nil

			if app then
				local bundleID = app:bundleID()
				image = hs.image.imageFromAppBundle(bundleID)
			end

			table.insert(choices, {
				text = win["app-name"],
				subText = win["window-title"],				
				image = image,
				window = hsWin,
			})
		end
	end

	local chooser = hs.chooser.new(function(choice)
		if choice and choice.window then
			choice.window:focus()
		end
	end)

	chooser:choices(choices)
	chooser:show()
end

hs.hotkey.bind(utils.HYPER, "tab", function()
	chooseWindow()
end)

return M