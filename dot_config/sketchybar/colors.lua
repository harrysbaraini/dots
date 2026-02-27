-- Kanagawa Wave color palette (ported from variables.sh)
-- All colors are 0xAARRGGBB format

local colors = {
  -- Base surfaces
  bg_base    = 0xed1f1f28, -- Deep background (ed = ~93% opaque)
  bg_surface = 0xd02a2a37, -- Surface layer (d0 = ~82% opaque)
  bg_overlay = 0xff363646, -- Overlay/highlight

  -- Accent colors
  wave_blue     = 0xff7e9cd8,
  spring_violet = 0xff957fb8,
  autumn_red    = 0xffc34043,
  wave_aqua     = 0xff7fb4ca,
  spring_green  = 0xff98bb6c,
  autumn_yellow = 0xffc0a36e,
  sakura_pink   = 0xffe6c384,
  old_white     = 0xffdcd7ba,

  -- Text
  fg_primary   = 0xffdcd7ba,
  fg_secondary = 0xffc8c093,
  fg_dim       = 0xff727169,

  -- Transparent
  transparent  = 0x00000000,

  -- Module backgrounds / borders (with alpha baked in)
  module_bg     = 0xd02a2a37, -- d0 alpha on bg_surface
  module_border = 0x407e9cd8, -- 40 alpha on wave_blue

  -- Workspace accent colors (one per slot, cycling)
  workspace_accents = {
    0xff957fb8, -- 1 VSA: spring_violet
    0xff98bb6c, -- 2 VLM: spring_green
    0xffe6c384, -- 3 JUI: sakura_pink
    0xff7fb4ca, -- 4 MSW: wave_aqua
    0xff7e9cd8, -- 5 KDG: wave_blue
    0xffc0a36e, -- 6 XYZ: autumn_yellow
  },

  -- Blend alpha (0.0–1.0) into a 0xAARRGGBB color
  with_alpha = function(color, alpha)
    if alpha == nil or alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}

return colors
