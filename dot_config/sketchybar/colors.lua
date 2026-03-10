-- Islands Relax Dark Coffee color palette (matched from WezTerm theme)
-- All colors are 0xAARRGGBB format

local colors = {
  -- Base surfaces
  bg_base    = 0xed2c2122, -- Deep background (ed = ~93% opaque)
  bg_surface = 0xd03c3031, -- Surface layer (d0 = ~82% opaque)
  bg_overlay = 0xff6e4552, -- Overlay/highlight (selection)

  -- Accent colors
  wave_blue     = 0xff5da3f4,
  spring_violet = 0xffbd93f9,
  autumn_red    = 0xffff5554,
  wave_aqua     = 0xff8be9fd,
  spring_green  = 0xff2fc864,
  autumn_yellow = 0xffdbab4a,
  sakura_pink   = 0xffff79c6,
  old_white     = 0xffddd5d4,

  -- Text
  fg_primary   = 0xffbbbbbb,
  fg_secondary = 0xff858994,
  fg_dim       = 0xff554849,

  -- Transparent
  transparent  = 0x00000000,

  -- Module backgrounds / borders (with alpha baked in)
  module_bg     = 0xd03c3031, -- d0 alpha on bg_surface
  module_border = 0x40dbab4a, -- 40 alpha on autumn_yellow (gold accent)

  -- Workspace accent colors (one per slot, cycling)
  workspace_accents = {
    0xffbd93f9, -- 1: purple
    0xff2fc864, -- 2: green
    0xffdbab4a, -- 3: gold
    0xff8be9fd, -- 4: cyan
    0xff5da3f4, -- 5: blue
    0xffa96f79, -- 6: rose
  },

  -- Blend alpha (0.0–1.0) into a 0xAARRGGBB color
  with_alpha = function(color, alpha)
    if alpha == nil or alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}

return colors
