# N2255 Fracker Liquid Consumer Row (water 0.15f (= 9/s)) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave second-consumers-1, coordinator lượt 5).

## What this slice did

Required ConsumeLiquid row as a pure row in `SourceFrackerBuildState.gd` (ConsumeLiquid.java:42-47 + :37-39): water 0.15f (= 9/s) folds into the first-pass min beside the power row; the second pass removes `amount * folded_edelta * multiplier`. 2 result symbols: row, has_liquid_row.

## Key facts for the next agent

**Verified line numbers**: efficiency :42-47 (not :45-51), update :37-39 (not :40-43), `efficiency = minEfficiency;` BuildingComp.java:1985, shouldConsumePower if :1972-1973, Fracker guard :141-142, AdjacentFactory updates append :368. **Direct removal, not the updates-array actor** — the machinery's second pass only records update consumers, it never calls update on them. Sand item row NOT in this slice — the merged 'Fracker item / liquid rows' DEFERRED entry was split: water resolved, sand row kept as its own new entry (the N2224 intake entry cross-reference updated to it). Frame already had liquids + items (N2207/N2224). Tick gate: block.properties.has("consumeLiquid"); source_delta/time_scale hoisted above the consumption block, the N2224 advance reuses them. Direct second-pass removal after apply (no consumer actor infra in this pure-function driver). Register: ledger/contract java_source is Fracker.java (N2153/N2224 precedent) — ConsumeLiquid.java as ledger java_source crashes the consumer_slices shard rebuild (KeyError: 'generated_owner'). Register: 24 exact exprs, all grep-verified verbatim. DEFERRED: 294 (net 0: −1 merged item/liquid entry + 1 new sand-row entry; intake entry reworded in place). Production shards changed (all 4 production shards). Slice commit `1fed72fc` (branch `slice/N2255-fracker-liquid-row`, đã push).

## Godot debt (this slice)

`C07FrackerLiquidRowProof` — 6 keys: row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
