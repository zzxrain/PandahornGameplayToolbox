local _, PGT = ...

local function OnOff(value)
    return value and "ON" or "OFF"
end

function PGT:PrintStatus()
    local fi = self.db.friendlyIdentity
    local hi = self.db.partyTargetHighlight
    local ni = self.db.nameplateTargetHighlight

    self:Print("v" .. self.version
        .. " | addon=" .. OnOff(self.db.enabled)
        .. " | arena=" .. OnOff(self.inArena))
    self:Print("Friendly Identity: " .. OnOff(fi.enabled)
        .. " | party=" .. OnOff(fi.partyFrames)
        .. " | target=" .. OnOff(fi.targetFrame)
        .. " | format=|cffffffff" .. fi.format .. "|r")
    self:Print("Party Target Highlight: " .. OnOff(hi.enabled)
        .. " | arenaOnly=" .. OnOff(hi.arenaOnly)
        .. " | border=" .. OnOff(hi.showBorder)
        .. " | glow=" .. OnOff(hi.showGlow)
        .. " | thickness=" .. tostring(hi.thickness)
        .. " | contrast=" .. tostring(hi.contrast))
    self:Print("Nameplate Target Highlight: " .. OnOff(ni.enabled)
        .. " | border=" .. OnOff(ni.showBorder)
        .. " | glow=" .. OnOff(ni.showGlow)
        .. " | thickness=" .. tostring(ni.thickness)
        .. " | contrast=" .. tostring(ni.contrast))
end

local function PrintHelp()
    PGT:Print("Commands:")
    PGT:Print("/pgt settings")
    PGT:Print("/pgt status")
    PGT:Print("/pgt on | off")
    PGT:Print("/pgt party on | off")
    PGT:Print("/pgt target on | off")
    PGT:Print("/pgt format spec class [party]")
    PGT:Print("/pgt format {spec} {class} {party}")
    PGT:Print("/pgt partyprefix P   (use 'none' for no prefix)")
    PGT:Print("/pgt fallback Ally")
    PGT:Print("/pgt highlight on | off")
    PGT:Print("/pgt highlight arena on | off")
    PGT:Print("/pgt highlight border on | off")
    PGT:Print("/pgt highlight glow on | off")
    PGT:Print("/pgt preview")
    PGT:Print("/pgt debug on | off")
    PGT:Print("/pgt reset")
end

local function ParseOnOff(value)
    value = (value or ""):lower()
    if value == "on" then
        return true
    elseif value == "off" then
        return false
    end
    return nil
end

SLASH_PANDAHORNGAMEPLAYTOOLBOX1 = "/pgt"
SLASH_PANDAHORNGAMEPLAYTOOLBOX2 = "/pandahorngameplay"

SlashCmdList.PANDAHORNGAMEPLAYTOOLBOX = function(message)
    local command, rest = message:match("^(%S*)%s*(.-)%s*$")
    command = (command or ""):lower()
    rest = rest or ""

    if command == "" or command == "help" then
        PrintHelp()
        return
    end

    if command == "settings" or command == "config" or command == "options" then
        if not (PGT.SettingsUI and PGT.SettingsUI:Open()) then
            PGT:Print("Settings panel is not available yet.")
        end
        return
    end

    if command == "status" then
        PGT:PrintStatus()
        return
    end

    if command == "on" or command == "off" then
        PGT.db.enabled = command == "on"
        PGT:Refresh("slash")
        PGT:PrintStatus()
        return
    end

    if command == "party" or command == "target" then
        local value = ParseOnOff(rest)
        if value == nil then
            PGT:Print("Usage: /pgt " .. command .. " on|off")
            return
        end

        if command == "party" then
            PGT.db.friendlyIdentity.partyFrames = value
        else
            PGT.db.friendlyIdentity.targetFrame = value
        end
        PGT:Refresh("slash")
        PGT:PrintStatus()
        return
    end

    if command == "format" then
        local module = PGT.modules.FriendlyIdentity
        local normalized = module and module:NormalizeFormat(rest) or nil
        if not normalized then
            PGT:Print("Invalid format. Tokens: spec, class, party; or use {spec} {class} {party}.")
            return
        end
        PGT.db.friendlyIdentity.format = normalized
        PGT:Refresh("slash")
        PGT:Print("Format set to: |cffffffff" .. normalized .. "|r")
        return
    end

    if command == "partyprefix" then
        local value = rest:gsub("^%s+", ""):gsub("%s+$", "")
        if value:lower() == "none" then
            value = ""
        end
        PGT.db.friendlyIdentity.partyPrefix = value
        PGT:Refresh("slash")
        PGT:Print("Party prefix set to: |cffffffff" .. (value == "" and "<none>" or value) .. "|r")
        return
    end

    if command == "fallback" then
        local value = rest:gsub("^%s+", ""):gsub("%s+$", "")
        if value == "" then
            PGT:Print("Usage: /pgt fallback Ally")
            return
        end
        PGT.db.friendlyIdentity.fallbackText = value
        PGT:Refresh("slash")
        PGT:Print("Fallback text set to: |cffffffff" .. value .. "|r")
        return
    end

    if command == "highlight" then
        local subcommand, valueText = rest:match("^(%S*)%s*(.-)%s*$")
        subcommand = (subcommand or ""):lower()
        valueText = valueText or ""

        if subcommand == "on" or subcommand == "off" then
            PGT.db.partyTargetHighlight.enabled = subcommand == "on"
        elseif subcommand == "arena" or subcommand == "border" or subcommand == "glow" then
            local value = ParseOnOff(valueText)
            if value == nil then
                PGT:Print("Usage: /pgt highlight " .. subcommand .. " on|off")
                return
            end
            if subcommand == "arena" then
                PGT.db.partyTargetHighlight.arenaOnly = value
            elseif subcommand == "border" then
                PGT.db.partyTargetHighlight.showBorder = value
            else
                PGT.db.partyTargetHighlight.showGlow = value
            end
        else
            PGT:Print("Usage: /pgt highlight on|off | arena on|off | border on|off | glow on|off")
            return
        end

        PGT:Refresh("slash")
        PGT:PrintStatus()
        return
    end

    if command == "preview" then
        local module = PGT.modules.FriendlyIdentity
        local preview = module and module:GetPreview() or "Holy Pal"
        PGT:Print("Preview: |cffffffff" .. preview .. "|r")
        return
    end

    if command == "debug" then
        local value = ParseOnOff(rest)
        if value == nil then
            PGT:Print("Usage: /pgt debug on|off")
            return
        end
        PGT.db.debug = value
        PGT:Refresh("slash")
        PGT:Print("Debug: " .. OnOff(PGT.db.debug))
        return
    end

    if command == "reset" then
        PGT:ResetToDefaults()
        PGT:Print("Settings reset to defaults.")
        return
    end

    PrintHelp()
end
