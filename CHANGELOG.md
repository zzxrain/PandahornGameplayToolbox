# Changelog

## 0.6.0

### Compatibility

- Updated the Retail interface declaration to `120105` for World of Warcraft Retail 12.1.5.
- Added WoW: Forever 1.60.1 support with interface `16001`. One release ZIP and manifest serve both clients.
- Detect Forever using its 1.60.x version string and interface range, rather than assuming that modern PvP APIs identify Retail.
- Updated the addon runtime and manifest version together.

### WoW: Forever behavior

- Friendly Identity is disabled by default and unavailable because Forever has no arenas.
  Its name-replacement hooks and specialization inspection service are not initialized on this client.
- Party / raid-style party frame target highlighting defaults to all zones. An arena-only
  setting imported from Retail is ignored on Forever, so it cannot leave the feature permanently inactive.
- Nameplate target highlighting remains independently configurable for friendly and enemy targets.
- The Settings panel identifies the active client and disables unavailable Friendly Identity
  and Arena only controls. Status output reports their effective availability.
- Do not register arena match start/end events on Forever, and skip arena detection APIs.

### Fixes

- Corrected the Party Target Highlight combat-end callback signature. The
  `PLAYER_REGEN_ENABLED` event now checks whether a deferred resync is actually
  pending before scheduling work, while still creating highlights deferred during combat.

### Development and validation

- Added a Lua 5.1 regression suite for version metadata, saved preference preservation,
  arena-only highlighting, combat-end resynchronization, identity formatting, module loading,
  and arena API fallbacks. Forever checks cover defaults, reset behavior, imported settings,
  disabled controls, inspection suppression, and nameplate target transitions on both clients.
- Updated the developer guide and in-game checklist for this version.
- Release packages continue to contain only the manifest, seven runtime Lua files,
  and the addon icon. Documentation and tests are excluded.

### Upgrade notes and limitations

- Existing SavedVariables and user preferences are preserved; no settings reset is required.
- The SavedVariables schema remains version 4. Reset to defaults uses the current client's
  defaults; stored Retail preferences are retained when loaded on Forever.
- Friendly Identity retains its Retail arena-only behavior, and Retail party highlighting
  remains arena-only by default.
- Mocked Lua checks do not replace validation in a live WoW client. Settings rendering,
  Retail arena transitions, Forever gameplay, combat restrictions, and third-party frame compatibility still require
  the in-game checks in `TESTING.md`.

## 0.5.1

- Renamed the addon to Pandahorn Gameplay Toolbox, including its manifest, code namespace, SavedVariables table, callback identifiers, UI text, and documentation.
- Removed the `/pgt` and `/pandahorngameplay` slash commands and their documentation; configuration is available through Blizzard Settings.
- Kept status printing in the Settings UI and removed command-only settings shortcuts.
- Added an in-game addon-list icon.
- Added an executable macOS-compatible Shell packaging script that includes only the manifest, Lua runtime files, and addon icon, with file and path validation.
- Simplified the English README with four smaller screenshots covering arena teammate names, party frame target highlighting, and nameplate target highlighting.
- Moved packaging, architecture, and implementation notes into a separate developer guide.
- Removed in-game screenshot preview buttons and preview textures; screenshots remain documentation-only and are excluded from release packages.
- Preserved existing gameplay behavior and settings fields.

## 0.4.0

- Added Settings UI controls for Party / Raid Frame highlight color, thickness, and contrast.
- Added separate Settings UI controls for nameplate highlight color, thickness, and contrast.
- Made nameplate border/glow visibility and visual styling independent from Party / Raid Frame highlighting.
- Preserved existing core identity masking and event-driven target detection behavior.

## 0.3.0

- Added an independent current-target nameplate highlight for enemy and friendly nameplates.
- Matched the existing Party Target Highlight strong-border and outer-glow style.
- Added a Settings UI toggle for the nameplate highlight.
- Added a high-level overlay designed to stay prominent with nameplate skinning addons such as BetterBlizzPlates.
- Kept updates event-driven with a single active-nameplate reference and no per-frame nameplate scan.

## 0.2.1

- Fixed a WoW 12.1 Settings tooltip error caused by the legacy multi-argument `GameTooltip:SetText(text, r, g, b, wrap)` call.
- Tooltips now use `GameTooltip:SetText(text)` for compatibility with the 12.1 runtime signature.
- No SavedVariables migration is required; all 0.2.0 settings are preserved.

## 0.2.0

- Added `Settings -> AddOns -> Pandahorn Gameplay Toolbox` configuration page.
- Added GUI controls for Friendly Identity, party/target frame masking, name template, party prefix, fallback text and diagnostics.
- Added quick identity-format presets while retaining editable `{spec}`, `{class}`, `{party}` templates.
- Integrated `SimplePartyHighlight` as the new modular `PartyTargetHighlight` feature.
- Party Target Highlight keeps the Blizzard `selectionHighlight:IsShown()` based selection detection to avoid unnecessary target identity API calls.
- Added Arena-only toggle plus independent strong-border and outer-glow toggles for Party Target Highlight.
- Improved Friendly Identity handling for Blizzard compact raid-style party frames.
- Improved party-number resolution using GUID matching before falling back to `UnitIsUnit()`.
- Added ordered module initialization for easier future expansion.
- Added reset-to-defaults support.

## 0.1.0

- Initial framework for Pandahorn Gameplay Toolbox.
- Arena-only Friendly Identity module.
- Party-frame teammate name replacement, excluding the player.
- Friendly target-frame name replacement.
- Inspect queue and specialization cache.
- Configurable `{spec}`, `{class}`, `{party}` format tokens.
- Patch 12.1 / Interface 120100 metadata.
