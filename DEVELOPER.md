# Development and maintenance

Technical notes for addon maintainers. User instructions and screenshots are in [README](README.md).

## Runtime and validation

The current addon version is 0.4.0, targeting WoW Retail 12.1 with `Interface: 120100`.
The cloud environment has no WoW client; Lua loading and mocked checks cannot replace in-game validation.
Before releasing, follow [TESTING.md](TESTING.md) to check settings, arena behavior, and third-party addon compatibility.
Use BugSack / BugGrabber to capture full Lua error stacks.

## Packaging

On macOS, use the built-in Bash and `zip` tools; no Python is required. From the repository root:

```sh
./scripts/package.sh
```

The script also works from other working directories. It reads the version and Lua file list from the `.toc`
and includes the addon-local icon referenced by `## IconTexture:`.
Output: `dist/PandahornGameplayToolbox-<version>.zip`, with `PandahornGameplayToolbox/` as the top-level folder.
The current package contains only the manifest, seven Lua files, and `Media/addon_icon.tga`: nine files total.

The script validates files and paths, rejects symlinks, and replaces the previous ZIP only after packaging succeeds.
Documentation, source screenshots, Git metadata, scripts, and development outputs are excluded.

## Image resources

- `Media/addon_icon.tga`: in-game addon-list icon, referenced by the manifest's `IconTexture` field.
- `assets/previews/*.png`: original screenshots for the README only. HTML width attributes reduce their displayed size without modifying the source images.

## Architecture

| File | Responsibility |
| --- | --- |
| `Core.lua` | Lifecycle, ordered module initialization, SavedVariables, arena detection, callbacks, and secret-value helpers |
| `Data/Specs.lua` | Specialization and class abbreviations |
| `Services/Inspect.lua` | Throttled inspect queue and GUID-to-specialization cache |
| `Modules/FriendlyIdentity.lua` | Party / target identity masking and format parsing |
| `Modules/PartyTargetHighlight.lua` | Current-target party frame border and glow |
| `Modules/NameplateTargetHighlight.lua` | Current-target nameplate highlighting |
| `UI/Settings.lua` | Blizzard Settings configuration page |

Register independent modules through `PGT:RegisterModule()`.
Settings are stored in `PandahornGameplayToolboxDB`, currently with `dbVersion = 4`.
Initialization preserves existing settings and fills in missing defaults.

## Behavior details

Friendly Identity runs only in arenas. Specializations come from the inspect API and are cached by GUID.
Until specialization data is available, labels fall back to class, party number, or `Ally` to avoid revealing teammate names while masking is active.

Party Target Highlight uses Blizzard's `selectionHighlight:IsShown()` state to avoid extra `UnitIsUnit()` calls.
Nameplate highlighting is event-driven, retains a single active-nameplate reference, and does not scan every frame.
Its independent high-level overlay is designed to work with skins such as BetterBlizzPlates; verify compatibility in-game.

Name formats support `{spec}`, `{class}`, and `{party}`:

| Template | Example |
| --- | --- |
| `{spec} {class}` | `Holy Pal` |
| `{spec} {class} {party}` | `Holy Pal P1` |
| `{class} {party}` | `Pal P1` |
| `{party} {spec} {class}` | `P1 Holy Pal` |
| `{spec}-{class}-{party}` | `Holy-Pal-P1` |

`{party}` maps to unit tokens such as `party1` and `party2`; addons that reorder frames may display them in a different order.
