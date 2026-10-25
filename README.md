# Pandahorn PVP Helper

A lightweight, modular helper for World of Warcraft Retail (Midnight) and WoW: Forever.

## Version 0.5.1

### Supported clients

- Retail / Midnight (`standard`, Interface `120100` / `120105`)
- WoW: Forever 1.60.x (`camelot`, Interface `16001`)

Forever uses a Mainline-derived UI/API, but its interface number and game type are different. PPH detects Forever from its `16000` interface range and avoids assuming that every Retail gameplay system is available.

### 1. Friendly Identity

Identity masking for friendly players. It is enabled by default and arena-only on Retail. On Forever it defaults to disabled because arenas are not currently available; users may explicitly enable it for ordinary groups.

- Party / raid-style party frames: replace teammate names while keeping your own name by default.
- Friendly Target Frame: replace the friendly player's real name with the same identity format.
- Default format: `{spec} {class}` -> `Holy Pal`.
- Configurable tokens: `{spec}`, `{class}`, `{party}`.
- On Retail, specialization lookup is cached by GUID and populated through the inspect API.
- On Forever, the addon uses class and party-number fallbacks instead of interpreting Forever progression data as Retail specialization IDs.
- If specialization data is not ready, the addon falls back to class / party number / `Ally`; it does not intentionally reveal the teammate's real name while masking is active.

### 2. Party Target Highlight

Integrated from the standalone `SimplePartyHighlight` prototype as a separate PPH module.

- Highlights the Blizzard compact party/raid frame that represents your current target.
- Uses Blizzard's existing `frame.selectionHighlight:IsShown()` state rather than directly re-evaluating target identity with `UnitIsUnit()`.
- Strong border + outer glow visual style with configurable color, thickness, and contrast.
- Default on Retail: enabled and **arena-only**.
- On Forever, the unavailable arena restriction is ignored and the setting is disabled in the UI.
- Settings allow border/glow to be enabled independently.

### 3. Nameplate Target Highlight

- Highlights the nameplate belonging to the current target, for both enemies and friendlies.
- Has its own independently configurable border/glow, color, thickness, and contrast settings.
- Runs independently from Party Target Highlight and has its own Settings UI toggle.
- Uses event-driven target/nameplate updates instead of an `OnUpdate` scan.
- The independent high-level overlay is designed to remain prominent with nameplate skins such as BetterBlizzPlates.

### 4. Settings UI

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
- Nameplate Target Highlight
- Diagnostics

## Installation

Copy the `PandahornPVPHelper` folder to the client-specific AddOns directory:

- Retail: `World of Warcraft/_retail_/Interface/AddOns/`
- Forever beta: `World of Warcraft/_classic_beta_/Interface/AddOns/`

If you previously installed the standalone `SimplePartyHighlight`, disable or remove it after installing PPH 0.5.1 to avoid duplicate target highlight visuals.

## Configuration compatibility

The addon uses the same `PandahornPVPHelperDB` SavedVariables schema and the same Settings UI on Retail and Forever. No Lua-file editing or configuration conversion is required. Existing 0.4.x values are filled forward to schema version 5 without deleting user choices.

Friendly Identity's client-specific default only applies when that setting does not already exist: enabled on Retail and disabled on Forever. An existing SavedVariables choice is preserved during upgrade.

Retail and Forever installations normally keep their WTF/SavedVariables files in different client folders, so settings do not automatically synchronize between them. Copying the SavedVariables file is structurally supported, but gameplay-dependent behavior differs:

- `arenaOnly` is retained for Retail but ignored on Forever.
- `{spec}` is populated from Retail specialization inspection; on Forever it is empty unless a compatible specialization source becomes available, so `{class}` and `{party}` are the reliable tokens.
- Colors, thickness, contrast, enable states, name format, prefix, and fallback text have the same meaning on both clients.

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

- `Core.lua` - lifecycle, client capability detection, ordered module initialization, SavedVariables, arena detection, callback bus and secret-value helpers.
- `Data/Specs.lua` - specialization/class abbreviation data.
- `Services/Inspect.lua` - throttled inspect queue and GUID -> specialization cache.
- `Modules/FriendlyIdentity.lua` - party/target identity masking and format tokens.
- `Modules/PartyTargetHighlight.lua` - current-target party frame border/glow module.
- `Modules/NameplateTargetHighlight.lua` - event-driven enemy/friendly current-target nameplate border/glow module.
- `UI/Settings.lua` - Blizzard Settings -> AddOns configuration page.
- `Commands.lua` - slash-command configuration and diagnostics.

Future functionality should be implemented as independent modules under `Modules/` and registered through `PPH:RegisterModule()`.
