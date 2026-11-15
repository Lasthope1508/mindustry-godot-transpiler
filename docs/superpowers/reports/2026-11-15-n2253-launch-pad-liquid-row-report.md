# N2253 LaunchPad Liquid Consumer Row (oil 9f/60f (advanced-launch-pad ONLY)) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave second-consumers-1, integration branch `integration/wave-second-consumers-1-n2249-n2255`, base `c2d27fb0`).

## Source

Required ConsumeLiquid row: `ConsumeLiquid.efficiency` (ConsumeLiquid.java:42-47) + `ConsumeLiquid.update` (:37-39), folded into `BuildingComp.updateConsumption` first/second pass (:1969-1976 / :1999-2003). Def: Blocks.java:6808 `consumeLiquid(Liquids.oil, 9f/60f);`; launch-pad power 4f (:6797), advanced 8f (:6809) Multiplier default 1f (Consume.java:18); the def sets none. **Scope corrections (verified by grep): efficiency :42-47 (not :45-51 as the brief/scope said), update :37-39 (not :40-43); `efficiency = minEfficiency;` BuildingComp.java:1985; shouldConsumePower if :1972-1973; Fracker read guard :141-142; AdjacentFactory updates append :368.** Only advanced-launch-pad has the oil row (Blocks.java:6808); plain launch-pad has no liquid consumer.

## Implementation

`SourceLaunchPadBuildState.gd`: pure `source_launch_pad_liquid_consumer_row_state(frame, ...)` → 2 result symbols: row, has_liquid_row. Tick syncs frame["liquids"] from the sprite meta before the fold, appends the row to required_results (shared fold handles min + shouldConsumePower=false at ≤1e-7), direct second-pass removal after apply_update_consumption_state (guard `update && efficiency > 0`, edelta from the FOLDED efficiency). `_initial_frame` gains `"liquids": {}` where missing. 8 proof keys (2 more than the brief suggested): the row-absent case for the plain pad is a first-class key. Consumer detected from the catalog consumeLiquid row (advanced-only: amount 0.15 = 9f/60f, liquid oil); oil id via liquid_id_by_name. Direct second-pass removal after apply: the AdjacentFactory updates-array precedent does NOT fit — the machinery's second pass only records update consumers in updated_consumers, it never calls update on them, so an actor would remove no oil (finding confirmed across the wave). record_placed_block binds consumeLiquid for the advanced def and initializes the liquids store (plain pad syncs {} and its row is absent).

## Commits

Slice `ecebb9c5` (worker-N2253, branch `slice/N2253-launch-pad-liquid-row`, 5 files, đã push, remote tip verified by ls-remote). Integration cherry-pick on `integration/wave-second-consumers-1-n2249-n2255` (base c2d27fb0).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. 28 exact exprs, all grep-verified verbatim. Siblings (N2172/N2186/N2238: 9/12 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate: Ran 6110 in 1143.879s, failures=204, skipped=5, 0 errors — 204/204 Godot-absent (197 inherited + 7 new proof tests N2249–N2255).

## SSOT / DEFERRED

SSOT single-slice +2/+1/+1/+2 → 11708/1699/1621/3033; audit stays 1336. No shard changes. DEFERRED 293 (−1 resolved; 0 added). Merged wave DEFERRED: 293 entries (DEFERRED-after-second-consumers-1.py).

## Godot debt

`C07LaunchPadLiquidRowProof` — 8 keys: advanced_pad_has_oil_consumer, row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, row_absent_for_plain_launch_pad, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
