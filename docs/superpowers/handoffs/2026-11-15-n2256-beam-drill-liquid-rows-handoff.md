# N2256 BeamDrill Liquid Rows (plasma-bore hydrogen 0.25f/60f booster; large-plasma-bore hydrogen 0.5f/60f REQUIRED + nitrogen 3f/60f booster) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave second-consumers-2, coordinator lượt 6).

## What this slice did

Required + booster ConsumeLiquid rows as one pure row function in `SourceBeamDrillBuildState.gd` (ConsumeLiquid.java:42-47 + :37-39; booster = `optional(true, true)`, Consume.java:33-35): plasma-bore hydrogen 0.25f/60f booster; large-plasma-bore hydrogen 0.5f/60f REQUIRED + nitrogen 3f/60f booster. The tick routes each catalog row by its `optional` flag — required rows fold the first-pass min beside the power row, booster rows fold the optional pass (capped by minEfficiency, BuildingComp.java:1986). 2 result symbols: row, has_liquid_row. The N2195 advance is untouched — it already reads `frame["optional_efficiency"]`.

## Key facts for the next agent

**Verified line numbers**: booster `optional(true, true)` Consume.java:33-35; optional pass BuildingComp.java:1980-1981, cap :1986, zeroed if !update :1992-1994; `efficiency = minEfficiency;` :1985; second pass :1999; efficiency :42-47, update :37-39. **"Fracker:139-144" is stale** — the liquid-row guard is SourceFrackerBuildState.gd:221 (gate guard :151); liquids sync :361 is correct. **Direct removal, not the updates-array actor** — the machinery's second pass only records update consumers, it never calls update on them. Both rows have update=true (Consume.java:16), so both are second-pass consumers. Register: ledger/contract java_source is BeamDrill.java — ConsumeLiquid.java as ledger java_source crashes the consumer_slices shard rebuild (KeyError: 'generated_owner'). Register: 17 exact exprs, all grep-verified verbatim. DEFERRED: 293 (293 − 1 resolved + 1 new: live liquid intake). WallCrafter hydrogen is NOT a booster (no `.boost()`) — separate future slice. Slice commit `6e654a14` (branch `slice/N2256-beam-drill-liquid-rows`, đã push). Integration cherry-pick `a964be8e`; coordinator fix `33893e22` removed the stale "no optional rows modeled yet" line from the N2195 advance docstring.

## Godot debt (this slice)

`C07BeamDrillLiquidRowsProof` — 6 keys: required_row_folds_min_when_starved, booster_row_folds_optional_when_starved, optional_capped_by_min_efficiency, row_caps_at_one_when_full, live_tick_folds_both_rows, live_tick_removes_liquid_when_running. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
