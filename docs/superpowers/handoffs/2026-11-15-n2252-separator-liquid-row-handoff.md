# N2252 Separator Liquid Consumer Row (slag 4f/60f (separator) / 0.12f (disassembler)) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave second-consumers-1, coordinator lượt 5).

## What this slice did

Required ConsumeLiquid row as a pure row in `SourceSeparatorBuildState.gd` (ConsumeLiquid.java:42-47 + :37-39): slag 4f/60f (separator) / 0.12f (disassembler) folds into the first-pass min beside the power row; the second pass removes `amount * folded_edelta * multiplier`. 2 result symbols: row, has_liquid_row.

## Key facts for the next agent

**Verified line numbers**: efficiency :42-47 (not :45-51), update :37-39 (not :40-43), `efficiency = minEfficiency;` BuildingComp.java:1985, shouldConsumePower if :1972-1973, Fracker guard :141-142, AdjacentFactory updates append :368. **Direct removal, not the updates-array actor** — the machinery's second pass only records update consumers, it never calls update on them. Amount read per-def from the catalog consumeLiquid slag row (separator 0.0666…, disassembler 0.12). Direct second-pass removal after apply (AdjacentFactory updates-array needs consumer actor objects built by reinitialize_consumers_state, which this driver has no infrastructure for). New deferral found by the worker: the disassembler's scrap ConsumeItems efficiency row (ConsumeItems.java:51-53) is still unmodeled — the coordinator added a DEFERRED entry at integration. Cite corrections applied by the coordinator at integration (81b0dbe4): the slice used the brief's wrong ConsumeLiquid cites (:45-51/:40-43 → :42-47/:37-39). Register: 12 exact exprs, all grep-verified verbatim. DEFERRED: 293 (−1 resolved; 0 added by the slice). Production shards changed (production_api_contracts/slices/state_schema/symbols). Slice commit `b3922a5f` (branch `slice/N2252-separator-liquid-row`, đã push).

## Godot debt (this slice)

`C07SeparatorLiquidRowProof` — 6 keys: row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
