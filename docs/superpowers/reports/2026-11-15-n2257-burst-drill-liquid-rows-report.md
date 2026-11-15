# N2257 BurstDrill Liquid Rows (impact water 10f/60f REQUIRED + ozone 3f/60f booster; eruption hydrogen 4f/60f REQUIRED + cyanogen 0.75f/60f booster) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 6 — wave second-consumers-2, integration branch `integration/wave-second-consumers-2-n2256-n2259`, base `73185810`).

## Source

Booster = `optional(true, true)` via `Consume.boost()` (Consume.java:33-35); booster consumers fold into the optional pass (BuildingComp.java:1980-1981), capped by minEfficiency (:1986), zeroed if !update (:1992-1994). Fold: assume efficiency = optionalEfficiency = 1f (:1965); first pass non-optional :1969-1976; `efficiency = minEfficiency;` :1985; second pass `if(update && efficiency > 0)` :1999. `ConsumeLiquid.efficiency` :42-47 (ed = edelta × efficiencyScale, ed ≤ 1e-8 → 0, cap 1f); `ConsumeLiquid.update` :37-39. Defs: impact-drill water 10f/60f REQUIRED (Blocks.java:3089) + ozone 3f/60f booster (:3090); eruption-drill hydrogen 4f/60f REQUIRED (:3119) + cyanogen 0.75f/60f booster (:3120). BurstDrill speed = lerp(1, liquidBoostIntensity, optionalEfficiency) × efficiency (Drill.java:94; class default 1.6f Drill.java:38; impact 1.75f, eruption 2f) — the N2219 advance already reads `frame["optional_efficiency"]`, untouched by this slice. **Scope corrections (verified by grep): "Fracker:139-144" is the wrong file — Fracker.java is only 46 lines; the guard is SourceFrackerBuildState.gd:151-152 / :221; "Fracker:361" (liquids sync) is correct in the GDScript file; N2252's "Fracker:327" cite is stale (sync moved to :361).**

## Implementation

`SourceBurstDrillBuildState.gd`: ONE pure function `source_burst_drill_liquid_consumer_row_state(frame, ...)` serves both the required row and the booster row (same design as N2256) → 2 result symbols: row, has_liquid_row. The tick routes each catalog consumeLiquid row by its `optional` flag: required rows fold the first pass (starved non-power row also stops power draw, BuildingComp.java:1972, via the shared fold), booster rows fold the optional pass. Tick syncs frame["liquids"] from the sprite meta before the fold (Fracker precedent :361); direct second-pass removal after apply_update_consumption_state for BOTH rows (both have update=true, Consume.java:16), guard `update && efficiency > 0`, edelta from the FOLDED efficiency. Register: ledger/contract java_source is BurstDrill.java (ConsumeLiquid.java as ledger java_source crashes the consumer_slices shard rebuild — KeyError: 'generated_owner').

## Commits

Slice `c6c564fb` (worker-N2257, branch `slice/N2257-burst-drill-liquid-rows`, 5 files, +1038/−12, đã push, remote tip verified by ls-remote). Integration cherry-pick `649ed0ec` on `integration/wave-second-consumers-2-n2256-n2259` (base 73185810). No coordinator fix needed at integration.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 18/18, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings: 12/12 non-proof PASS, 0 other failures. Full wave gate: Ran 6126 in 1081.029s, failures=208, skipped=5, 0 errors — 208/208 Godot-absent (204 inherited + 4 new proof tests N2256–N2259).

## SSOT / DEFERRED

SSOT single-slice +2/+1/+1/+2 → 11722/1706/1628/3047; audit stays 1336. DEFERRED 292 (293 − 1 resolved, 0 added). Merged wave DEFERRED: 293 entries (DEFERRED-after-second-consumers-2.py).

## Godot debt

`C07BurstDrillLiquidRowsProof` — 6 keys: required_row_folds_min_when_starved, booster_row_folds_optional_when_starved, optional_capped_by_min_efficiency, row_caps_at_one_when_full, live_tick_folds_both_rows, live_tick_removes_liquid_when_running (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
