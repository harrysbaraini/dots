-- items/workspaces.lua
-- AeroSpace workspace indicator pills (left side)
-- 6 fixed slots; focused one gets an accent-coloured pill background.
-- Clicking a pill switches to that AeroSpace workspace.

local colors   = require("colors")
local settings = require("settings")

local ws_ids    = settings.workspaces.ids
local ws_labels = settings.workspaces.labels

-- ── Build pill items ──────────────────────────────────────────────────────────
local pills = {}

for i, id in ipairs(ws_ids) do
  local label  = ws_labels[i] or id
  local accent = colors.workspace_accents[i] or colors.wave_blue

  local pill = sbar.add("item", "space." .. id, {
    position = "left",
    padding_left  = 2,
    padding_right = 2,
    label = {
      drawing       = false,
      string        = label,
      font          = { family = settings.font, style = "SemiBold", size = 12.0 },
      color         = colors.old_white,
      padding_left  = 8,
      padding_right = 8,
    },
    icon = {
      drawing = true,
      string = settings.workspaces.icons[i],
      color = colors.with_alpha(colors.workspace_accents[i], 0.85),
      font = { family = settings.font, style = "SemiBold", size = 12.0 },
      padding_left  = 8,
      padding_right = 8,
    },
    background = {
      drawing       = false,
      color         = colors.with_alpha(accent, 0.16),
      border_color  = colors.with_alpha(accent, 0.38),
      border_width  = 1,
      corner_radius = settings.item.corner_radius,
      height        = settings.item.height,
    },
    click_script = "aerospace workspace " .. id,
  })

  pills[id] = { item = pill, accent = accent, label = label }
end

-- ── Highlight logic ───────────────────────────────────────────────────────────
local function update_pills(focused_id)
  -- focused_id is a string like "1"
  for id, p in pairs(pills) do
    if id == focused_id then
      sbar.animate("tanh", 10, function()
        p.item:set({
          label = {
            drawing = true,
          },
          icon = {
            drawing = true,
            color = colors.workspace_accents[i],
          },
          background = {
            drawing      = true,
            color        = colors.with_alpha(p.accent, 0.16),
            border_color = colors.with_alpha(p.accent, 0.38),
          },
        })
      end)
    else
      sbar.animate("tanh", 10, function()
        p.item:set({
          label = {
            drawing = false,
          },
          -- icon = {
          --   drawing = true,
          --   color = colors.with_alpha(colors.workspace_accents[i], 0.25),
          -- },
          background = {
            drawing = false,
          },
        })
      end)
    end
  end
end

-- ── Separator ─────────────────────────────────────────────────────────────────
sbar.add("item", "ws_sep", {
  position = "left",
  padding_left  = 4,
  padding_right = 4,
  icon = {
    string        = "│",
    color         = colors.with_alpha(colors.fg_dim, 0.30),
    padding_left  = 2,
    padding_right = 2,
  },
  label      = { drawing = false },
  background = { drawing = false },
})

-- ── Event subscription via a single visible sentinel ──────────────────────────
-- IMPORTANT: must NOT be drawing=false with updates=when_shown, or events die.
local ws_sentinel = sbar.add("item", "ws.sentinel", {
  position = "left",
  drawing = false,
  updates = true,    -- must be true so the hidden item still receives events
})

ws_sentinel:subscribe("aerospace_workspace_change", function(env)
  local focused_id = env.FOCUSED_WORKSPACE or ""
  update_pills(focused_id)
end)

-- ── Initial state ─────────────────────────────────────────────────────────────
sbar.exec("aerospace list-workspaces --focused", function(result)
  local focused_id = (result or ""):gsub("%s+", "")
  if focused_id ~= "" then
    update_pills(focused_id)
  end
end)

return { pills = pills, update = update_pills }
