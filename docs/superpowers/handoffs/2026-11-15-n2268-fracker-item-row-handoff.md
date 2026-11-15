# N2268 Fracker Sand Item Row (consumeItem sand) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave dynamic/special, coordinator lượt 8).

## What this slice did

Sand item consumer row in `SourceFrackerBuildState.gd` (fracker def Blocks.java:2965-2978; `consumeItem(Items.sand)` :2976; `itemUseTime = 60f` :2974; `ConsumeItems.efficiency` BINARY 1/0, ConsumeItems.java:51-53; REQUIRED row → first pass, min + shouldConsumePower, BuildingComp.java:1969-1976 / :1972-1973). Pure `source_fracker_item_consumer_row_state` (BINARY via `inventory.item_count`) → `required_results` (after the liquid row). NO removal, advance untouched — the only sand removal stays the N2224 advance.

## Key facts for the next agent

**Verified line numbers**: `ItemModule.has` :153-158; GDScript guard :221 is the N2255 liquid-row guard, the N2207 gate guard is :151; sync :361. **The catalog DOES carry consumeItem for fracker** (oil-extractor consumeItem sand) — the SCOPE said "no consumeItem" (wrong); stacks come from the catalog (WallCrafter precedent). **FrackerBuild does NOT override `consumeTriggerValid`** (only ConsumeGeneratorBuild does, :152). Register: 18 exact exprs, all grep-verified verbatim. DEFERRED: 288 (289 − 1 resolved; the "Fracker item intake" entry stays with its cross-ref updated to the live N2268 row). Slice commit `47f89c86` (branch `slice/N2268-fracker-item-row`, đã push). Integration cherry-pick `afc6304c`.

## Godot debt (this slice)

`C07FrackerItemRowProof` — 6 keys: item_row_binary_sand, item_row_zero_no_sand, item_row_folds_required_min, sand_row_blocks_power_when_starved, advance_removal_unchanged, live_tick_folds_sand_row. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
