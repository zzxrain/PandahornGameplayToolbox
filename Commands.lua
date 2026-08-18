local _, PPH = ...

local function OnOff(value)
    return value and "ON" or "OFF"
end

function PPH:PrintStatus()
    local fi = self.db.friendlyIdentity
    local hi = self.db.partyTargetHighlight

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
        .. " | glow=" .. OnOff(hi.showGlow))
end

local function PrintHelp()
    PPH:Print("Commands:")
    PPH:Print("/pph settings")
    PPH:Print("/pph status")
    PPH:Print("/pph on | off")
    PPH:Print("/pph party on | off")
    PPH:Print("/pph target on | off")
    PPH:Print("/pph format spec class [party]")
    PPH:Print("/pph format {spec} {class} {party}")
    PPH:Print("/pph partyprefix P   (use 'none' for no prefix)")
    PPH:Print("/pph fallback Ally")
    PPH:Print("/pph highlight on | off")
    PPH:Print("/pph highlight arena on | off")
    PPH:Print("/pph highlight border on | off")
    PPH:Print("/pph highlight glow on | off")
    PPH:Print("/pph preview")
    PPH:Print("/pph debug on | off")
    PPH:Print("/pph reset")
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

SLASH_PANDAHORNPVPHELPER1 = "/pph"
SLASH_PANDAHORNPVPHELPER2 = "/pandahornpvp"

SlashCmdList.PANDAHORNPVPHELPER = function(message)
    local command, rest = message:match("^(%S*)%s*(.-)%s*$")
    command = (command or ""):lower()
    rest = rest or ""

    if command == "" or command == "help" then
        PrintHelp()
        return
    end

    if command == "settings" or command == "config" or command == "options" then
        if not (PPH.SettingsUI and PPH.SettingsUI:Open()) then
            PPH:Print("Settings panel is not available yet.")
        end
        return
    end

    if command == "status" then
        PPH:PrintStatus()
        return
    end

    if command == "on" or command == "off" then
        PPH.db.enabled = command == "on"
        PPH:Refresh("slash")
        PPH:PrintStatus()
        return
    end

    if command == "party" or command == "target" then
        local value = ParseOnOff(rest)
        if value == nil then
            PPH:Print("Usage: /pph " .. command .. " on|off")
            return
        end

        if command == "party" then
            PPH.db.friendlyIdentity.partyFrames = value
        else
            PPH.db.friendlyIdentity.targetFrame = value
        end
        PPH:Refresh("slash")
        PPH:PrintStatus()
        return
    end

    if command == "format" then
        local module = PPH.modules.FriendlyIdentity
        local normalized = module and module:NormalizeFormat(rest) or nil
        if not normalized then
            PPH:Print("Invalid format. Tokens: spec, class, party; or use {spec} {class} {party}.")
            return
        end
        PPH.db.friendlyIdentity.format = normalized
        PPH:Refresh("slash")
        PPH:Print("Format set to: |cffffffff" .. normalized .. "|r")
        return
    end

    if command == "partyprefix" then
        local value = rest:gsub("^%s+", ""):gsub("%s+$", "")
        if value:lower() == "none" then
            value = ""
        end
        PPH.db.friendlyIdentity.partyPrefix = value
        PPH:Refresh("slash")
        PPH:Print("Party prefix set to: |cffffffff" .. (value == "" and "<none>" or value) .. "|r")
        return
    end

    if command == "fallback" then
        local value = rest:gsub("^%s+", ""):gsub("%s+$", "")
        if value == "" then
            PPH:Print("Usage: /pph fallback Ally")
            return
        end
        PPH.db.friendlyIdentity.fallbackText = value
        PPH:Refresh("slash")
        PPH:Print("Fallback text set to: |cffffffff" .. value .. "|r")
        return
    end

    if command == "highlight" then
        local subcommand, valueText = rest:match("^(%S*)%s*(.-)%s*$")
        subcommand = (subcommand or ""):lower()
        valueText = valueText or ""

        if subcommand == "on" or subcommand == "off" then
            PPH.db.partyTargetHighlight.enabled = subcommand == "on"
        elseif subcommand == "arena" or subcommand == "border" or subcommand == "glow" then
            local value = ParseOnOff(valueText)
            if value == nil then
                PPH:Print("Usage: /pph highlight " .. subcommand .. " on|off")
                return
            end
            if subcommand == "arena" then
                PPH.db.partyTargetHighlight.arenaOnly = value
            elseif subcommand == "border" then
                PPH.db.partyTargetHighlight.showBorder = value
            else
                PPH.db.partyTargetHighlight.showGlow = value
            end
        else
            PPH:Print("Usage: /pph highlight on|off | arena on|off | border on|off | glow on|off")
            return
        end

        PPH:Refresh("slash")
        PPH:PrintStatus()
        return
    end

    if command == "preview" then
        local module = PPH.modules.FriendlyIdentity
        local preview = module and module:GetPreview() or "Holy Pal"
        PPH:Print("Preview: |cffffffff" .. preview .. "|r")
        return
    end

    if command == "debug" then
        local value = ParseOnOff(rest)
        if value == nil then
            PPH:Print("Usage: /pph debug on|off")
            return
        end
        PPH.db.debug = value
        PPH:Refresh("slash")
        PPH:Print("Debug: " .. OnOff(PPH.db.debug))
        return
    end

    if command == "reset" then
        PPH:ResetToDefaults()
        PPH:Print("Settings reset to defaults.")
        return
    end

    PrintHelp()
end
