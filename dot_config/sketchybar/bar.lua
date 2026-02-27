local colors   = require("colors")
local settings = require("settings")

sbar.bar({
  position      = "top",
  height        = settings.bar.height,
  color         = colors.bg_base,
  border_color  = colors.with_alpha(colors.bg_base, 0.16),
  border_width  = settings.bar.border_width,
  shadow        = false,
  sticky        = true,
  margin        = settings.bar.margin,
  padding_left  = 4,
  padding_right = 4,
  corner_radius = settings.bar.corner_radius,
  blur_radius   = settings.bar.blur_radius,
  y_offset      = settings.bar.y_offset,
  topmost       = "window",
  -- Notch handling for MacBook Pro
  notch_width   = 200,
  notch_offset  = 0,
})