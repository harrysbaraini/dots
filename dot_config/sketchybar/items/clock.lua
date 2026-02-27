-- items/clock.lua
-- Clock item on the right: shows time in HH:MM AM/PM format, updates every second.

local colors   = require("colors")
local settings = require("settings")

local clock = sbar.add("item", {
  position = "right",
  padding_left  = 8,
  padding_right = 12,
  update_freq   = 10,   -- poll every 10s (we also subscribe to "routine" below)
  updates       = true,
  icon = {
    string        = "󰥔",
    font          = { family = settings.font, style = "Bold", size = 15.0 },
    color         = colors.old_white,
    padding_left  = 8,
    padding_right = 6,
  },
  label = {
    font          = { family = settings.font, style = "SemiBold", size = 13.0 },
    color         = colors.fg_primary,
    padding_left  = 2,
    padding_right = 8,
  },
  background = {
    color         = colors.transparent,
    border_width  = 0,
  },
})

local function update_clock()
  sbar.exec("date '+%I:%M %p'", function(time)
    clock:set({ label = { string = time:gsub("%s+$", "") } })
  end)
end

-- Update on routine tick and on initial load
update_clock()
clock:subscribe("routine",         function(_) update_clock() end)
clock:subscribe("system_woke",     function(_) update_clock() end)

return clock
