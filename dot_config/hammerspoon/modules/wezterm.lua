local utils = require("utils")

-- 1. Configuration Mapping (Path Fragment -> Yabai Space Label)
local pathMap = {
    ["/work/juiced"] = "JUI",
    ["/work/valleymetro"] = "VLM",
}

-- 2. Create the window filter for WezTerm
local termFilter = hs.window.filter.new('wezterm-gui')

local function moveWezTermByPath(win)
    local winID = win:id()

    -- Get the active pane info from WezTerm CLI
    local clientsRaw, status = hs.execute("/opt/homebrew/bin/wezterm cli list-clients --format json")

    if not status or not clientsRaw then return end

    local clients = hs.json.decode(clientsRaw)
    local focusedPaneId = nil

    -- Pick the focused pane from the first client (usually the only one)
    if clients and #clients > 0 then
        focusedPaneId = clients[1].focused_pane_id
    end

    if not focusedPaneId then return end

    -- 2. Get the CWD for that specific pane ID
    local listRaw, status = hs.execute("/opt/homebrew/bin/wezterm cli list --format json")
    if not status or not listRaw then return end

    local panes = hs.json.decode(listRaw)
    local cwd = ""

    for _, pane in ipairs(panes) do
        if pane.pane_id == focusedPaneId then
            -- Clean file:// URI
            cwd = pane.cwd:gsub("file://.-/", "/")
            print(cwd)
            break
        end
    end

    -- 3. Match CWD against our pathMap
    local targetSpace = nil
    for pathFragment, spaceLabel in pairs(pathMap) do
        if cwd:find(pathFragment, 1, true) then
            targetSpace = spaceLabel
            break
        end
    end

    print("Focused WezTerm pane CWD:", targetSpace)

    -- 4. Handle the Yabai move if a target is found
    if targetSpace then
        local winRaw = utils.yabai("-m query --windows --window " .. winID)
        local spaceRaw = utils.yabai("-m query --spaces --space " .. targetSpace)

        if winRaw and spaceRaw then
            local winData = hs.json.decode(winRaw)
            local spaceData = hs.json.decode(spaceRaw)

            -- Only move if the window is not already on the correct space
            if winData.space ~= spaceData.index then
                utils.yabai(string.format("-m window %s --space %s", winID, targetSpace))

                -- Focus the window to switch the viewport and raise it
                hs.timer.doAfter(0.2, function()
                    utils.yabai(string.format("-m window --focus %s", winID))
                end)
            end
        end
    end
end

-- Focus is the most reliable trigger for terminal path checking
termFilter:subscribe(hs.window.filter.windowFocused, moveWezTermByPath)
