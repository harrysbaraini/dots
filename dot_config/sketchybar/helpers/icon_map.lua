-- helpers/icon_map.lua
-- Maps macOS app names (as reported by AeroSpace) to sketchybar-app-font ligature strings.
-- The font renders these string values as icons when icon.font = "sketchybar-app-font:Regular:XX"
-- Fallback returns a generic app icon character.

local icon_map = {}

-- Map: app display name (case-insensitive) → ligature string for sketchybar-app-font
local map = {
  ["default"]           = "default",  

  -- Terminals
  ["wezterm"]           = "wezterm",
  ["wezterm-gui"]       = "wezterm",
  ["terminal"]          = "terminal",

  -- Editors / IDEs
  ["code"]              = "code",
  ["zed"]               = "zed",
  ["phpstorm"]          = "phpstorm",
  ["neovide"]           = "neovide",
  ["antigravity"]       = "antigravity",
  
  -- Browsers
  ["dia"]               = "dia",
  ["firefox"]           = "firefox",
  ["google chrome"]     = "google-chrome",
  ["chromium"]          = "chromium",
  ["safari"]            = "safari",
  ["opera"]             = "opera",
  ["brave browser"]     = "brave",
  ["microsoft edge"]    = "microsoft-edge",
  ["zen browser"]       = "zen-browser",

  -- Communication
  ["slack"]             = "slack",
  ["discord"]           = "discord",
  ["telegram"]          = "telegram",
  ["whatsapp"]          = "whatsapp",
  ["messages"]          = "messages",
  ["facetime"]          = "facetime",
  ["zoom"]              = "zoom",
  ["microsoft teams"]   = "microsoft-teams",
  ["skype"]             = "skype",

  -- Mail
  ["proton mail"]       = "proton-mail",
  ["mail"]              = "mail",
  ["airmail 5"]         = "airmail",
  ["mimestream"]        = "mimestream",
  ["spark"]             = "spark",

  -- Productivity
  ["notion"]            = "notion",
  ["obsidian"]          = "obsidian",
  ["linear"]            = "linear",
  ["jira"]              = "jira",
  ["confluence"]        = "confluence",
  ["figma"]             = "figma",
  ["sketch"]            = "sketch",
  ["affinity designer"] = "affinity-designer",
  ["affinity photo"]    = "affinity-photo",

  -- Password managers
  ["proton pass"]       = "proton-pass",
  ["1password 7"]       = "1password",
  ["1password"]         = "1password",
  ["bitwarden"]         = "bitwarden",

  -- Music / Media
  ["spotify"]           = "spotify",
  ["music"]             = "music",
  ["podcasts"]          = "podcasts",
  ["plex"]              = "plex",

  -- Utilities
  ["finder"]            = "finder",
  ["system preferences"] = "system-preferences",
  ["system settings"]   = "system-preferences",
  ["activity monitor"]  = "activity-monitor",
  ["console"]           = "console",
  ["keychain access"]   = "keychain-access",
  ["disk utility"]      = "disk-utility",
  ["textedit"]          = "textedit",
  ["notes"]             = "notes",
  ["reminders"]         = "reminders",
  ["calendar"]          = "calendar",
  ["contacts"]          = "contacts",
  ["photos"]            = "photos",
  ["preview"]           = "preview",
  ["vlc"]               = "vlc",

  -- Window managers / system
  ["dia"]               = "dia",
  ["raycast"]           = "raycast",
  ["alfred"]            = "alfred",
  ["bartender 4"]       = "bartender",
  ["stats"]             = "stats",
}

-- Return the ligature string for a given app name, or fallback icon
function icon_map.get(app_name)
  if not app_name or app_name == "" then
    return "default"
  end
  
  local key = string.lower(app_name)
  
  return ":" .. (map[key] or "default") .. ":"
end

return icon_map
