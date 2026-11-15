# N2254 ImpactReactor Liquid Consumer Row (cryofluid 0.25f (= 15/s)) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave second-consumers-1, coordinator lượt 5).

## What this slice did

Required ConsumeLiquid row as a pure row in `SourceImpactReactorBuildState.gd` (ConsumeLiquid.java:42-47 + :37-39): cryofluid 0.25f (= 15/s) folds into the first-pass min beside the power row; the second pass removes `amount * folded_edelta * multiplier`. 2 result symbols: row, has_liquid_row.

## Key facts for the next agent

**Verified line numbers**: efficiency :42-47 (not :45-51), update :37-39 (not :40-43), `efficiency = minEfficiency;` BuildingComp.java:1985, shouldConsumePower if :1972-1973, Fracker guard :141-142, AdjacentFactory updates append :368. **Direct removal, not the updates-array actor** — the machinery's second pass only records update consumers, it never calls update on them. Blast-compound item row NOT in this slice (timer consume, ImpactReactor.java:91-93) — still deferred. Register fix: java_source under /world/consumers/ selects the slice into the consumer_slices shard, which mirrors generated_owner — the register crashed (KeyError: 'generated_owner') until generated_owner='' was added (N2007 precedent). Direct second-pass removal after apply (this driver is pure static functions with no actor). Def constants SOURCE_IMPACT_REACTOR_LIQUID = "cryofluid", SOURCE_IMPACT_REACTOR_LIQUID_AMOUNT = 0.25. Register: Exact exprs grep-verified verbatim. DEFERRED: 293 (−1 resolved; 0 added). Consumer shards changed (consumer_slices 106→107 + consumer_api_contracts). Slice commit `2abb4c60` (branch `slice/N2254-impact-reactor-liquid-row`, đã push).

## Godot debt (this slice)

`C07ImpactReactorLiquidRowProof` — 6 keys: row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
