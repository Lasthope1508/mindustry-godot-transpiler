# N2254 ImpactReactor Liquid Consumer Row (cryofluid 0.25f (= 15/s)) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave second-consumers-1, integration branch `integration/wave-second-consumers-1-n2249-n2255`, base `c2d27fb0`).

## Source

Required ConsumeLiquid row: `ConsumeLiquid.efficiency` (ConsumeLiquid.java:42-47) + `ConsumeLiquid.update` (:37-39), folded into `BuildingComp.updateConsumption` first/second pass (:1969-1976 / :1999-2003). Def: Blocks.java:2644 `consumeLiquid(Liquids.cryofluid, 0.25f);` — 0.25f PER FRAME (= 15/s) Multiplier default 1f (Consume.java:18); the def sets none. **Scope corrections (verified by grep): efficiency :42-47 (not :45-51 as the brief/scope said), update :37-39 (not :40-43); `efficiency = minEfficiency;` BuildingComp.java:1985; shouldConsumePower if :1972-1973; Fracker read guard :141-142; AdjacentFactory updates append :368.** Single def impact-reactor (Blocks.java:2640+); power 25f + blast-compound item row + cryofluid 0.25f.

## Implementation

`SourceImpactReactorBuildState.gd`: pure `source_impact_reactor_liquid_consumer_row_state(frame, ...)` → 2 result symbols: row, has_liquid_row. Tick syncs frame["liquids"] from the sprite meta before the fold, appends the row to required_results (shared fold handles min + shouldConsumePower=false at ≤1e-7), direct second-pass removal after apply_update_consumption_state (guard `update && efficiency > 0`, edelta from the FOLDED efficiency). `_initial_frame` gains `"liquids": {}` where missing. Blast-compound item row NOT in this slice (timer consume, ImpactReactor.java:91-93) — still deferred. Register fix: java_source under /world/consumers/ selects the slice into the consumer_slices shard, which mirrors generated_owner — the register crashed (KeyError: 'generated_owner') until generated_owner='' was added (N2007 precedent). Direct second-pass removal after apply (this driver is pure static functions with no actor). Def constants SOURCE_IMPACT_REACTOR_LIQUID = "cryofluid", SOURCE_IMPACT_REACTOR_LIQUID_AMOUNT = 0.25.

## Commits

Slice `2abb4c60` (worker-N2254, branch `slice/N2254-impact-reactor-liquid-row`, 5 files, đã push, remote tip verified by ls-remote). Integration cherry-pick on `integration/wave-second-consumers-1-n2249-n2255` (base c2d27fb0).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Exact exprs grep-verified verbatim. Siblings (N2182/N2192: 6/8 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate: Ran 6110 in 1143.879s, failures=204, skipped=5, 0 errors — 204/204 Godot-absent (197 inherited + 7 new proof tests N2249–N2255).

## SSOT / DEFERRED

SSOT single-slice +2/+1/+1/+2 → 11708/1699/1621/3033; audit stays 1336. Consumer shards changed (consumer_slices 106→107 + consumer_api_contracts). DEFERRED 293 (−1 resolved; 0 added). Merged wave DEFERRED: 293 entries (DEFERRED-after-second-consumers-1.py).

## Godot debt

`C07ImpactReactorLiquidRowProof` — 6 keys: row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
