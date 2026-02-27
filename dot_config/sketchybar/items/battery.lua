-- items/battery.lua
-- Battery indicator on the right: shows percentage and charging state icon.

local colors   = require("colors")
local settings = require("settings")

local battery = sbar.add("item", {
  position = "right",
  padding_left  = 8,
  padding_right = 12,
  update_freq   = 60,
  updates       = true,
  icon = {
    font          = { family = settings.font, style = "Bold", size = 15.0 },
    color         = colors.spring_green,
    padding_left  = 8,
    padding_right = 6,
  },
  label = {
    font          = { family = settings.font, style = "Medium", size = 13.0 },
    color         = colors.fg_secondary,
    padding_left  = 2,
    padding_right = 8,
  },
  background = {
    color        = colors.transparent,
    border_width = 0,
  },
})

local function update_battery()
  sbar.exec("pmset -g batt", function(output)
    local pct      = tonumber(output:match("(%d+)%%")) or 0
    local charging = output:find("AC Power") ~= nil

    local icon
    if charging then
      icon = "󰂄"
    elseif pct >= 90 then icon = "󰁹"
    elseif pct >= 60 then icon = "󰁾"
    elseif pct >= 30 then icon = "󰁼"
    elseif pct >= 10 then icon = "󰁻"
    else              icon = "󰁺"
    end

    -- Change icon colour when low
    local icon_color = colors.spring_green
    if not charging and pct <= 20 then
      icon_color = colors.autumn_red
    elseif not charging and pct <= 40 then
      icon_color = colors.autumn_yellow
    end

    battery:set({
      icon  = { string = icon, color = icon_color },
      label = { string = pct .. "%" },
    })
  end)
end

update_battery()
battery:subscribe("routine",            function(_) update_battery() end)
battery:subscribe("system_woke",        function(_) update_battery() end)
battery:subscribe("power_source_change", function(_) update_battery() end)

return battery
