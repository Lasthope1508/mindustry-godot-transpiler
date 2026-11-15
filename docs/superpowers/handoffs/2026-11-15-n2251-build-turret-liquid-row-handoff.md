# N2251 BuildTurret Liquid Consumer Row (nitrogen 3f/60f) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave second-consumers-1, coordinator lượt 5).

## What this slice did

Required ConsumeLiquid row as a pure row in `SourceBuildTurretBuildState.gd` (ConsumeLiquid.java:42-47 + :37-39): nitrogen 3f/60f folds into the first-pass min beside the power row; the second pass removes `amount * folded_edelta * multiplier`. 2 result symbols: row, has_liquid_row.

## Key facts for the next agent

**Verified line numbers**: efficiency :42-47 (not :45-51), update :37-39 (not :40-43), `efficiency = minEfficiency;` BuildingComp.java:1985, shouldConsumePower if :1972-1973, Fracker guard :141-142, AdjacentFactory updates append :368. **Direct removal, not the updates-array actor** — the machinery's second pass only records update consumers, it never calls update on them. The 2 pure advance functions (N2243 sync/warmup, N2244 plan logic) untouched. Direct second-pass removal after apply (AdjacentFactory updates-array precedent needs RuntimeConsumer actors; this driver has none). Catalog build-tower consumeLiquid 0.05 nitrogen; record_placed_block initializes the sprite liquids store. New DEFERRED entry: no live conduit/bridge delivery fills frame["liquids"] yet — a live tower with no intake reads 0 nitrogen and folds efficiency 0. Register: 31 exact exprs, all grep-verified verbatim. DEFERRED: 294 (net 0: −1 resolved + 1 new: live nitrogen intake). Defense shards changed (defense_slices + defense_api_contracts). Slice commit `eec92c53` (branch `slice/N2251-build-turret-liquid-row`, đã push).

## Godot debt (this slice)

`C07BuildTurretLiquidRowProof` — 6 keys: row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
