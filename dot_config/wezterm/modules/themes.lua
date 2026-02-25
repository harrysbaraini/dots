local wezterm = require("wezterm")

-- Color schemes to toggle between.
local light_scheme = 'GruvboxLight'
local dark_scheme = 'GruvboxDark'

-- Custom event to toggle color scheme. Fire it `config.keys`.
wezterm.on('toggle-color-scheme', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if overrides.color_scheme == light_scheme then
    overrides.color_scheme = dark_scheme
  else
    overrides.color_scheme = light_scheme
  end
  window:set_config_overrides(overrides)
end)