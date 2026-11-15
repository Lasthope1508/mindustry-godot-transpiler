# N2253 LaunchPad Liquid Consumer Row (oil 9f/60f (advanced-launch-pad ONLY)) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave second-consumers-1, coordinator lượt 5).

## What this slice did

Required ConsumeLiquid row as a pure row in `SourceLaunchPadBuildState.gd` (ConsumeLiquid.java:42-47 + :37-39): oil 9f/60f (advanced-launch-pad ONLY) folds into the first-pass min beside the power row; the second pass removes `amount * folded_edelta * multiplier`. 2 result symbols: row, has_liquid_row.

## Key facts for the next agent

**Verified line numbers**: efficiency :42-47 (not :45-51), update :37-39 (not :40-43), `efficiency = minEfficiency;` BuildingComp.java:1985, shouldConsumePower if :1972-1973, Fracker guard :141-142, AdjacentFactory updates append :368. **Direct removal, not the updates-array actor** — the machinery's second pass only records update consumers, it never calls update on them. 8 proof keys (2 more than the brief suggested): the row-absent case for the plain pad is a first-class key. Consumer detected from the catalog consumeLiquid row (advanced-only: amount 0.15 = 9f/60f, liquid oil); oil id via liquid_id_by_name. Direct second-pass removal after apply: the AdjacentFactory updates-array precedent does NOT fit — the machinery's second pass only records update consumers in updated_consumers, it never calls update on them, so an actor would remove no oil (finding confirmed across the wave). record_placed_block binds consumeLiquid for the advanced def and initializes the liquids store (plain pad syncs {} and its row is absent). Register: 28 exact exprs, all grep-verified verbatim. DEFERRED: 293 (−1 resolved; 0 added). No shard changes. Slice commit `ecebb9c5` (branch `slice/N2253-launch-pad-liquid-row`, đã push).

## Godot debt (this slice)

`C07LaunchPadLiquidRowProof` — 8 keys: advanced_pad_has_oil_consumer, row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, row_absent_for_plain_launch_pad, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
