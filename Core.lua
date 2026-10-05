local ADDON_NAME, PGT = ...

_G.PandahornGameplayToolbox = PGT

PGT.name = "Pandahorn Gameplay Toolbox"
PGT.version = "0.5.1"
PGT.modules = PGT.modules or {}
PGT.moduleOrder = PGT.moduleOrder or {}
PGT.callbacks = PGT.callbacks or {}
PGT.initialized = false
PGT.inArena = false

local DEFAULTS = {
    dbVersion = 4,
    enabled = true,
    debug = false,

    friendlyIdentity = {
        enabled = true,
        partyFrames = true,
        targetFrame = true,
        keepPlayerName = true,
        format = "{spec} {class}",
        partyPrefix = "P",
        fallbackText = "Ally",
    },

    partyTargetHighlight = {
        enabled = true,
        arenaOnly = true,
        showBorder = true,
        showGlow = true,
        color = { 0.35, 1.00, 0.18 },
        thickness = 5,
        contrast = 85,
        borderColor = { 0.35, 1.00, 0.18, 1.00 },
        glowColor = { 0.20, 1.00, 0.12, 0.88 },
        borderSize = 5,
        glowSize = 7,
        borderOutset = 2,
        glowOutset = 4,
        frameLevelOffset = 30,
        initialResyncDelay = 0.25,
    },

    nameplateTargetHighlight = {
        enabled = true,
        showBorder = true,
        showGlow = true,
        color = { 1.00, 0.72, 0.12 },
        thickness = 4,
        contrast = 90,
        borderOutset = 2,
        glowOutset = 4,
        frameLevelOffset = 100,
    },
}

PGT.DEFAULTS = DEFAULTS

local eventFrame = CreateFrame("Frame")
PGT.eventFrame = eventFrame

local function DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local result = {}
    for key, child in pairs(value) do
        result[key] = DeepCopy(child)
    end
    return result
end

local function CopyDefaults(defaults, target)
    if type(target) ~= "table" then
        target = {}
    end

    for key, value in pairs(defaults) do
        if type(value) == "table" then
            target[key] = CopyDefaults(value, target[key])
        elseif target[key] == nil then
            target[key] = value
        end
    end

    return target
end

function PGT:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffPGT|r: " .. tostring(message))
end

function PGT:Debug(message)
    if self.db and self.db.debug then
        self:Print("|cff999999[debug]|r " .. tostring(message))
    end
end

function PGT:IsSecret(value)
    if _G.issecretvalue then
        return _G.issecretvalue(value)
    end
    return false
end

function PGT:GetSafeBoolean(func, ...)
    local ok, value = pcall(func, ...)
    if not ok or self:IsSecret(value) then
        return nil
    end
    return value and true or false
end

function PGT:GetSafeUnitGUID(unit)
    local ok, guid = pcall(UnitGUID, unit)
    if not ok or self:IsSecret(guid) then
        return nil
    end
    return guid
end

function PGT:GetSafeClassFile(unit)
    local ok, _, classFile = pcall(UnitClass, unit)
    if not ok or self:IsSecret(classFile) then
        return nil
    end
    return classFile
end

function PGT:IsPlayerUnit(unit)
    if unit == "player" then
        return true
    end

    local unitGUID = self:GetSafeUnitGUID(unit)
    local playerGUID = self:GetSafeUnitGUID("player")
    if unitGUID and playerGUID then
        return unitGUID == playerGUID
    end

    local result = self:GetSafeBoolean(UnitIsUnit, unit, "player")
    return result == true
end

function PGT:IsArenaInstance()
    local ok, inInstance, instanceType = pcall(IsInInstance)
    if ok and not self:IsSecret(inInstance) and not self:IsSecret(instanceType) then
        if inInstance and instanceType == "arena" then
            return true
        end
    end

    if C_PvP and C_PvP.IsMatchConsideredArena then
        local result = self:GetSafeBoolean(C_PvP.IsMatchConsideredArena)
        if result == true then
            return true
        end
    end

    if C_PvP and C_PvP.IsArena then
        local result = self:GetSafeBoolean(C_PvP.IsArena)
        if result == true then
            return true
        end
    end

    return false
end

function PGT:RegisterModule(name, module)
    if not name or not module then
        return
    end

    if not self.modules[name] then
        table.insert(self.moduleOrder, name)
    end

    module.name = name
    module.addon = self
    self.modules[name] = module
end

function PGT:RegisterCallback(event, owner, method)
    if not self.callbacks[event] then
        self.callbacks[event] = {}
        if event:sub(1, 4) ~= "PGT_" then
            eventFrame:RegisterEvent(event)
        end
    end

    table.insert(self.callbacks[event], {
        owner = owner,
        method = method,
    })
end

function PGT:Fire(event, ...)
    local callbacks = self.callbacks[event]
    if not callbacks then
        return
    end

    for _, callback in ipairs(callbacks) do
        local method = callback.method
        if type(method) == "string" then
            method = callback.owner[method]
        end
        if method then
            method(callback.owner, event, ...)
        end
    end
end

function PGT:UpdateArenaState()
    local newState = self:IsArenaInstance()
    if newState ~= self.inArena then
        self.inArena = newState
        self:Debug("Arena state changed: " .. tostring(newState))
        self:Fire("PGT_ARENA_STATE_CHANGED", newState)
    end
end

function PGT:Refresh(reason)
    self:UpdateArenaState()
    self:Fire("PGT_CONFIG_CHANGED", reason)
end

function PGT:ResetToDefaults()
    PandahornGameplayToolboxDB = DeepCopy(DEFAULTS)
    self.db = PandahornGameplayToolboxDB
    self:Refresh("reset")
    self:Fire("PGT_SETTINGS_REFRESH")
end

function PGT:Initialize()
    if self.initialized then
        return
    end

    PandahornGameplayToolboxDB = CopyDefaults(DEFAULTS, PandahornGameplayToolboxDB or {})
    PandahornGameplayToolboxDB.dbVersion = DEFAULTS.dbVersion
    self.db = PandahornGameplayToolboxDB

    for _, moduleName in ipairs(self.moduleOrder) do
        local module = self.modules[moduleName]
        if module and module.OnInitialize then
            module:OnInitialize()
        end
    end

    self.initialized = true
    self:UpdateArenaState()
    self:Fire("PGT_READY")
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("PVP_MATCH_ACTIVE")
eventFrame:RegisterEvent("PVP_MATCH_INACTIVE")

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == ADDON_NAME then
            PGT:Initialize()
        end
        return
    end

    if PGT.initialized then
        if event == "PLAYER_ENTERING_WORLD"
            or event == "ZONE_CHANGED_NEW_AREA"
            or event == "PVP_MATCH_ACTIVE"
            or event == "PVP_MATCH_INACTIVE" then
            C_Timer.After(0, function()
                PGT:UpdateArenaState()
            end)
        end

        PGT:Fire(event, ...)
    end
end)
