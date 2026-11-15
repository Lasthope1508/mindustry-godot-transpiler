# N2255 Fracker Liquid Consumer Row (water 0.15f (= 9/s)) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave second-consumers-1, integration branch `integration/wave-second-consumers-1-n2249-n2255`, base `c2d27fb0`).

## Source

Required ConsumeLiquid row: `ConsumeLiquid.efficiency` (ConsumeLiquid.java:42-47) + `ConsumeLiquid.update` (:37-39), folded into `BuildingComp.updateConsumption` first/second pass (:1969-1976 / :1999-2003). Def: Blocks.java:2978 `consumeLiquid(Liquids.water, 0.15f);` — 0.15f PER FRAME (= 9/s) Multiplier default 1f (Consume.java:18); the def sets none. **Scope corrections (verified by grep): efficiency :42-47 (not :45-51 as the brief/scope said), update :37-39 (not :40-43); `efficiency = minEfficiency;` BuildingComp.java:1985; shouldConsumePower if :1972-1973; Fracker read guard :141-142; AdjacentFactory updates append :368.** Single def oil-extractor (Blocks.java:2966+); power 3f + water 0.15f + sand item.

## Implementation

`SourceFrackerBuildState.gd`: pure `source_fracker_liquid_consumer_row_state(frame, ...)` → 2 result symbols: row, has_liquid_row. Tick syncs frame["liquids"] from the sprite meta before the fold, appends the row to required_results (shared fold handles min + shouldConsumePower=false at ≤1e-7), direct second-pass removal after apply_update_consumption_state (guard `update && efficiency > 0`, edelta from the FOLDED efficiency). `_initial_frame` gains `"liquids": {}` where missing. Sand item row NOT in this slice — the merged 'Fracker item / liquid rows' DEFERRED entry was split: water resolved, sand row kept as its own new entry (the N2224 intake entry cross-reference updated to it). Frame already had liquids + items (N2207/N2224). Tick gate: block.properties.has("consumeLiquid"); source_delta/time_scale hoisted above the consumption block, the N2224 advance reuses them. Direct second-pass removal after apply (no consumer actor infra in this pure-function driver). Register: ledger/contract java_source is Fracker.java (N2153/N2224 precedent) — ConsumeLiquid.java as ledger java_source crashes the consumer_slices shard rebuild (KeyError: 'generated_owner').

## Commits

Slice `1fed72fc` (worker-N2255, branch `slice/N2255-fracker-liquid-row`, 5 files, đã push, remote tip verified by ls-remote). Integration cherry-pick on `integration/wave-second-consumers-1-n2249-n2255` (base c2d27fb0).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. 24 exact exprs, all grep-verified verbatim. Siblings (N2153/N2207/N2224: 9/12 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate: Ran 6110 in 1143.879s, failures=204, skipped=5, 0 errors — 204/204 Godot-absent (197 inherited + 7 new proof tests N2249–N2255).

## SSOT / DEFERRED

SSOT single-slice +2/+1/+1/+2 → 11708/1699/1621/3033; audit stays 1336. Production shards changed (all 4 production shards). DEFERRED 294 (net 0: −1 merged item/liquid entry + 1 new sand-row entry; intake entry reworded in place). Merged wave DEFERRED: 293 entries (DEFERRED-after-second-consumers-1.py).

## Godot debt

`C07FrackerLiquidRowProof` — 6 keys: row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
