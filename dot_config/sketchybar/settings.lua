-- SketchyBar settings / design tokens

local settings = {
  font        = "JetBrainsMono Nerd Font",
  app_font    = "sketchybar-app-font",

  bar = {
    height        = 32,
    corner_radius = 10,
    border_width  = 1,
    blur_radius   = 8,
    y_offset      = 2,
    margin        = 2,
  },

  item = {
    corner_radius = 8,
    height        = 26,
    border_width  = 1,
  },

  paddings      = 6,   -- default icon/label side padding
  group_padding = 4,   -- padding inside bracket groups

  -- Workspace pill display
  workspaces = {
    ids    = { "1", "2", "3", "4", "5", "6" },
    labels = { "VSA", "VLM", "JUI", "MSW", "KDG", "XYZ" },
    icons = { "", "", "", "", "", "󰂓", "󰎶", "󰎹", "󰎼", "󰎡" },
  },

  -- Window title truncation length (chars before "…")
  title_max_chars = 16,
}

return settings
