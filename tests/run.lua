-- Run from the repository root: lua5.1 tests/run.lua
-- These checks exercise addon logic with explicit WoW API stubs, not a game client.
local passed = 0
local function test(name, callback)
    callback()
    passed = passed + 1
    print("PASS " .. name)
end

local function loadAddon(saved, client)
    local eventScripts = {}
    local timers = {}
    local events = {}
    _G.GetBuildInfo = function()
        if client == "forever" then
            return "1.60.1", "test", "test", 16001
        end
        return "12.1.5", "test", "test", 120105
    end
    _G.PandahornGameplayToolboxDB = saved
    _G.CreateFrame = function()
        return {
            RegisterEvent = function(_, event) events[event] = true end,
            SetScript = function(_, event, callback) eventScripts[event] = callback end,
        }
    end
    _G.C_Timer = { After = function(_, callback) timers[#timers + 1] = callback end }
    _G.IsInInstance = function() return false, "none" end
    _G.C_PvP = nil
    _G.issecretvalue = nil
    local addon = {}
    assert(loadfile("Core.lua"))("PandahornGameplayToolbox", addon)
    -- Initialize core before registering UI modules; the UI requires a real client.
    eventScripts.OnEvent(nil, "ADDON_LOADED", "PandahornGameplayToolbox")
    for line in io.lines("PandahornGameplayToolbox.toc") do
        if line:match("%.lua%s*$") and line ~= "Core.lua" then
            assert(loadfile(line))("PandahornGameplayToolbox", addon)
        end
    end
    return addon, timers, events
end

test("Retail 12.1.5 metadata and runtime version match", function()
    local addon = loadAddon()
    local file = assert(io.open("PandahornGameplayToolbox.toc"))
    local toc = file:read("*a")
    file:close()
    assert(toc:match("## Interface: 120105, 16001"))
    assert(toc:match("## Version: " .. addon.version:gsub("%.", "%%.")))
    assert(addon.version == "0.6.0")
end)

test("existing preferences survive default initialization", function()
    local addon = loadAddon({
        enabled = false,
        friendlyIdentity = { enabled = false, partyPrefix = "Team" },
        partyTargetHighlight = { arenaOnly = false, thickness = 9 },
    })
    assert(addon.db.enabled == false)
    assert(addon.db.friendlyIdentity.enabled == false)
    assert(addon.db.friendlyIdentity.partyPrefix == "Team")
    assert(addon.db.partyTargetHighlight.arenaOnly == false)
    assert(addon.db.partyTargetHighlight.thickness == 9)
    assert(addon.db.nameplateTargetHighlight.enabled == true)
end)

test("Retail arena-only highlighting respects arena and global settings", function()
    local addon = loadAddon()
    local highlight = addon.modules.PartyTargetHighlight
    assert(not highlight:IsActive())
    addon.inArena = true
    assert(highlight:IsActive())
    addon.db.enabled = false
    assert(not highlight:IsActive())
    addon.db.enabled = true
    addon.inArena = false
    addon.db.partyTargetHighlight.arenaOnly = false
    assert(highlight:IsActive())
end)

test("combat-end callbacks schedule resync only when it is pending", function()
    local addon, timers = loadAddon()
    local highlight = addon.modules.PartyTargetHighlight
    addon:RegisterCallback("PLAYER_REGEN_ENABLED", highlight, "OnEvent")
    addon:Fire("PLAYER_REGEN_ENABLED")
    assert(#timers == 0)
    local synced = 0
    highlight.SyncAllHighlights = function() synced = synced + 1 end
    highlight.needsPostCombatResync = true
    addon:Fire("PLAYER_REGEN_ENABLED")
    assert(#timers == 1)
    assert(not highlight.needsPostCombatResync)
    timers[1]()
    assert(synced == 1)
end)

test("identity format, preview and registration load in manifest order", function()
    local addon = loadAddon()
    assert(#addon.moduleOrder == 5)
    local identity = addon.modules.FriendlyIdentity
    assert(identity:NormalizeFormat("spec class number") == "{spec} {class} {party}")
    assert(identity:NormalizeFormat("{invalid}") == nil)
    assert(identity:GetPreview("{spec} {class} {party}") == "Holy Pal P1")
    assert(addon.SpecData[65].class == "Pal")
end)

test("arena detection tolerates missing APIs and API errors", function()
    local addon = loadAddon()
    _G.IsInInstance = nil
    assert(not addon:IsArenaInstance())
    _G.C_PvP = { IsArena = function() return true end }
    assert(addon:IsArenaInstance())
    _G.C_PvP.IsArena = function() error("unavailable") end
    assert(not addon:IsArenaInstance())
end)

test("Forever gets non-arena defaults and no match event registrations", function()
    local addon, _, events = loadAddon(nil, "forever")
    assert(addon.isForever and not addon.supportsArena)
    assert(addon.clientName == "WoW: Forever")
    assert(not addon.db.friendlyIdentity.enabled)
    assert(not addon.db.partyTargetHighlight.arenaOnly)
    assert(addon.modules.PartyTargetHighlight:IsActive())
    assert(addon.modules.NameplateTargetHighlight:IsActive())
    assert(not events.PVP_MATCH_ACTIVE and not events.PVP_MATCH_INACTIVE)
end)

test("Forever ignores arena APIs and bypasses imported arena-only preferences", function()
    local addon = loadAddon({
        friendlyIdentity = { enabled = true },
        partyTargetHighlight = { arenaOnly = true, thickness = 8 },
    }, "forever")
    _G.IsInInstance = function() error("Forever must not query arenas") end
    _G.C_PvP = { IsArena = function() error("Forever must not query PvP arenas") end }
    assert(not addon:IsArenaInstance())
    assert(addon.modules.PartyTargetHighlight:IsActive())
    assert(not addon.modules.FriendlyIdentity:IsEnabled())
    assert(addon.db.friendlyIdentity.enabled == true)
    assert(addon.db.partyTargetHighlight.arenaOnly == true)
    assert(addon.db.partyTargetHighlight.thickness == 8)
end)

test("Forever skips identity hooks and specialization inspection", function()
    local addon, _, events = loadAddon(nil, "forever")
    local function unavailable() error("arena-only API used on Forever") end
    _G.hooksecurefunc = unavailable
    _G.NotifyInspect = unavailable
    _G.CompactUnitFrame_UpdateName = unavailable
    _G.TargetFrame_Update = unavailable
    addon.modules.FriendlyIdentity:OnInitialize()
    addon.Inspect:OnInitialize()
    -- Even a stale state must not start inspecting on Forever.
    addon.inArena = true
    addon.Inspect:QueueUnit("party1")
    assert(#addon.Inspect.queue == 0 and addon.Inspect.pendingUnit == nil)
    assert(not events.INSPECT_READY)
    assert(not addon.modules.FriendlyIdentity.hookedCompactFrames)
    assert(not addon.modules.FriendlyIdentity.hookedTargetFrame)
    _G.CompactUnitFrame_UpdateName = nil
    _G.TargetFrame_Update = nil
end)

test("reset uses client defaults without changing the default tables", function()
    for _, client in ipairs({ "retail", "forever" }) do
        local addon = loadAddon(nil, client)
        addon.db.friendlyIdentity.enabled = not addon.DEFAULTS.friendlyIdentity.enabled
        addon.db.partyTargetHighlight.thickness = 12
        addon:ResetToDefaults()
        assert(addon.db.friendlyIdentity.enabled == addon.supportsArena)
        assert(addon.db.partyTargetHighlight.arenaOnly == addon.supportsArena)
        assert(addon.db.partyTargetHighlight.thickness == 5)
        addon.db.partyTargetHighlight.color[1] = 0
        assert(addon.DEFAULTS.partyTargetHighlight.color[1] == 0.35)
    end
end)

test("Forever disables arena controls while keeping highlight controls usable", function()
    local addon = loadAddon(nil, "forever")
    local ui = addon.SettingsUI
    local function control()
        return { SetControlEnabled = function(self, value) self.enabled = value end }
    end
    ui.fiEnabled, ui.highlightEnabled, ui.arenaOnly = control(), control(), control()
    ui.nameplateHighlightEnabled = control()
    ui.fiChildren = { control() }
    ui.highlightChildren = { ui.arenaOnly, control() }
    ui.nameplateHighlightChildren = { control() }
    ui.statusText = { SetText = function(self, value) self.value = value end }
    ui:RefreshControls()
    assert(not ui.fiEnabled.enabled and not ui.fiChildren[1].enabled)
    assert(not ui.arenaOnly.enabled)
    assert(ui.highlightEnabled.enabled and ui.highlightChildren[2].enabled)
    assert(ui.nameplateHighlightEnabled.enabled and ui.nameplateHighlightChildren[1].enabled)
    assert(ui.statusText.value:find("WoW: Forever", 1, true))
end)

test("both clients move and clear the nameplate highlight on target changes", function()
    for _, client in ipairs({ "retail", "forever" }) do
        local addon = loadAddon(nil, client)
        local highlight = addon.modules.NameplateTargetHighlight
        local first = { IsShown = function() return true end }
        local second = { IsShown = function() return true end }
        local target = first
        _G.C_NamePlate = { GetNamePlateForUnit = function(unit)
            assert(unit == "target")
            return target
        end }
        highlight.Show = function(_, plate) plate.highlighted = true end
        highlight.Hide = function(_, plate) plate.highlighted = false end
        highlight:Sync()
        assert(first.highlighted)
        target = second
        highlight:Sync()
        assert(not first.highlighted and second.highlighted)
        target = nil
        highlight:Sync()
        assert(not second.highlighted and highlight.activePlate == nil)
        target = first
        addon.db.nameplateTargetHighlight.enabled = false
        highlight:Sync()
        assert(not first.highlighted)
    end
    _G.C_NamePlate = nil
end)

print(string.format("%d tests passed", passed))
