local _, PGT = ...

local FriendlyIdentity = {
    seenPartyFrames = setmetatable({}, { __mode = "k" }),
    hookedCompactFrames = false,
    hookedTargetFrame = false,
}

local VALID_TOKENS = {
    spec = true,
    class = true,
    party = true,
}

local function Trim(text)
    text = tostring(text or "")
    return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

function FriendlyIdentity:GetSettings()
    return PGT.db and PGT.db.friendlyIdentity
end

function FriendlyIdentity:IsEnabled()
    local db = self:GetSettings()
    return PGT.db
        and PGT.db.enabled
        and db
        and db.enabled
        and PGT.inArena
end

function FriendlyIdentity:NormalizeFormat(value)
    value = Trim(value)
    if value == "" then
        return nil
    end

    if value:find("{", 1, true) then
        local invalid = false
        value:gsub("{([^}]+)}", function(token)
            if not VALID_TOKENS[token:lower()] then
                invalid = true
            end
        end)
        if invalid then
            return nil
        end
        return value
    end

    local output = {}
    for token in value:gmatch("%S+") do
        token = token:lower()
        if token == "number" then
            token = "party"
        end
        if not VALID_TOKENS[token] then
            return nil
        end
        table.insert(output, "{" .. token .. "}")
    end

    if #output == 0 then
        return nil
    end

    return table.concat(output, " ")
end

function FriendlyIdentity:GetPreview(format)
    local db = self:GetSettings()
    format = format or (db and db.format) or "{spec} {class}"
    local prefix = (db and db.partyPrefix) or "P"
    local preview = format
        :gsub("{spec}", "Holy")
        :gsub("{class}", "Pal")
        :gsub("{party}", prefix .. "1")
    preview = preview:gsub("%s+", " ")
    return Trim(preview)
end

function FriendlyIdentity:GetFrameUnit(frame)
    if not frame then
        return nil
    end

    local unit = frame.displayedUnit or frame.unit
    if PGT:IsSecret(unit) or type(unit) ~= "string" then
        return nil
    end
    return unit
end

function FriendlyIdentity:IsGroupMemberUnit(unit)
    return type(unit) == "string"
        and (unit:match("^party%d+$") ~= nil or unit:match("^raid%d+$") ~= nil)
end

function FriendlyIdentity:GetPartyNumber(unit)
    if type(unit) == "string" then
        local direct = unit:match("^party(%d+)$")
        if direct then
            return tonumber(direct)
        end
    end

    local unitGUID = PGT:GetSafeUnitGUID(unit)
    if unitGUID then
        for index = 1, 4 do
            local partyGUID = PGT:GetSafeUnitGUID("party" .. index)
            if partyGUID and partyGUID == unitGUID then
                return index
            end
        end
    end

    for index = 1, 4 do
        local sameUnit = PGT:GetSafeBoolean(UnitIsUnit, unit, "party" .. index)
        if sameUnit == true then
            return index
        end
    end

    return nil
end

function FriendlyIdentity:GetUnitIdentity(unit)
    local specID = PGT.Inspect and PGT.Inspect:GetSpecID(unit) or nil
    local specData = specID and PGT.SpecData[specID] or nil

    local specText = specData and specData.spec or nil
    local classText = specData and specData.class or nil

    if not classText and PGT.Inspect then
        local classFile = PGT.Inspect:GetClassFile(unit)
        if classFile then
            classText = PGT.ClassAbbreviations[classFile]
        end
    end

    local partyNumber = self:GetPartyNumber(unit)
    local db = self:GetSettings()
    local partyText = nil
    if partyNumber then
        partyText = (db.partyPrefix or "P") .. tostring(partyNumber)
    end

    return specText, classText, partyText
end

function FriendlyIdentity:FormatUnit(unit)
    local db = self:GetSettings()
    local specText, classText, partyText = self:GetUnitIdentity(unit)

    local output = db.format or "{spec} {class}"
    output = output:gsub("{spec}", specText or "")
    output = output:gsub("{class}", classText or "")
    output = output:gsub("{party}", partyText or "")

    output = output:gsub("%s+", " ")
    output = Trim(output)

    if output == "" then
        output = partyText or classText or db.fallbackText or "Ally"
    end

    return output
end

function FriendlyIdentity:ShouldMaskUnit(unit)
    if not self:IsEnabled() or not unit then
        return false
    end

    local db = self:GetSettings()
    if db.keepPlayerName and PGT:IsPlayerUnit(unit) then
        return false
    end

    local exists = PGT:GetSafeBoolean(UnitExists, unit)
    local isPlayer = PGT:GetSafeBoolean(UnitIsPlayer, unit)
    local isFriend = PGT:GetSafeBoolean(UnitIsFriend, "player", unit)

    return exists == true and isPlayer == true and isFriend == true
end

function FriendlyIdentity:ShouldHandlePartyFrame(frame)
    if not frame then
        return false
    end

    if frame.IsForbidden and frame:IsForbidden() then
        return false
    end

    local name = frame.GetName and frame:GetName()
    if name then
        if name:find("NamePlate") then
            return false
        end
        if not (name:find("^CompactRaid") or name:find("^CompactParty")) then
            return false
        end
    end

    if frame.frameType == "target" or frame.frameType == "pet" then
        return false
    end

    return self:IsGroupMemberUnit(self:GetFrameUnit(frame))
end

function FriendlyIdentity:ApplyPartyFrame(frame)
    local db = self:GetSettings()
    if not db or not db.partyFrames or not self:ShouldHandlePartyFrame(frame) then
        return
    end

    local unit = self:GetFrameUnit(frame)
    self.seenPartyFrames[frame] = true

    if self:ShouldMaskUnit(unit) and frame.name then
        frame.name:SetText(self:FormatUnit(unit))
        frame.name:Show()
        if PGT.Inspect then
            PGT.Inspect:QueueUnit(unit)
        end
    end
end

function FriendlyIdentity:RestorePartyFrame(frame)
    if not frame or (frame.IsForbidden and frame:IsForbidden()) or not frame.name then
        return
    end

    local unit = self:GetFrameUnit(frame)
    if not unit then
        return
    end

    local ok, name = pcall(GetUnitName, unit, true)
    if ok and not PGT:IsSecret(name) and name then
        frame.name:SetText(name)
    end
end

function FriendlyIdentity:GetTargetNameFontString()
    if not _G.TargetFrame then
        return nil
    end

    local content = _G.TargetFrame.TargetFrameContent
    local main = content and content.TargetFrameContentMain
    if main and main.Name then
        return main.Name
    end

    if _G.TargetFrameName then
        return _G.TargetFrameName
    end

    return nil
end

function FriendlyIdentity:ApplyTargetFrame()
    local db = self:GetSettings()
    local nameFontString = self:GetTargetNameFontString()
    if not nameFontString then
        return
    end

    if not self:IsEnabled() or not db.targetFrame then
        self:RestoreTargetFrame()
        return
    end

    if self:ShouldMaskUnit("target") then
        nameFontString:SetText(self:FormatUnit("target"))
        if PGT.Inspect then
            PGT.Inspect:QueueUnit("target", true)
        end
    else
        self:RestoreTargetFrame()
    end
end

function FriendlyIdentity:RestoreTargetFrame()
    local nameFontString = self:GetTargetNameFontString()
    if not nameFontString then
        return
    end

    local exists = PGT:GetSafeBoolean(UnitExists, "target")
    if exists ~= true then
        return
    end

    local ok, name = pcall(UnitName, "target")
    if ok and not PGT:IsSecret(name) and name then
        nameFontString:SetText(name)
    end
end

function FriendlyIdentity:DiscoverPartyFrames()
    if _G.CompactPartyFrame and type(_G.CompactPartyFrame.memberUnitFrames) == "table" then
        for _, frame in ipairs(_G.CompactPartyFrame.memberUnitFrames) do
            if frame then
                self.seenPartyFrames[frame] = true
            end
        end
    end

    for index = 1, 5 do
        local frame = _G["CompactPartyFrameMember" .. index]
        if frame then
            self.seenPartyFrames[frame] = true
        end
    end
end

function FriendlyIdentity:RefreshPartyFrames()
    self:DiscoverPartyFrames()
    local db = self:GetSettings()
    for frame in pairs(self.seenPartyFrames) do
        if self:IsEnabled() and db.partyFrames then
            self:ApplyPartyFrame(frame)
        else
            self:RestorePartyFrame(frame)
        end
    end
end

function FriendlyIdentity:RefreshTargetFrame()
    local db = self:GetSettings()
    if self:IsEnabled() and db.targetFrame then
        self:ApplyTargetFrame()
    else
        self:RestoreTargetFrame()
    end
end

function FriendlyIdentity:RefreshAll()
    self:RefreshPartyFrames()
    self:RefreshTargetFrame()
end

function FriendlyIdentity:InstallHooks()
    if not self.hookedCompactFrames and type(_G.CompactUnitFrame_UpdateName) == "function" then
        hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
            FriendlyIdentity:ApplyPartyFrame(frame)
        end)
        self.hookedCompactFrames = true
    end

    if not self.hookedTargetFrame and type(_G.TargetFrame_Update) == "function" then
        hooksecurefunc("TargetFrame_Update", function()
            FriendlyIdentity:ApplyTargetFrame()
        end)
        self.hookedTargetFrame = true
    end
end

function FriendlyIdentity:OnArenaStateChanged()
    C_Timer.After(0, function()
        FriendlyIdentity:InstallHooks()
        FriendlyIdentity:RefreshAll()
    end)
end

function FriendlyIdentity:OnTargetChanged()
    C_Timer.After(0, function()
        FriendlyIdentity:ApplyTargetFrame()
    end)
end

function FriendlyIdentity:OnInspectUpdated()
    C_Timer.After(0, function()
        FriendlyIdentity:RefreshAll()
    end)
end

function FriendlyIdentity:OnConfigChanged()
    C_Timer.After(0, function()
        FriendlyIdentity:RefreshAll()
    end)
end

function FriendlyIdentity:OnInitialize()
    self:InstallHooks()
    PGT:RegisterCallback("PLAYER_LOGIN", self, "OnArenaStateChanged")
    PGT:RegisterCallback("PLAYER_TARGET_CHANGED", self, "OnTargetChanged")
    PGT:RegisterCallback("GROUP_ROSTER_UPDATE", self, "OnArenaStateChanged")
    PGT:RegisterCallback("PGT_ARENA_STATE_CHANGED", self, "OnArenaStateChanged")
    PGT:RegisterCallback("PGT_INSPECT_UPDATED", self, "OnInspectUpdated")
    PGT:RegisterCallback("PGT_CONFIG_CHANGED", self, "OnConfigChanged")
end

PGT:RegisterModule("FriendlyIdentity", FriendlyIdentity)
