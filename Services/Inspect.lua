local _, PPH = ...

local Inspect = {
    specByGUID = {},
    classByGUID = {},
    queue = {},
    queued = {},
    pendingUnit = nil,
    pendingGUID = nil,
    retryAt = 0,
}

PPH.Inspect = Inspect

local function GetInspectSpec(unit)
    if C_SpecializationInfo and C_SpecializationInfo.GetInspectSpecialization then
        return C_SpecializationInfo.GetInspectSpecialization(unit)
    end
    if _G.GetInspectSpecialization then
        return _G.GetInspectSpecialization(unit)
    end
    return nil
end

function Inspect:GetSpecID(unit)
    local guid = PPH:GetSafeUnitGUID(unit)
    if guid then
        local cached = self.specByGUID[guid]
        if cached then
            return cached
        end
    end

    local ok, specID = pcall(GetInspectSpec, unit)
    if not ok or PPH:IsSecret(specID) then
        return nil
    end

    if type(specID) == "number" and specID > 0 then
        if guid then
            self.specByGUID[guid] = specID
        end
        return specID
    end

    return nil
end

function Inspect:GetClassFile(unit)
    local guid = PPH:GetSafeUnitGUID(unit)
    if guid and self.classByGUID[guid] then
        return self.classByGUID[guid]
    end

    local classFile = PPH:GetSafeClassFile(unit)
    if classFile and guid then
        self.classByGUID[guid] = classFile
    end
    return classFile
end

function Inspect:QueueUnit(unit, highPriority)
    if not PPH.inArena or not unit then
        return
    end

    if PPH:IsPlayerUnit(unit) then
        return
    end

    local exists = PPH:GetSafeBoolean(UnitExists, unit)
    local isPlayer = PPH:GetSafeBoolean(UnitIsPlayer, unit)
    local isFriend = PPH:GetSafeBoolean(UnitIsFriend, "player", unit)
    if exists ~= true or isPlayer ~= true or isFriend ~= true then
        return
    end

    if self:GetSpecID(unit) then
        return
    end

    local guid = PPH:GetSafeUnitGUID(unit)
    local key = guid or unit
    if self.queued[key] then
        return
    end

    self.queued[key] = true
    local entry = { unit = unit, key = key }
    if highPriority then
        table.insert(self.queue, 1, entry)
    else
        table.insert(self.queue, entry)
    end

    self:Pump()
end

function Inspect:QueueParty()
    if not PPH.inArena then
        return
    end

    for index = 1, 4 do
        self:QueueUnit("party" .. index)
    end
end

function Inspect:Pump()
    if self.pendingUnit or not PPH.inArena or #self.queue == 0 then
        return
    end

    local now = GetTime()
    if now < self.retryAt then
        C_Timer.After(self.retryAt - now, function()
            Inspect:Pump()
        end)
        return
    end

    while #self.queue > 0 do
        local entry = table.remove(self.queue, 1)
        self.queued[entry.key] = nil

        if self:GetSpecID(entry.unit) then
            PPH:Fire("PPH_INSPECT_UPDATED", entry.unit)
        else
            local canInspect = PPH:GetSafeBoolean(CanInspect, entry.unit, false)
            if canInspect == true then
                local guid = PPH:GetSafeUnitGUID(entry.unit)
                self.pendingUnit = entry.unit
                self.pendingGUID = guid
                self.retryAt = now + 1.5

                local ok = pcall(NotifyInspect, entry.unit)
                if not ok then
                    self.pendingUnit = nil
                    self.pendingGUID = nil
                else
                    C_Timer.After(2.5, function()
                        if Inspect.pendingUnit == entry.unit then
                            Inspect.pendingUnit = nil
                            Inspect.pendingGUID = nil
                            if _G.ClearInspectPlayer then
                                pcall(ClearInspectPlayer)
                            end
                            Inspect:Pump()
                        end
                    end)
                    return
                end
            end
        end
    end
end

function Inspect:OnInspectReady(_, guid)
    if not self.pendingUnit then
        return
    end

    if PPH:IsSecret(guid) then
        return
    end

    if self.pendingGUID and guid and self.pendingGUID ~= guid then
        return
    end

    local unit = self.pendingUnit
    local specID = self:GetSpecID(unit)
    local unitGUID = PPH:GetSafeUnitGUID(unit)
    if specID and unitGUID then
        self.specByGUID[unitGUID] = specID
    end

    self.pendingUnit = nil
    self.pendingGUID = nil

    if _G.ClearInspectPlayer then
        pcall(ClearInspectPlayer)
    end

    PPH:Fire("PPH_INSPECT_UPDATED", unit)
    C_Timer.After(0.1, function()
        Inspect:Pump()
    end)
end

function Inspect:OnArenaStateChanged(_, active)
    self.queue = {}
    self.queued = {}
    self.pendingUnit = nil
    self.pendingGUID = nil

    if active then
        for _, delay in ipairs({ 0.5, 2.0, 5.0 }) do
            C_Timer.After(delay, function()
                if PPH.inArena then
                    Inspect:QueueParty()
                end
            end)
        end
    elseif _G.ClearInspectPlayer then
        pcall(ClearInspectPlayer)
    end
end

function Inspect:OnGroupRosterUpdate()
    if PPH.inArena then
        C_Timer.After(0.25, function()
            Inspect:QueueParty()
        end)
    end
end

function Inspect:OnTargetChanged()
    if PPH.inArena then
        self:QueueUnit("target", true)
    end
end

function Inspect:OnInitialize()
    PPH:RegisterCallback("INSPECT_READY", self, "OnInspectReady")
    PPH:RegisterCallback("GROUP_ROSTER_UPDATE", self, "OnGroupRosterUpdate")
    PPH:RegisterCallback("PLAYER_TARGET_CHANGED", self, "OnTargetChanged")
    PPH:RegisterCallback("PPH_ARENA_STATE_CHANGED", self, "OnArenaStateChanged")
end

PPH:RegisterModule("InspectService", Inspect)
