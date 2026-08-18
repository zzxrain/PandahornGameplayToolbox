# Pandahorn PVP Helper

A lightweight, modular World of Warcraft Retail PvP helper designed for Midnight / Patch 12.1.

## Version 0.2.1

### 1. Friendly Identity

Arena-only identity masking for friendly players.

- Party / raid-style party frames: replace teammate names while keeping your own name by default.
- Friendly Target Frame: replace the friendly player's real name with the same identity format.
- Default format: `{spec} {class}` -> `Holy Pal`.
- Configurable tokens: `{spec}`, `{class}`, `{party}`.
- Specialization lookup is cached by GUID and populated through the inspect API.
- If specialization data is not ready, the addon falls back to class / party number / `Ally`; it does not intentionally reveal the teammate's real name while masking is active.

### 2. Party Target Highlight

Integrated from the standalone `SimplePartyHighlight` prototype as a separate PPH module.

- Highlights the Blizzard compact party/raid frame that represents your current target.
- Uses Blizzard's existing `frame.selectionHighlight:IsShown()` state rather than directly re-evaluating target identity with `UnitIsUnit()`.
- Strong border + outer glow visual style.
- Default: enabled and **arena-only**.
- Settings allow border/glow to be enabled independently.

### 3. Settings UI

Open:

`Esc -> Options -> AddOns -> Pandahorn PVP Helper`

or:

`/pph settings`

Settings are applied immediately.

Available sections:

- General
- Friendly Identity
- Name Format
- Party Target Highlight
- Diagnostics

## Installation

Copy the `PandahornPVPHelper` folder to:

`World of Warcraft/_retail_/Interface/AddOns/`

If you previously installed the standalone `SimplePartyHighlight`, disable or remove it after installing PPH 0.2.1 to avoid duplicate target highlight visuals.

## Name format examples

| Template | Example |
|---|---|
| `{spec} {class}` | `Holy Pal` |
| `{spec} {class} {party}` | `Holy Pal P1` |
| `{class} {party}` | `Pal P1` |
| `{party} {spec} {class}` | `P1 Holy Pal` |
| `{spec}-{class}-{party}` | `Holy-Pal-P1` |

`{party}` maps to the WoW `party1` / `party2` / ... unit token number. If another addon visually re-sorts party frames, the token number may not equal the visible top-to-bottom position.

## Commands

- `/pph settings`
- `/pph status`
- `/pph on` / `/pph off`
- `/pph party on` / `/pph party off`
- `/pph target on` / `/pph target off`
- `/pph format spec class`
- `/pph format spec class party`
- `/pph format {spec} {class} {party}`
- `/pph partyprefix P`
- `/pph partyprefix none`
- `/pph fallback Ally`
- `/pph highlight on` / `/pph highlight off`
- `/pph highlight arena on` / `/pph highlight arena off`
- `/pph highlight border on` / `/pph highlight border off`
- `/pph highlight glow on` / `/pph highlight glow off`
- `/pph preview`
- `/pph debug on` / `/pph debug off`
- `/pph reset`

## Architecture

- `Core.lua` - lifecycle, ordered module initialization, SavedVariables, arena detection, callback bus and secret-value helpers.
- `Data/Specs.lua` - specialization/class abbreviation data.
- `Services/Inspect.lua` - throttled inspect queue and GUID -> specialization cache.
- `Modules/FriendlyIdentity.lua` - party/target identity masking and format tokens.
- `Modules/PartyTargetHighlight.lua` - current-target party frame border/glow module.
- `UI/Settings.lua` - Blizzard Settings -> AddOns configuration page.
- `Commands.lua` - slash-command configuration and diagnostics.

Future functionality should be implemented as independent modules under `Modules/` and registered through `PPH:RegisterModule()`.
