# N2257 BurstDrill Liquid Rows (impact water 10f/60f REQUIRED + ozone 3f/60f booster; eruption hydrogen 4f/60f REQUIRED + cyanogen 0.75f/60f booster) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave second-consumers-2, coordinator lượt 6).

## What this slice did

Required + booster ConsumeLiquid rows as one pure row function in `SourceBurstDrillBuildState.gd` (ConsumeLiquid.java:42-47 + :37-39; booster = `optional(true, true)`, Consume.java:33-35): impact-drill water 10f/60f REQUIRED + ozone 3f/60f booster; eruption-drill hydrogen 4f/60f REQUIRED + cyanogen 0.75f/60f booster. Same one-function + catalog-flag design as N2256: the tick routes each catalog row by its `optional` flag — required rows fold the first-pass min beside the power row, booster rows fold the optional pass (capped by minEfficiency, BuildingComp.java:1986). 2 result symbols: row, has_liquid_row. The N2219 advance is untouched — it already reads `frame["optional_efficiency"]`.

## Key facts for the next agent

**Verified line numbers**: booster `optional(true, true)` Consume.java:33-35; optional pass BuildingComp.java:1980-1981, cap :1986, zeroed if !update :1992-1994; `efficiency = minEfficiency;` :1985; second pass :1999; efficiency :42-47, update :37-39. **"Fracker:139-144" is the wrong file** — Fracker.java is only 46 lines; the guard is SourceFrackerBuildState.gd:151-152 / :221; liquids sync :361 is correct; N2252's "Fracker:327" cite is stale. **Direct removal, not the updates-array actor** — the machinery's second pass only records update consumers, it never calls update on them. Both rows have update=true (Consume.java:16), so both are second-pass consumers. Register: ledger/contract java_source is BurstDrill.java — ConsumeLiquid.java as ledger java_source crashes the consumer_slices shard rebuild (KeyError: 'generated_owner'). Register: 18 exact exprs, all grep-verified verbatim. DEFERRED: 292 (293 − 1 resolved, 0 added). Slice commit `c6c564fb` (branch `slice/N2257-burst-drill-liquid-rows`, đã push). Integration cherry-pick `649ed0ec`; no coordinator fix needed.

## Godot debt (this slice)

`C07BurstDrillLiquidRowsProof` — 6 keys: required_row_folds_min_when_starved, booster_row_folds_optional_when_starved, optional_capped_by_min_efficiency, row_caps_at_one_when_full, live_tick_folds_both_rows, live_tick_removes_liquid_when_running. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
