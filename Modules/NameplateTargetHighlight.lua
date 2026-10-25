local _, PPH = ...

-- Nameplates are pooled, so only retain the currently highlighted plate and
-- store the reusable visual directly on the plate. Target lookup is event-
-- driven; there is intentionally no OnUpdate scan over visible nameplates.
local NameplateTargetHighlight = {
    activePlate = nil,
    deferredSyncPending = false,
}

function NameplateTargetHighlight:GetSettings()
    return PPH.db and PPH.db.nameplateTargetHighlight
end

function NameplateTargetHighlight:IsActive()
    local db = self:GetSettings()
    return PPH.db and PPH.db.enabled and db and db.enabled
end

function NameplateTargetHighlight:GetTargetPlate()
    if not self:IsActive() or not C_NamePlate or not C_NamePlate.GetNamePlateForUnit then
        return nil
    end

    local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, "target")
    if not ok or not plate or PPH:IsSecret(plate) then
        return nil
    end
    if plate.IsForbidden and plate:IsForbidden() then
        return nil
    end
    return plate
end

function NameplateTargetHighlight:GetAnchor(plate)
    local unitFrame = plate and plate.UnitFrame
    local healthBar = unitFrame and unitFrame.healthBar
    if healthBar and healthBar.IsObjectType and healthBar:IsObjectType("StatusBar") then
        return healthBar
    end
    return unitFrame or plate
end

function NameplateTargetHighlight:Hide(plate)
    local visual = plate and plate.PPH_NameplateTargetHighlight
    if not visual then
        return
    end
    visual.border:Hide()
    visual.glow:Hide()
end

function NameplateTargetHighlight:Create(plate, anchor)
    local style = self:GetSettings()
    if not style then
        return nil
    end

    local glow = CreateFrame("Frame", nil, plate, "BackdropTemplate")
    glow:EnableMouse(false)
    glow:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = style.glowSize or 7,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    glow:Hide()

    local border = CreateFrame("Frame", nil, plate, "BackdropTemplate")
    border:EnableMouse(false)
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = style.borderSize or 5,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    border:Hide()

    local visual = {
        anchor = anchor,
        border = border,
        glow = glow,
    }
    plate.PPH_NameplateTargetHighlight = visual
    return visual
end

function NameplateTargetHighlight:ApplyLayout(plate, visual, anchor)
    local style = self:GetSettings()
    if not style then
        return
    end

    if visual.anchor ~= anchor then
        visual.anchor = anchor
    end

    local color = style.color or { 1.00, 0.72, 0.12 }
    local thickness = math.max(1, math.min(12, tonumber(style.thickness) or 4))
    local contrast = math.max(0, math.min(100, tonumber(style.contrast) or 90)) / 100
    local borderOutset = style.borderOutset or 2
    local glowOutset = style.glowOutset or 4
    local baseLevel = math.max(plate:GetFrameLevel(), anchor:GetFrameLevel())
    local levelOffset = math.max(style.frameLevelOffset or 30, 100)

    visual.glow:ClearAllPoints()
    visual.glow:SetPoint("TOPLEFT", anchor, "TOPLEFT", -glowOutset, glowOutset)
    visual.glow:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", glowOutset, -glowOutset)
    visual.glow:SetFrameStrata("HIGH")
    visual.glow:SetFrameLevel(baseLevel + levelOffset - 1)
    visual.glow:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = thickness + 2 })
    visual.glow:SetBackdropBorderColor(color[1], color[2], color[3], 0.10 + (contrast * 0.70))

    visual.border:ClearAllPoints()
    visual.border:SetPoint("TOPLEFT", anchor, "TOPLEFT", -borderOutset, borderOutset)
    visual.border:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", borderOutset, -borderOutset)
    visual.border:SetFrameStrata("HIGH")
    visual.border:SetFrameLevel(baseLevel + levelOffset)
    visual.border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = thickness })
    visual.border:SetBackdropBorderColor(color[1], color[2], color[3], 0.35 + (contrast * 0.65))
end

function NameplateTargetHighlight:Show(plate)
    local anchor = self:GetAnchor(plate)
    local style = self:GetSettings()
    if not anchor or not style then
        return
    end

    local visual = plate.PPH_NameplateTargetHighlight or self:Create(plate, anchor)
    if not visual then
        return
    end

    -- Reassert layout when the target changes so skinning addons such as
    -- BetterBlizzPlates cannot leave this overlay below their custom layers.
    self:ApplyLayout(plate, visual, anchor)

    if style.showGlow then
        visual.glow:Show()
    else
        visual.glow:Hide()
    end
    if style.showBorder then
        visual.border:Show()
    else
        visual.border:Hide()
    end
end

function NameplateTargetHighlight:Sync()
    local previous = self.activePlate
    local current = self:GetTargetPlate()

    if previous and previous ~= current then
        self:Hide(previous)
    end

    self.activePlate = current
    if current and current:IsShown() then
        self:Show(current)
    elseif current then
        self:Hide(current)
    end
end

function NameplateTargetHighlight:ScheduleSync()
    if self.deferredSyncPending then
        return
    end
    self.deferredSyncPending = true
    C_Timer.After(0, function()
        NameplateTargetHighlight.deferredSyncPending = false
        NameplateTargetHighlight:Sync()
    end)
end

function NameplateTargetHighlight:OnNamePlateAdded()
    -- Defer once so Blizzard and nameplate skinning addons finish laying out
    -- the newly acquired plate before the PPH overlay is positioned above it.
    self:ScheduleSync()
end

function NameplateTargetHighlight:OnNamePlateRemoved()
    self:ScheduleSync()
end

function NameplateTargetHighlight:OnConfigChanged()
    self:Sync()
end

function NameplateTargetHighlight:OnInitialize()
    PPH:RegisterCallback("NAME_PLATE_UNIT_ADDED", self, "OnNamePlateAdded")
    PPH:RegisterCallback("NAME_PLATE_UNIT_REMOVED", self, "OnNamePlateRemoved")
    PPH:RegisterCallback("PLAYER_TARGET_CHANGED", self, "ScheduleSync")
    PPH:RegisterCallback("PLAYER_ENTERING_WORLD", self, "ScheduleSync")
    PPH:RegisterCallback("PPH_CONFIG_CHANGED", self, "OnConfigChanged")
end

PPH:RegisterModule("NameplateTargetHighlight", NameplateTargetHighlight)
