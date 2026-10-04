# Pandahorn PVP Helper 0.4.0 - In-game Test Checklist

Because the addon cannot be executed against a real WoW client in this build environment, use this checklist for the first arena session.

## A. Settings registration

1. Log in with PPH enabled.
2. Open `Esc -> Options -> AddOns -> Pandahorn PVP Helper`.
3. Confirm all sections render without Lua errors.
4. Run `/pph settings` and confirm it opens the same category.

## B. Friendly Identity - outside arena

1. Join a normal party outside an arena.
2. Confirm teammate names remain unchanged.
3. Target a friendly party member and confirm the normal Target Frame name remains unchanged.

## C. Friendly Identity - arena

1. Enter an Arena Skirmish / rated arena.
2. Confirm your own name remains unchanged.
3. Confirm teammate compact-frame names change to the configured identity format.
4. Default expected examples: `Holy Pal`, `Disc Priest`, `Arms War`.
5. Target a friendly teammate and confirm the Target Frame uses the same identity format.
6. Target yourself and confirm your own real name remains visible.
7. Target an enemy and confirm the enemy name is not modified by Friendly Identity.
8. Leave the arena and confirm friendly real names are restored.

## D. Name Format settings

1. Set template to `{spec} {class} {party}` and expect e.g. `Holy Pal P1`.
2. Set template to `{party} {spec} {class}` and expect e.g. `P1 Holy Pal`.
3. Set Party Prefix to empty and expect party token values such as `1`, `2`.
4. Verify Quick Preset buttons update the preview and in-arena names.

## E. Party Target Highlight

1. In arena, target teammate #1.
2. Confirm the corresponding Blizzard compact party/raid-style frame gets a strong border and outer glow.
3. Change target to teammate #2 and confirm the highlight moves.
4. Clear target and confirm no teammate remains highlighted.
5. Toggle `Show strong border` and `Show outer glow` independently.
6. Leave arena with `Arena only` enabled and confirm custom highlight disappears.
7. Disable `Arena only`, target a teammate outside arena, and confirm the highlight can work outside arena.
8. Change Party / Raid Frame highlight color, thickness, and contrast; confirm each change applies immediately.

## F. Nameplate Target Highlight

1. Enable enemy and friendly nameplates, then enable `Nameplate Target Highlight` in PPH Settings.
2. Target an enemy with a visible nameplate and confirm its health bar gets the same strong border and outer glow as Party Target Highlight.
3. Target a friendly unit with a visible nameplate and confirm the same effect appears.
4. Switch rapidly between visible targets and confirm the old highlight is removed and only the current target remains highlighted.
5. Clear the target and confirm the highlight disappears.
6. Disable the nameplate feature and confirm it disappears without disabling Party Target Highlight.
7. Disable Party Target Highlight while leaving the nameplate feature enabled and confirm the nameplate feature still works.
8. Change the nameplate color, thickness, and contrast and confirm these settings apply immediately.
9. Give Party / Raid Frames and nameplates visibly different styles, then confirm each retains its independent configuration.

## G. Compatibility / diagnostics

1. If the standalone `SimplePartyHighlight` addon is installed, disable it before testing PPH 0.3.0 to avoid duplicate visuals.
2. Test with BetterBlizzFrames enabled if that is part of your UI stack.
3. Test with BetterBlizzPlates enabled, including with its own target indicator enabled, and confirm the PPH border/glow stays visible above the nameplate skin.
4. Resize nameplates through BetterBlizzPlates and confirm the PPH highlight remains anchored to the health bar.
5. Keep BugSack + BugGrabber enabled for the first few matches.
6. If an error occurs, capture the full Lua stack plus the action that triggered it.
7. `/pph debug on` can be used for additional state messages.

## 0.2.1 Regression

- Hover several Settings controls and verify the tooltip opens without a Lua error.
