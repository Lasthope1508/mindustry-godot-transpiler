# N2250 RepairTower Liquid Consumer Row (ozone 3f/60f) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave second-consumers-1, coordinator lượt 5).

## What this slice did

Required ConsumeLiquid row as a pure row in `SourceRepairTowerBuildState.gd` (ConsumeLiquid.java:42-47 + :37-39): ozone 3f/60f folds into the first-pass min beside the power row; the second pass removes `amount * folded_edelta * multiplier`. 2 result symbols: row, has_liquid_row.

## Key facts for the next agent

**Verified line numbers**: efficiency :42-47 (not :45-51), update :37-39 (not :40-43), `efficiency = minEfficiency;` BuildingComp.java:1985, shouldConsumePower if :1972-1973, Fracker guard :141-142, AdjacentFactory updates append :368. **Direct removal, not the updates-array actor** — the machinery's second pass only records update consumers, it never calls update on them. Tick hoists time_delta/time_scale before the fold (read once, reused by the advance). Direct second-pass removal after apply (RuntimeConsumer actor pattern does not fit a single static consumer with a constant multiplier). Catalog confirms unit-repair-tower consumeLiquid 0.05 ozone; record_placed_block initializes the liquids store. Register: 22 exact exprs, all grep-verified verbatim. DEFERRED: 295 (294 − 1 resolved + 2 new: display rows, build rows). No shard changes (java_source RepairTower.java per N2176 precedent — consumer_slices shard selects /world/consumers/ and mirrors generated_owner). Slice commit `c9364955` (branch `slice/N2250-repair-tower-liquid-row`, đã push).

## Godot debt (this slice)

`C07RepairTowerLiquidRowProof` — 6 keys: row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
