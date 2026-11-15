# N2264 WallCrafter Second Consumers (large-cliff-crusher hydrogen 1f/60f required row + graphite booster item row) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave booster items, coordinator lượt 7).

## What this slice did

Hydrogen 1f/60f required row + graphite booster item row in `SourceWallCrafterBuildState.gd` (large-cliff-crusher, Blocks.java:3028-3032; `ConsumeLiquid.efficiency` :42-47, `update` :37-39; `ConsumeItems.efficiency` binary 1/0, ConsumeItems.java:51-53; booster `optional(true, true)` → optional pass BuildingComp.java:1980-1981; required folds in the first pass :1969-1976). Pure `source_wall_crafter_liquid_consumer_row_state` → `required_results`; pure `source_wall_crafter_item_consumer_row_state` → `optional_results`. The item row is computed OUTSIDE the consumption guard so `item_valid` stays live even when the machinery skips (cheating team). Direct hydrogen second-pass removal after `apply_update_consumption_state`; the N2223 advance is untouched. `_initial_frame` already had `"items": {}`.

## Key facts for the next agent

**Verified line numbers**: large-cliff-crusher hydrogen 1f/60f REQUIRED (NOT boosted) Blocks.java:3028 + graphite boost :3030, itemCapacity 20 :3031, boostItemUseTime 60f/0.75f = 80f :3032; itemValid (WallCrafter.java:191), eff *= lerp(1, 1.6f, hasLiquidBooster? optionalEfficiency: 0) * (itemValid? 1.6f: 1) (:205), timer-gated consume (:207-209) → DEFERRED (timer-infra); hasLiquidBooster = false for both defs (hydrogen not boosted, WallCrafter.java:106). **The "Fracker:139-144" cite is stale** — the liquid-row guard is SourceFrackerBuildState.gd:221 (gate :151); sync :361 is correct. **The N2170 driver docstring mislabeled WallCrafter hydrogen "as a booster" — corrected to a REQUIRED row.** The catalog carries NO `consumeItem` row for the graphite booster — the driver reads it via `SourceBlockMetadataState.block_booster_item(block)` as `boosterItem: "graphite"` (N2115 precedent); stacks explicit `[{"item": "graphite", "amount": 1}]`. Register: 22 exact exprs, all grep-verified verbatim. DEFERRED: 291 (293 − 2 resolved, 0 added; updateTile live-fill entry trimmed — `item_valid` now stamped live). NO live intake fills `frame["items"]` yet (Separator precedent); the timer-gated graphite consume stays deferred. Slice commit `041c31e7` (branch `slice/N2264-wall-crafter-second-consumers`, đã push). Integration cherry-pick `23b7c4c4`.

## Godot debt (this slice)

`C07WallCrafterSecondConsumersProof` — 6 keys: cliff_crusher_has_no_rows, graphite_row_folds_optional_when_absent, hydrogen_row_folds_min_when_starved, item_row_binary_one_when_present, item_valid_stamped_live, live_tick_removes_hydrogen_when_running. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
