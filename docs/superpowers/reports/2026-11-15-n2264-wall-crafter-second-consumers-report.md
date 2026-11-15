# N2264 WallCrafter Second Consumers (large-cliff-crusher hydrogen 1f/60f required row + graphite booster item row) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 7 — wave booster items, integration branch `integration/wave-booster-items-n2260-n2264`, base `22164673`).

## Source

Large-cliff-crusher def (Blocks.java:3028-3032): hydrogen 1f/60f REQUIRED (NOT boosted) + graphite boost (:3030), itemCapacity 20 (:3031), boostItemUseTime 60f/0.75f = 80f (:3032). `ConsumeLiquid.efficiency` :42-47 (ed = edelta × efficiencyScale, ed ≤ 1e-8 → 0, cap 1f); `update` :37-39. `ConsumeItems.efficiency` (ConsumeItems.java:51-53) is BINARY 1/0; `items.has(ItemStack[], float)` (ItemModule.java:153-158, check :154): EVERY stack must have `round(amount * multiplier)`. Booster = `optional(true, true)` (Consume.java:33-35) → optional pass (BuildingComp.java:1980-1981), cap by minEfficiency (:1986), zero when !update (:1992-1994); required folds in the first pass (:1969-1976). WallCrafter itemValid (:191), eff *= lerp(1, 1.6f, hasLiquidBooster? optionalEfficiency: 0) * (itemValid? 1.6f: 1) (:205), timer-gated consume (:207-209) → DEFERRED (timer-infra). hasLiquidBooster = false for both WallCrafter defs (hydrogen not boosted, WallCrafter.java:106). **Scope corrections (verified by grep): the "Fracker:139-144" cite is stale — the liquid-row guard is SourceFrackerBuildState.gd:221 (gate :151); sync :361 is correct. The N2170 driver docstring mislabeled WallCrafter hydrogen "as a booster" — corrected to a REQUIRED row.**

## Implementation

`SourceWallCrafterBuildState.gd`: pure `source_wall_crafter_liquid_consumer_row_state` (Fracker guard, ed ≤ 1e-8 → 0, cap 1f) → `required_results`; pure `source_wall_crafter_item_consumer_row_state` (BINARY 1.0/0.0 via `inventory.item_count`) → `optional_results`. The item row is computed OUTSIDE the consumption guard so `item_valid` stays live even when the machinery skips (cheating team). The catalog carries NO `consumeItem` row for the graphite booster — the driver reads it via `SourceBlockMetadataState.block_booster_item(block)` as `boosterItem: "graphite"` (N2115 precedent); stacks explicit `[{"item": "graphite", "amount": 1}]`. Direct hydrogen second-pass removal after `apply_update_consumption_state`; the N2223 advance is untouched. `_initial_frame` already had `"items": {}`. NO live intake fills `frame["items"]` yet (Separator precedent — the row reads the frame as-is, documented as a limit); the timer-gated graphite consume stays deferred.

## Commits

Slice `041c31e7` (worker-N2264, branch `slice/N2264-wall-crafter-second-consumers`, 5 files, +1149/−9, đã push, remote tip verified by ls-remote). Integration cherry-pick `23b7c4c4` on `integration/wave-booster-items-n2260-n2264` (base 22164673). No coordinator fix needed.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 22/22, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (power_status, should_consume, update_tile: 9/12 non-proof PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate run 2 (PID 1856, launch 22:29 by coordinator lượt 7, done 22:47 +07): Ran 6146 in 1091.013s, failures=213, skipped=5, 0 errors — 213/213 Godot-absent (208 inherited + 5 new proof tests N2260–N2264). Run 1 (PID 25034, launch 22:09) was killed by VM restart #5 ~22:27 after ~17.8 min, no footer.

## SSOT / DEFERRED

SSOT single-slice +5/+1/+2/+4 → 11737/1710/1633/3057 (2 pure functions → 2 contracts + 4 schemas); audit stays 1336. DEFERRED 291 (293 − 2 resolved, 0 added; updateTile live-fill entry trimmed — `item_valid` is now stamped live by N2264). Merged wave DEFERRED: 289 entries (DEFERRED-after-booster-items.py) — 293 − 8 resolved + 4 new, resolved by entry TEXT not number.

## Godot debt

`C07WallCrafterSecondConsumersProof` — 6 keys: cliff_crusher_has_no_rows, graphite_row_folds_optional_when_absent, hydrogen_row_folds_min_when_starved, item_row_binary_one_when_present, item_valid_stamped_live, live_tick_removes_hydrogen_when_running (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
