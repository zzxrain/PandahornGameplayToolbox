# Changelog

## 0.5.1

- Changed Friendly Identity to default to disabled on new WoW: Forever installations while retaining the existing Retail default.
- Kept Friendly Identity available as an opt-in Forever feature for users who still want class/party masking in ordinary groups.
- Confirmed Retail 12.1.5 loading metadata through Interface `120105`.

## 0.5.0

- Added WoW: Forever (`camelot`, Interface `16001`) loading support alongside Retail.
- Added runtime Forever detection and capability-based handling instead of treating the five-digit interface number as a Classic client.
- Bypassed arena-only restrictions on Forever, where arenas are not currently available, so friendly identity and party-frame highlighting remain usable in ordinary groups.
- Avoided Retail specialization inspection on Forever; identity formatting safely falls back to class, party number, or configured fallback text.
- Made event registration tolerant of client-specific missing events and stopped registering Retail PvP match events on Forever.
- Documented cross-client SavedVariables compatibility and the gameplay-specific differences between Retail and Forever.

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

- Added `Settings -> AddOns -> Pandahorn PVP Helper` configuration page.
- Added `/pph settings` shortcut.
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

- Initial framework for Pandahorn PVP Helper.
- Arena-only Friendly Identity module.
- Party-frame teammate name replacement, excluding the player.
- Friendly target-frame name replacement.
- Inspect queue and specialization cache.
- Configurable `{spec}`, `{class}`, `{party}` format tokens.
- Patch 12.1 / Interface 120100 metadata.
