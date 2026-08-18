# Pandahorn PVP Helper 0.2.1 - In-game Test Checklist

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

## F. Compatibility / diagnostics

1. If the standalone `SimplePartyHighlight` addon is installed, disable it before testing PPH 0.2.1 to avoid duplicate visuals.
2. Test with BetterBlizzFrames enabled if that is part of your UI stack.
3. Keep BugSack + BugGrabber enabled for the first few matches.
4. If an error occurs, capture the full Lua stack plus the action that triggered it.
5. `/pph debug on` can be used for additional state messages.

## 0.2.1 Regression

- Hover several Settings controls and verify the tooltip opens without a Lua error.
