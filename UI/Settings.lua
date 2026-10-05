local _, PGT = ...

local SettingsUI = {
    controls = {},
    panel = nil,
    category = nil,
    categoryID = nil,
}

PGT.SettingsUI = SettingsUI

local function AddTooltip(frame, text)
    if not text or text == "" then
        return
    end

    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function CreateSection(parent, text, x, y)
    local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    label:SetText(text)

    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(0.35, 0.35, 0.35, 0.5)
    line:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
    line:SetSize(650, 1)

    return label
end

local function CreateCheckbox(parent, labelText, tooltip, x, y, getter, setter)
    local check = CreateFrame("CheckButton", nil, parent)
    check:SetSize(24, 24)
    check:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
    check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

    local text = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("LEFT", check, "RIGHT", 4, 0)
    text:SetJustifyH("LEFT")
    text:SetText(labelText)
    check.label = text

    check.getter = getter
    check.setter = setter

    check:SetScript("OnClick", function(self)
        if self.setter then
            self.setter(self:GetChecked() and true or false)
            PGT:Refresh("settings")
        end
    end)

    AddTooltip(check, tooltip)

    function check:Refresh()
        if self.getter then
            self:SetChecked(self.getter() and true or false)
        end
    end

    function check:SetControlEnabled(enabled)
        if enabled then
            self:Enable()
            self:SetAlpha(1)
            self.label:SetTextColor(1, 1, 1)
        else
            self:Disable()
            self:SetAlpha(0.5)
            self.label:SetTextColor(0.6, 0.6, 0.6)
        end
    end

    return check
end

local function CreateEditBox(parent, labelText, tooltip, x, y, width, getter, setter)
    local label = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    label:SetText(labelText)

    local edit = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    edit:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 5, -6)
    edit:SetSize(width, 28)
    edit:SetAutoFocus(false)
    edit:SetTextInsets(6, 6, 0, 0)
    edit.getter = getter
    edit.setter = setter

    local function Commit(self)
        if not self.setter then
            return
        end
        local accepted = self.setter(self:GetText() or "")
        if accepted == false and self.getter then
            self:SetText(self.getter() or "")
        end
        PGT:Refresh("settings")
        self:ClearFocus()
    end

    edit:SetScript("OnEnterPressed", Commit)
    edit:SetScript("OnEscapePressed", function(self)
        if self.getter then
            self:SetText(self.getter() or "")
        end
        self:ClearFocus()
    end)
    edit:SetScript("OnEditFocusLost", function(self)
        if self:IsShown() then
            Commit(self)
        end
    end)

    AddTooltip(edit, tooltip)

    function edit:Refresh()
        if self.getter and not self:HasFocus() then
            self:SetText(self.getter() or "")
        end
    end

    function edit:SetControlEnabled(enabled)
        if enabled then
            self:Enable()
            self:SetAlpha(1)
            label:SetTextColor(1, 1, 1)
        else
            self:Disable()
            self:SetAlpha(0.5)
            label:SetTextColor(0.6, 0.6, 0.6)
        end
    end

    return edit, label
end

local function CreateButton(parent, text, x, y, width, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    button:SetSize(width, 24)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

local function CreateSlider(parent, labelText, tooltip, x, y, width, minimum, maximum, step, getter, setter)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    slider:SetSize(width, 18)
    slider:SetMinMaxValues(minimum, maximum)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider.getter = getter
    slider.setter = setter

    slider.Text:SetText(labelText)
    slider.Low:SetText(tostring(minimum))
    slider.High:SetText(tostring(maximum))
    AddTooltip(slider, tooltip)

    slider:SetScript("OnValueChanged", function(self, value, userInput)
        value = math.floor((value / step) + 0.5) * step
        self.Text:SetText(labelText .. ": " .. value)
        if userInput and self.setter then
            self.setter(value)
            PGT:Refresh("settings")
        end
    end)

    function slider:Refresh()
        local value = self.getter and self.getter() or minimum
        self:SetValue(value)
        self.Text:SetText(labelText .. ": " .. value)
    end

    function slider:SetControlEnabled(enabled)
        self:SetEnabled(enabled)
        self:SetAlpha(enabled and 1 or 0.5)
    end

    return slider
end

local function CreateColorButton(parent, labelText, tooltip, x, y, getter, setter)
    local button = CreateFrame("Button", nil, parent)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    button:SetSize(170, 24)

    local swatch = button:CreateTexture(nil, "ARTWORK")
    swatch:SetPoint("LEFT", button, "LEFT", 2, 0)
    swatch:SetSize(20, 20)
    swatch:SetColorTexture(1, 1, 1, 1)

    local border = button:CreateTexture(nil, "BACKGROUND")
    border:SetPoint("TOPLEFT", swatch, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", swatch, "BOTTOMRIGHT", 1, -1)
    border:SetColorTexture(0.15, 0.15, 0.15, 1)

    local label = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    label:SetPoint("LEFT", swatch, "RIGHT", 8, 0)
    label:SetText(labelText)
    button.getter = getter
    button.setter = setter
    AddTooltip(button, tooltip)

    function button:Refresh()
        local color = self.getter and self.getter() or { 1, 1, 1 }
        swatch:SetColorTexture(color[1], color[2], color[3], 1)
    end

    function button:SetControlEnabled(enabled)
        self:SetEnabled(enabled)
        self:SetAlpha(enabled and 1 or 0.5)
    end

    button:SetScript("OnClick", function(self)
        local old = self.getter and self.getter() or { 1, 1, 1 }
        local previous = { old[1], old[2], old[3] }
        local function Apply()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            self.setter({ r, g, b })
            self:Refresh()
            PGT:Refresh("settings-color")
        end
        local info = {
            r = previous[1], g = previous[2], b = previous[3],
            hasOpacity = false,
            swatchFunc = Apply,
            cancelFunc = function()
                self.setter(previous)
                self:Refresh()
                PGT:Refresh("settings-color-cancel")
            end,
        }
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)

    return button
end

function SettingsUI:RegisterControl(control)
    table.insert(self.controls, control)
    return control
end

function SettingsUI:RefreshControls()
    if not PGT.db then
        return
    end

    for _, control in ipairs(self.controls) do
        if control.Refresh then
            control:Refresh()
        end
    end

    local globalEnabled = PGT.db.enabled
    local fi = PGT.db.friendlyIdentity
    local hi = PGT.db.partyTargetHighlight
    local ni = PGT.db.nameplateTargetHighlight

    if self.fiEnabled then
        self.fiEnabled:SetControlEnabled(globalEnabled)
    end
    local fiChildrenEnabled = globalEnabled and fi.enabled
    for _, control in ipairs(self.fiChildren or {}) do
        control:SetControlEnabled(fiChildrenEnabled)
    end

    if self.highlightEnabled then
        self.highlightEnabled:SetControlEnabled(globalEnabled)
    end
    local highlightChildrenEnabled = globalEnabled and hi.enabled
    for _, control in ipairs(self.highlightChildren or {}) do
        control:SetControlEnabled(highlightChildrenEnabled)
    end

    if self.nameplateHighlightEnabled then
        self.nameplateHighlightEnabled:SetControlEnabled(globalEnabled and ni ~= nil)
    end
    local nameplateChildrenEnabled = globalEnabled and ni and ni.enabled
    for _, control in ipairs(self.nameplateHighlightChildren or {}) do
        control:SetControlEnabled(nameplateChildrenEnabled)
    end

    if self.previewText then
        local module = PGT.modules.FriendlyIdentity
        local preview = module and module:GetPreview() or "Holy Pal"
        self.previewText:SetText("Preview: |cffffffff" .. preview .. "|r")
    end

    if self.statusText then
        self.statusText:SetText("Arena detected: " .. (PGT.inArena and "|cff55ff55YES|r" or "|cffffaa55NO|r"))
    end
end

function SettingsUI:BuildPanel()
    local panel = CreateFrame("Frame")
    panel.name = PGT.name
    self.panel = panel

    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 4)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(720, 1160)
    scroll:SetScrollChild(content)
    self.content = content

    panel:SetScript("OnSizeChanged", function(_, width)
        if width and width > 80 then
            content:SetWidth(width - 48)
        end
    end)

    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", content, "TOPLEFT", 18, -16)
    title:SetText(PGT.name)

    local version = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    version:SetPoint("LEFT", title, "RIGHT", 10, -2)
    version:SetText("v" .. PGT.version)

    local description = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    description:SetWidth(650)
    description:SetJustifyH("LEFT")
    description:SetText("Modular gameplay toolbox. Friendly identity masking is arena-only. Party target highlight can be limited to arenas or enabled everywhere.")

    CreateSection(content, "General", 18, -82)

    self.masterEnabled = self:RegisterControl(CreateCheckbox(
        content,
        "Enable Pandahorn Gameplay Toolbox",
        "Master switch for all PGT modules.",
        22, -116,
        function() return PGT.db.enabled end,
        function(value) PGT.db.enabled = value end
    ))

    CreateSection(content, "Friendly Identity", 18, -160)

    self.fiEnabled = self:RegisterControl(CreateCheckbox(
        content,
        "Enable Friendly Identity",
        "Replaces friendly player names with specialization/class identity text. This module only activates in arena instances.",
        22, -194,
        function() return PGT.db.friendlyIdentity.enabled end,
        function(value) PGT.db.friendlyIdentity.enabled = value end
    ))

    self.fiChildren = {}

    local partyFrames = self:RegisterControl(CreateCheckbox(
        content,
        "Replace teammate names on Party / Raid-style Party Frames",
        "Changes teammate names such as a Holy Paladin to the configured identity string.",
        46, -226,
        function() return PGT.db.friendlyIdentity.partyFrames end,
        function(value) PGT.db.friendlyIdentity.partyFrames = value end
    ))
    table.insert(self.fiChildren, partyFrames)

    local targetFrame = self:RegisterControl(CreateCheckbox(
        content,
        "Replace friendly player name on Target Frame",
        "When your target is a friendly player in arena, replace the real name with the same identity format.",
        46, -256,
        function() return PGT.db.friendlyIdentity.targetFrame end,
        function(value) PGT.db.friendlyIdentity.targetFrame = value end
    ))
    table.insert(self.fiChildren, targetFrame)

    local keepPlayer = self:RegisterControl(CreateCheckbox(
        content,
        "Keep my own player name",
        "Your own name remains unchanged when you target yourself or when your own compact frame is shown.",
        46, -286,
        function() return PGT.db.friendlyIdentity.keepPlayerName end,
        function(value) PGT.db.friendlyIdentity.keepPlayerName = value end
    ))
    table.insert(self.fiChildren, keepPlayer)

    CreateSection(content, "Name Format", 18, -334)

    local formatEdit = self:RegisterControl((CreateEditBox(
        content,
        "Identity template",
        "Available tokens: {spec}, {class}, {party}. Example: {spec} {class} {party}",
        24, -366, 360,
        function() return PGT.db.friendlyIdentity.format end,
        function(value)
            local module = PGT.modules.FriendlyIdentity
            local normalized = module and module:NormalizeFormat(value) or nil
            if not normalized then
                PGT:Print("Invalid identity format. Valid tokens: {spec}, {class}, {party}.")
                return false
            end
            PGT.db.friendlyIdentity.format = normalized
            return true
        end
    )))
    table.insert(self.fiChildren, formatEdit)

    local presetY = -424
    local presetLabel = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    presetLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 24, presetY + 16)
    presetLabel:SetText("Quick presets")

    local function SetPreset(format)
        PGT.db.friendlyIdentity.format = format
        PGT:Refresh("settings-preset")
        SettingsUI:RefreshControls()
    end

    self.preset1 = CreateButton(content, "Spec + Class", 24, presetY - 4, 110, function()
        SetPreset("{spec} {class}")
    end)
    self.preset2 = CreateButton(content, "+ Party", 142, presetY - 4, 90, function()
        SetPreset("{spec} {class} {party}")
    end)
    self.preset3 = CreateButton(content, "Party first", 240, presetY - 4, 100, function()
        SetPreset("{party} {spec} {class}")
    end)
    self.preset4 = CreateButton(content, "Class + Party", 348, presetY - 4, 110, function()
        SetPreset("{class} {party}")
    end)

    local prefixEdit = self:RegisterControl((CreateEditBox(
        content,
        "Party number prefix",
        "Prefix used by {party}. Use P for P1/P2; leave empty for 1/2.",
        24, -470, 150,
        function() return PGT.db.friendlyIdentity.partyPrefix end,
        function(value)
            PGT.db.friendlyIdentity.partyPrefix = tostring(value or "")
            return true
        end
    )))
    table.insert(self.fiChildren, prefixEdit)

    local fallbackEdit = self:RegisterControl((CreateEditBox(
        content,
        "Fallback text",
        "Used when specialization/class/party information is not available yet. The addon never intentionally falls back to the teammate's real name while masking is active.",
        220, -470, 180,
        function() return PGT.db.friendlyIdentity.fallbackText end,
        function(value)
            value = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if value == "" then
                value = "Ally"
            end
            PGT.db.friendlyIdentity.fallbackText = value
            return true
        end
    )))
    table.insert(self.fiChildren, fallbackEdit)

    self.previewText = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    self.previewText:SetPoint("TOPLEFT", content, "TOPLEFT", 24, -534)
    self.previewText:SetText("Preview: |cffffffffHoly Pal|r")

    CreateSection(content, "Party Target Highlight", 18, -574)

    self.highlightEnabled = self:RegisterControl(CreateCheckbox(
        content,
        "Enable current-target highlight",
        "Adds a strong border/glow around the compact party/raid frame representing your current target.",
        22, -608,
        function() return PGT.db.partyTargetHighlight.enabled end,
        function(value) PGT.db.partyTargetHighlight.enabled = value end
    ))

    self.highlightChildren = {}

    local arenaOnly = self:RegisterControl(CreateCheckbox(
        content,
        "Arena only",
        "When enabled, the target highlight is hidden outside arena instances.",
        46, -640,
        function() return PGT.db.partyTargetHighlight.arenaOnly end,
        function(value) PGT.db.partyTargetHighlight.arenaOnly = value end
    ))
    table.insert(self.highlightChildren, arenaOnly)

    local showBorder = self:RegisterControl(CreateCheckbox(
        content,
        "Show strong border",
        "Show the inner high-contrast border around the selected teammate frame.",
        46, -670,
        function() return PGT.db.partyTargetHighlight.showBorder end,
        function(value) PGT.db.partyTargetHighlight.showBorder = value end
    ))
    table.insert(self.highlightChildren, showBorder)

    local showGlow = self:RegisterControl(CreateCheckbox(
        content,
        "Show outer glow",
        "Show the outer glow ring around the selected teammate frame.",
        46, -700,
        function() return PGT.db.partyTargetHighlight.showGlow end,
        function(value) PGT.db.partyTargetHighlight.showGlow = value end
    ))
    table.insert(self.highlightChildren, showGlow)

    local partyColor = self:RegisterControl(CreateColorButton(
        content, "Highlight color", "Choose the Party / Raid Frame target highlight color.",
        46, -732,
        function() return PGT.db.partyTargetHighlight.color end,
        function(value) PGT.db.partyTargetHighlight.color = value end
    ))
    table.insert(self.highlightChildren, partyColor)

    local partyThickness = self:RegisterControl(CreateSlider(
        content, "Thickness", "Controls the border and glow width in pixels.",
        250, -730, 150, 1, 12, 1,
        function() return PGT.db.partyTargetHighlight.thickness end,
        function(value) PGT.db.partyTargetHighlight.thickness = value end
    ))
    table.insert(self.highlightChildren, partyThickness)

    local partyContrast = self:RegisterControl(CreateSlider(
        content, "Contrast", "Controls highlight opacity and visual contrast.",
        450, -730, 150, 0, 100, 5,
        function() return PGT.db.partyTargetHighlight.contrast end,
        function(value) PGT.db.partyTargetHighlight.contrast = value end
    ))
    table.insert(self.highlightChildren, partyContrast)

    CreateSection(content, "Nameplate Target Highlight", 18, -790)

    self.nameplateHighlightEnabled = self:RegisterControl(CreateCheckbox(
        content,
        "Enable current-target highlight on nameplates",
        "Highlights the current enemy or friendly target's nameplate with an independently configurable style, layered above nameplate skins such as BetterBlizzPlates.",
        22, -824,
        function() return PGT.db.nameplateTargetHighlight.enabled end,
        function(value) PGT.db.nameplateTargetHighlight.enabled = value end
    ))

    self.nameplateHighlightChildren = {}

    local nameplateBorder = self:RegisterControl(CreateCheckbox(
        content, "Show strong border", "Show the inner high-contrast nameplate border.",
        46, -856,
        function() return PGT.db.nameplateTargetHighlight.showBorder end,
        function(value) PGT.db.nameplateTargetHighlight.showBorder = value end
    ))
    table.insert(self.nameplateHighlightChildren, nameplateBorder)

    local nameplateGlow = self:RegisterControl(CreateCheckbox(
        content, "Show outer glow", "Show the outer nameplate glow.",
        46, -886,
        function() return PGT.db.nameplateTargetHighlight.showGlow end,
        function(value) PGT.db.nameplateTargetHighlight.showGlow = value end
    ))
    table.insert(self.nameplateHighlightChildren, nameplateGlow)

    local nameplateColor = self:RegisterControl(CreateColorButton(
        content, "Highlight color", "Choose the nameplate target highlight color independently.",
        46, -918,
        function() return PGT.db.nameplateTargetHighlight.color end,
        function(value) PGT.db.nameplateTargetHighlight.color = value end
    ))
    table.insert(self.nameplateHighlightChildren, nameplateColor)

    local nameplateThickness = self:RegisterControl(CreateSlider(
        content, "Thickness", "Controls the nameplate border and glow width in pixels.",
        250, -916, 150, 1, 12, 1,
        function() return PGT.db.nameplateTargetHighlight.thickness end,
        function(value) PGT.db.nameplateTargetHighlight.thickness = value end
    ))
    table.insert(self.nameplateHighlightChildren, nameplateThickness)

    local nameplateContrast = self:RegisterControl(CreateSlider(
        content, "Contrast", "Controls nameplate highlight opacity and visual contrast.",
        450, -916, 150, 0, 100, 5,
        function() return PGT.db.nameplateTargetHighlight.contrast end,
        function(value) PGT.db.nameplateTargetHighlight.contrast = value end
    ))
    table.insert(self.nameplateHighlightChildren, nameplateContrast)

    CreateSection(content, "Diagnostics", 18, -976)

    self.debugControl = self:RegisterControl(CreateCheckbox(
        content,
        "Debug messages",
        "Print additional PGT state information to chat for troubleshooting.",
        22, -1010,
        function() return PGT.db.debug end,
        function(value) PGT.db.debug = value end
    ))

    self.statusText = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    self.statusText:SetPoint("TOPLEFT", content, "TOPLEFT", 270, -1016)

    CreateButton(content, "Reset defaults", 22, -1052, 120, function()
        PGT:ResetToDefaults()
        SettingsUI:RefreshControls()
        PGT:Print("Settings reset to defaults.")
    end)

    CreateButton(content, "Print status", 150, -1052, 110, function()
        if PGT.PrintStatus then
            PGT:PrintStatus()
        else
            PGT:Print("v" .. PGT.version .. " | arena=" .. tostring(PGT.inArena))
        end
    end)

    panel.OnRefresh = function()
        SettingsUI:RefreshControls()
    end

    panel.OnDefault = function()
        PGT:ResetToDefaults()
        SettingsUI:RefreshControls()
    end

    panel.OnCommit = function()
        PGT:Refresh("settings-commit")
    end

    panel:SetScript("OnShow", function()
        SettingsUI:RefreshControls()
    end)

    return panel
end

function SettingsUI:RegisterSettingsCategory()
    if self.category or not _G.Settings then
        return
    end

    local panel = self:BuildPanel()
    local category, layout = Settings.RegisterCanvasLayoutCategory(panel, PGT.name)
    if layout and layout.AddAnchorPoint then
        layout:AddAnchorPoint("TOPLEFT", 0, 0)
        layout:AddAnchorPoint("BOTTOMRIGHT", 0, 0)
    end
    Settings.RegisterAddOnCategory(category)

    self.category = category
    self.categoryID = category:GetID()
    PGT.settingsCategoryID = self.categoryID
end

function SettingsUI:Open()
    if self.categoryID and _G.Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(self.categoryID)
        return true
    end
    return false
end

function SettingsUI:OnConfigChanged()
    if self.panel and self.panel:IsShown() then
        self:RefreshControls()
    end
end

function SettingsUI:OnInitialize()
    self:RegisterSettingsCategory()
    PGT:RegisterCallback("PGT_CONFIG_CHANGED", self, "OnConfigChanged")
    PGT:RegisterCallback("PGT_SETTINGS_REFRESH", self, "OnConfigChanged")
end

PGT:RegisterModule("SettingsUI", SettingsUI)
