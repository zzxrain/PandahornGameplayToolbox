# Pandahorn Gameplay Toolbox

A lightweight World of Warcraft Retail PvP addon for identifying teammates and spotting your current target.

## Arena teammate names

In arenas, replace teammate names on party frames and the friendly Target Frame with specialization and class, such as `Holy Pal`. Your own name stays unchanged by default; normal names return when you leave the arena.

<img src="assets/previews/Arena_Party_Frame_Rename.png" alt="Arena teammate names" width="240">

## Party frame target highlight

Highlight your selected teammate on Blizzard party / raid-style party frames. Arena-only by default, with an option to enable it elsewhere.

<img src="assets/previews/Party_Raid_Frame_Highlight.png" alt="Party frame target highlight" width="280">

## Nameplate target highlight

Add a clear border and glow to your current enemy or friendly target's nameplate. Configure it independently from party frame highlighting, including color and thickness.

<img src="assets/previews/Target_HighLight_1.png" alt="Nameplate target highlight example 1" width="240">
<img src="assets/previews/Target_HighLight_2.png" alt="Nameplate target highlight example 2" width="360">

## Installation and settings

Extract the release ZIP into `World of Warcraft/_retail_/Interface/AddOns/`, with the addon inside a `PandahornGameplayToolbox` folder.

Open **Esc → Options → AddOns → Pandahorn Gameplay Toolbox** to adjust feature toggles, name formats, and highlight styles. Changes apply immediately.

If you use the old standalone `SimplePartyHighlight` addon, disable it to avoid duplicate highlights.
