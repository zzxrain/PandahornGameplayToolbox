local _, PPH = ...

-- Integrated from the standalone SimplePartyHighlight prototype.
-- The important safety property is preserved: selection state is read from
-- Blizzard's own frame.selectionHighlight instead of re-evaluating UnitIsUnit.
local PartyTargetHighlight = {
    trackedFrames = setmetatable({}, { __mode = "k" }),
    needsPostCombatResync = false,
    hooksInstalled = false,
}

function PartyTargetHighlight:GetSettings()
    return PPH.db and PPH.db.partyTargetHighlight
end

function PartyTargetHighlight:IsActive()
    local db = self:GetSettings()
    if not PPH.db or not PPH.db.enabled or not db or not db.enabled then
        return false
    end

    if db.arenaOnly and not PPH.inArena then
        return false
    end

    return true
end

function PartyTargetHighlight:GetDisplayedUnit(frame)
    if not frame then
        return nil
    end

    local unit = frame.displayedUnit or frame.unit
    if PPH:IsSecret(unit) or type(unit) ~= "string" then
        return nil
    end
    return unit
end

function PartyTargetHighlight:IsPartyOrRaidMemberUnit(unit)
    return type(unit) == "string"
        and (unit:match("^party%d+$") ~= nil or unit:match("^raid%d+$") ~= nil)
end

function PartyTargetHighlight:ShouldTrackFrame(frame)
    if not frame then
        return false
    end

    if frame.IsForbidden and frame:IsForbidden() then
        return false
    end

    local name = frame.GetName and frame:GetName()
    if not name then
        return false
    end

    if name:find("NamePlate") then
        return false
    end

    if not (name:find("^CompactRaid") or name:find("^CompactParty")) then
        return false
    end

    if frame.frameType == "target" or frame.frameType == "pet" then
        return false
    end

    return self:IsPartyOrRaidMemberUnit(self:GetDisplayedUnit(frame))
end

function PartyTargetHighlight:HideHighlight(frame)
    if not frame then
        return
    end

    if frame.PPH_TargetHighlightBorder then
        frame.PPH_TargetHighlightBorder:Hide()
    end

    if frame.PPH_TargetHighlightGlow then
        frame.PPH_TargetHighlightGlow:Hide()
    end
end

function PartyTargetHighlight:ShowHighlight(frame)
    if not frame then
        return
    end

    local db = self:GetSettings()
    if db.showGlow and frame.PPH_TargetHighlightGlow then
        frame.PPH_TargetHighlightGlow:Show()
    elseif frame.PPH_TargetHighlightGlow then
        frame.PPH_TargetHighlightGlow:Hide()
    end

    if db.showBorder and frame.PPH_TargetHighlightBorder then
        frame.PPH_TargetHighlightBorder:Show()
    elseif frame.PPH_TargetHighlightBorder then
        frame.PPH_TargetHighlightBorder:Hide()
    end
end

function PartyTargetHighlight:CreateHighlight(frame)
    local db = self:GetSettings()
    local borderOutset = db.borderOutset or 2
    local glowOutset = db.glowOutset or 4
    local levelOffset = db.frameLevelOffset or 30

    local glow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    glow:SetFrameLevel(frame:GetFrameLevel() + levelOffset - 1)
    glow:SetPoint("TOPLEFT", frame, "TOPLEFT", -glowOutset, glowOutset)
    glow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", glowOutset, -glowOutset)
    glow:EnableMouse(false)
    glow:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = db.glowSize or 7,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    glow:SetBackdropBorderColor(unpack(db.glowColor or { 0.20, 1.00, 0.12, 0.88 }))
    glow:Hide()

    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetFrameLevel(frame:GetFrameLevel() + levelOffset)
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -borderOutset, borderOutset)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", borderOutset, -borderOutset)
    border:EnableMouse(false)
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = db.borderSize or 5,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    border:SetBackdropBorderColor(unpack(db.borderColor or { 0.35, 1.00, 0.18, 1.00 }))
    border:Hide()

    frame.PPH_TargetHighlightGlow = glow
    frame.PPH_TargetHighlightBorder = border
    return border
end

function PartyTargetHighlight:GetOrCreateHighlight(frame)
    if frame.PPH_TargetHighlightBorder and frame.PPH_TargetHighlightGlow then
        return frame.PPH_TargetHighlightBorder
    end

    if InCombatLockdown and InCombatLockdown() then
        self.needsPostCombatResync = true
        return nil
    end

    return self:CreateHighlight(frame)
end

function PartyTargetHighlight:IsFrameSelected(frame)
    return frame
        and frame:IsVisible()
        and frame.selectionHighlight
        and frame.selectionHighlight:IsShown()
end

function PartyTargetHighlight:SyncHighlight(frame)
    if not frame then
        return
    end

    if not self:ShouldTrackFrame(frame) then
        self.trackedFrames[frame] = nil
        self:HideHighlight(frame)
        return
    end

    self.trackedFrames[frame] = true

    if not self:IsActive() then
        self:HideHighlight(frame)
        return
    end

    local highlight = self:GetOrCreateHighlight(frame)
    if not highlight then
        return
    end

    if self:IsFrameSelected(frame) then
        self:ShowHighlight(frame)
    else
        self:HideHighlight(frame)
    end
end

function PartyTargetHighlight:DiscoverFrames()
    if _G.CompactPartyFrame and type(_G.CompactPartyFrame.memberUnitFrames) == "table" then
        for _, frame in ipairs(_G.CompactPartyFrame.memberUnitFrames) do
            if frame and self:ShouldTrackFrame(frame) then
                self.trackedFrames[frame] = true
            end
        end
    end

    for index = 1, 5 do
        local frame = _G["CompactPartyFrameMember" .. index]
        if frame and self:ShouldTrackFrame(frame) then
            self.trackedFrames[frame] = true
        end
    end
end

function PartyTargetHighlight:SyncAllHighlights()
    self:DiscoverFrames()
    for frame in pairs(self.trackedFrames) do
        self:SyncHighlight(frame)
    end
end

function PartyTargetHighlight:InstallHooks()
    if self.hooksInstalled then
        return
    end

    if type(_G.CompactUnitFrame_UpdateAll) == "function" then
        hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
            PartyTargetHighlight:SyncHighlight(frame)
        end)
    end

    if type(_G.CompactUnitFrame_UpdateSelectionHighlight) == "function" then
        hooksecurefunc("CompactUnitFrame_UpdateSelectionHighlight", function(frame)
            PartyTargetHighlight:SyncHighlight(frame)
        end)
    end

    if type(_G.CompactUnitFrame_SetUnit) == "function" then
        hooksecurefunc("CompactUnitFrame_SetUnit", function(frame)
            PartyTargetHighlight:SyncHighlight(frame)
        end)
    end

    self.hooksInstalled = true
end

function PartyTargetHighlight:OnEvent(_, event)
    if event == "PLAYER_REGEN_ENABLED" and not self.needsPostCombatResync then
        return
    end

    self.needsPostCombatResync = false
    C_Timer.After(0, function()
        PartyTargetHighlight:SyncAllHighlights()
    end)
end

function PartyTargetHighlight:OnArenaStateChanged()
    C_Timer.After(0, function()
        PartyTargetHighlight:SyncAllHighlights()
    end)
end

function PartyTargetHighlight:OnConfigChanged()
    C_Timer.After(0, function()
        PartyTargetHighlight:SyncAllHighlights()
    end)
end

function PartyTargetHighlight:OnInitialize()
    self:InstallHooks()

    PPH:RegisterCallback("PLAYER_TARGET_CHANGED", self, "OnEvent")
    PPH:RegisterCallback("GROUP_ROSTER_UPDATE", self, "OnEvent")
    PPH:RegisterCallback("PLAYER_ENTERING_WORLD", self, "OnEvent")
    PPH:RegisterCallback("PLAYER_REGEN_ENABLED", self, "OnEvent")
    PPH:RegisterCallback("PPH_ARENA_STATE_CHANGED", self, "OnArenaStateChanged")
    PPH:RegisterCallback("PPH_CONFIG_CHANGED", self, "OnConfigChanged")

    local db = self:GetSettings()
    local delay = db and db.initialResyncDelay or 0.25
    C_Timer.After(delay, function()
        PartyTargetHighlight:SyncAllHighlights()
    end)
end

PPH:RegisterModule("PartyTargetHighlight", PartyTargetHighlight)
