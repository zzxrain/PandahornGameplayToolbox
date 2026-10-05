# Pandahorn Gameplay Toolbox

A lightweight, modular World of Warcraft Retail gameplay toolbox designed for Midnight / Patch 12.1.

## Version 0.4.0

### 1. Friendly Identity

Arena-only identity masking for friendly players.

- Party / raid-style party frames: replace teammate names while keeping your own name by default.
- Friendly Target Frame: replace the friendly player's real name with the same identity format.
- Default format: `{spec} {class}` -> `Holy Pal`.
- Configurable tokens: `{spec}`, `{class}`, `{party}`.
- Specialization lookup is cached by GUID and populated through the inspect API.
- If specialization data is not ready, the addon falls back to class / party number / `Ally`; it does not intentionally reveal the teammate's real name while masking is active.

### 2. Party Target Highlight

Integrated from the standalone `SimplePartyHighlight` prototype as a separate PGT module.

- Highlights the Blizzard compact party/raid frame that represents your current target.
- Uses Blizzard's existing `frame.selectionHighlight:IsShown()` state rather than directly re-evaluating target identity with `UnitIsUnit()`.
- Strong border + outer glow visual style with configurable color, thickness, and contrast.
- Default: enabled and **arena-only**.
- Settings allow border/glow to be enabled independently.

### 3. Nameplate Target Highlight

- Highlights the nameplate belonging to the current target, for both enemies and friendlies.
- Has its own independently configurable border/glow, color, thickness, and contrast settings.
- Runs independently from Party Target Highlight and has its own Settings UI toggle.
- Uses event-driven target/nameplate updates instead of an `OnUpdate` scan.
- The independent high-level overlay is designed to remain prominent with nameplate skins such as BetterBlizzPlates.

### 4. Settings UI

Open:

`Esc -> Options -> AddOns -> Pandahorn Gameplay Toolbox`

Settings are applied immediately.

Use the **Preview** buttons beside Friendly Identity, Party Target Highlight,
and Nameplate Target Highlight to view example screenshots. The nameplate preview
shows both supplied examples. These are static examples, not live previews of your settings.

Available sections:

- General
- Friendly Identity
- Name Format
- Party Target Highlight
- Nameplate Target Highlight
- Diagnostics

## Installation

Copy the `PandahornGameplayToolbox` folder to:

`World of Warcraft/_retail_/Interface/AddOns/`

If you previously installed the standalone `SimplePartyHighlight`, disable or remove it after installing PGT 0.4.0 to avoid duplicate target highlight visuals.

## Packaging

On macOS, use the built-in Bash and `zip` tools; no Python installation is needed.
Run from the repository root:

```sh
bash scripts/package.sh
```

The script reads the version and runtime file list from `PandahornGameplayToolbox.toc`
and creates `dist/PandahornGameplayToolbox-<version>.zip`. It also works when invoked
from another working directory. The ZIP contains a single `PandahornGameplayToolbox/`
folder with only the manifest, its listed files, the `IconTexture`, and resources
declared using `# Package: <relative path>` comments in the manifest; documentation, Git metadata,
scripts, and development outputs are excluded. Missing or unsafe manifest paths
stop packaging before replacing an existing ZIP. Extract the ZIP into
`World of Warcraft/_retail_/Interface/AddOns/` to install.

`Media/addon_icon.tga` supplies the in-game addon-list icon. Game-ready preview
textures live under `Media/Previews/`; their original PNGs are kept under
`assets/previews/` and excluded from the ZIP. The TGA previews preserve the original
pixels on transparent power-of-two canvases; the UI crops the padding when displaying them.

## Name format examples

| Template | Example |
|---|---|
| `{spec} {class}` | `Holy Pal` |
| `{spec} {class} {party}` | `Holy Pal P1` |
| `{class} {party}` | `Pal P1` |
| `{party} {spec} {class}` | `P1 Holy Pal` |
| `{spec}-{class}-{party}` | `Holy-Pal-P1` |

`{party}` maps to the WoW `party1` / `party2` / ... unit token number. If another addon visually re-sorts party frames, the token number may not equal the visible top-to-bottom position.

## Architecture

- `Core.lua` - lifecycle, ordered module initialization, SavedVariables, arena detection, callback bus and secret-value helpers.
- `Data/Specs.lua` - specialization/class abbreviation data.
- `Services/Inspect.lua` - throttled inspect queue and GUID -> specialization cache.
- `Modules/FriendlyIdentity.lua` - party/target identity masking and format tokens.
- `Modules/PartyTargetHighlight.lua` - current-target party frame border/glow module.
- `Modules/NameplateTargetHighlight.lua` - event-driven enemy/friendly current-target nameplate border/glow module.
- `UI/Settings.lua` - Blizzard Settings -> AddOns configuration page.

Future functionality should be implemented as independent modules under `Modules/` and registered through `PGT:RegisterModule()`.
