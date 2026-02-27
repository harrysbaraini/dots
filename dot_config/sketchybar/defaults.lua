local colors   = require("colors")
local settings = require("settings")

-- Global defaults
sbar.default({
  updates = true,
  padding_left  = 4,
  padding_right = 4,
  icon = {
    font = {
      family = settings.font,
      style  = "Bold",
      size   = 15.0,
    },
    color         = colors.wave_blue,
    padding_left  = settings.paddings,
    padding_right = settings.paddings,
  },
  label = {
    font = {
      family = settings.font,
      style  = "Medium",
      size   = 13.0,
    },
    color         = colors.fg_primary,
    padding_left  = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    height        = settings.item.height,
    corner_radius = settings.item.corner_radius,
    border_width  = settings.item.border_width,
    drawing       = false,
  },
})


-- Custom events
sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "aerospace_mode_change")