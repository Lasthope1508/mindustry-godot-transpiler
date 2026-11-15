# N2250 RepairTower Liquid Consumer Row (ozone 3f/60f) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave second-consumers-1, integration branch `integration/wave-second-consumers-1-n2249-n2255`, base `c2d27fb0`).

## Source

Required ConsumeLiquid row: `ConsumeLiquid.efficiency` (ConsumeLiquid.java:42-47) + `ConsumeLiquid.update` (:37-39), folded into `BuildingComp.updateConsumption` first/second pass (:1969-1976 / :1999-2003). Def: Blocks.java:6583 `consumeLiquid(Liquids.ozone, 3f / 60f);` Multiplier default 1f (Consume.java:18); the def sets none. **Scope corrections (verified by grep): efficiency :42-47 (not :45-51 as the brief/scope said), update :37-39 (not :40-43); `efficiency = minEfficiency;` BuildingComp.java:1985; shouldConsumePower if :1972-1973; Fracker read guard :141-142; AdjacentFactory updates append :368.** Single def unit-repair-tower (Blocks.java:6575-6583); power 1f.

## Implementation

`SourceRepairTowerBuildState.gd`: pure `source_repair_tower_liquid_consumer_row_state(frame, ...)` → 2 result symbols: row, has_liquid_row. Tick syncs frame["liquids"] from the sprite meta before the fold, appends the row to required_results (shared fold handles min + shouldConsumePower=false at ≤1e-7), direct second-pass removal after apply_update_consumption_state (guard `update && efficiency > 0`, edelta from the FOLDED efficiency). `_initial_frame` gains `"liquids": {}` where missing. Tick hoists time_delta/time_scale before the fold (read once, reused by the advance). Direct second-pass removal after apply (RuntimeConsumer actor pattern does not fit a single static consumer with a constant multiplier). Catalog confirms unit-repair-tower consumeLiquid 0.05 ozone; record_placed_block initializes the liquids store.

## Commits

Slice `c9364955` (worker-N2250, branch `slice/N2250-repair-tower-liquid-row`, 5 files, đã push, remote tip verified by ls-remote). Integration cherry-pick on `integration/wave-second-consumers-1-n2249-n2255` (base c2d27fb0).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. 22 exact exprs, all grep-verified verbatim. Siblings (N2176/N2213/N2227: 9/12 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate: Ran 6110 in 1143.879s, failures=204, skipped=5, 0 errors — 204/204 Godot-absent (197 inherited + 7 new proof tests N2249–N2255).

## SSOT / DEFERRED

SSOT single-slice +2/+1/+1/+2 → 11708/1699/1621/3033; audit stays 1336. No shard changes (java_source RepairTower.java per N2176 precedent — consumer_slices shard selects /world/consumers/ and mirrors generated_owner). DEFERRED 295 (294 − 1 resolved + 2 new: display rows, build rows). Merged wave DEFERRED: 293 entries (DEFERRED-after-second-consumers-1.py).

## Godot debt

`C07RepairTowerLiquidRowProof` — 6 keys: row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
