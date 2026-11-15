# N2252 Separator Liquid Consumer Row (slag 4f/60f (separator) / 0.12f (disassembler)) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave second-consumers-1, integration branch `integration/wave-second-consumers-1-n2249-n2255`, base `c2d27fb0`).

## Source

Required ConsumeLiquid row: `ConsumeLiquid.efficiency` (ConsumeLiquid.java:42-47) + `ConsumeLiquid.update` (:37-39), folded into `BuildingComp.updateConsumption` first/second pass (:1969-1976 / :1999-2003). Def: Blocks.java:1244 `consumeLiquid(Liquids.slag, 4f / 60f);` (separator); Blocks.java:1264 `consumeLiquid(Liquids.slag, 0.12f);` (disassembler — 0.12f PER FRAME = 7.2/s) Multiplier default 1f (Consume.java:18); the def sets none. **Scope corrections (verified by grep): efficiency :42-47 (not :45-51 as the brief/scope said), update :37-39 (not :40-43); `efficiency = minEfficiency;` BuildingComp.java:1985; shouldConsumePower if :1972-1973; Fracker read guard :141-142; AdjacentFactory updates append :368.** Two defs: separator (Blocks.java:1244) + disassembler (Blocks.java:1264).

## Implementation

`SourceSeparatorBuildState.gd`: pure `source_separator_liquid_consumer_row_state(frame, ...)` → 2 result symbols: row, has_liquid_row. Tick syncs frame["liquids"] from the sprite meta before the fold, appends the row to required_results (shared fold handles min + shouldConsumePower=false at ≤1e-7), direct second-pass removal after apply_update_consumption_state (guard `update && efficiency > 0`, edelta from the FOLDED efficiency). `_initial_frame` gains `"liquids": {}` where missing. Amount read per-def from the catalog consumeLiquid slag row (separator 0.0666…, disassembler 0.12). Direct second-pass removal after apply (AdjacentFactory updates-array needs consumer actor objects built by reinitialize_consumers_state, which this driver has no infrastructure for). New deferral found by the worker: the disassembler's scrap ConsumeItems efficiency row (ConsumeItems.java:51-53) is still unmodeled — the coordinator added a DEFERRED entry at integration. Cite corrections applied by the coordinator at integration (81b0dbe4): the slice used the brief's wrong ConsumeLiquid cites (:45-51/:40-43 → :42-47/:37-39).

## Commits

Slice `b3922a5f` (worker-N2252, branch `slice/N2252-separator-liquid-row`, 5 files, đã push, remote tip verified by ls-remote). Integration cherry-pick on `integration/wave-second-consumers-1-n2249-n2255` (base c2d27fb0).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. 12 exact exprs, all grep-verified verbatim. Siblings (N2169/N2200/N2222: 9/12 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate: Ran 6110 in 1143.879s, failures=204, skipped=5, 0 errors — 204/204 Godot-absent (197 inherited + 7 new proof tests N2249–N2255).

## SSOT / DEFERRED

SSOT single-slice +2/+1/+1/+2 → 11708/1699/1621/3033; audit stays 1336. Production shards changed (production_api_contracts/slices/state_schema/symbols). DEFERRED 293 (−1 resolved; 0 added by the slice). Merged wave DEFERRED: 293 entries (DEFERRED-after-second-consumers-1.py).

## Godot debt

`C07SeparatorLiquidRowProof` — 6 keys: row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
