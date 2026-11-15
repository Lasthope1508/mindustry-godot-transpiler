# N2256 BeamDrill Liquid Rows (plasma-bore hydrogen 0.25f/60f booster; large-plasma-bore hydrogen 0.5f/60f REQUIRED + nitrogen 3f/60f booster) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 6 — wave second-consumers-2, integration branch `integration/wave-second-consumers-2-n2256-n2259`, base `73185810`).

## Source

Booster = `optional(true, true)` via `Consume.boost()` (Consume.java:33-35); booster consumers fold into the optional pass (BuildingComp.java:1980-1981), capped by minEfficiency (:1986), zeroed if !update (:1992-1994). Fold: assume efficiency = optionalEfficiency = 1f (:1965); first pass non-optional :1969-1976; `efficiency = minEfficiency;` :1985; second pass `if(update && efficiency > 0)` :1999. `ConsumeLiquid.efficiency` :42-47 (ed = edelta × efficiencyScale, ed ≤ 1e-8 → 0, cap 1f); `ConsumeLiquid.update` :37-39. Defs: plasma-bore hydrogen 0.25f/60f booster (Blocks.java:3049); large-plasma-bore hydrogen 0.5f/60f REQUIRED (:3064) + nitrogen 3f/60f booster (:3065). BeamDrill multiplier lerp(1, 2.5, optionalEfficiency) (BeamDrill.java:246, optionalBoostIntensity 2.5f :44) — the N2195 advance already reads `frame["optional_efficiency"]`, untouched by this slice. **Scope corrections (verified by grep): the "Fracker:139-144" cite is stale — the liquid-row guard is SourceFrackerBuildState.gd:221 (gate guard :151); "Fracker:361" (liquids sync) is correct.** WallCrafter hydrogen 1f/60f (Blocks.java:3028) is NOT a booster (no `.boost()`, hasLiquidBooster stays false) — separate future slice, not this wave.

## Implementation

`SourceBeamDrillBuildState.gd`: ONE pure function `source_beam_drill_liquid_consumer_row_state(frame, ...)` serves both the required row and the booster row (the efficiency formula is identical; Java distinguishes them only by which consumer list they join) → 2 result symbols: row, has_liquid_row. The tick routes each catalog consumeLiquid row by its `optional` flag: required rows fold the first pass (starved non-power row also stops power draw, BuildingComp.java:1972, via the shared fold), booster rows fold the optional pass. Tick syncs frame["liquids"] from the sprite meta before the fold (Fracker precedent :361); direct second-pass removal after apply_update_consumption_state for BOTH rows (both have update=true, Consume.java:16), guard `update && efficiency > 0`, edelta from the FOLDED efficiency. Register: ledger/contract java_source is BeamDrill.java (ConsumeLiquid.java as ledger java_source crashes the consumer_slices shard rebuild — KeyError: 'generated_owner').

## Commits

Slice `6e654a14` (worker-N2256, branch `slice/N2256-beam-drill-liquid-rows`, 5 files, +1006/−11, đã push, remote tip verified by ls-remote). Integration cherry-pick `a964be8e` on `integration/wave-second-consumers-2-n2256-n2259` (base 73185810). Coordinator fix `33893e22` at integration: removed the stale "with no optional rows modeled yet" line from the N2195 advance docstring (now false).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 17/17, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (N2195 advance + power/gate family: 9/12 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate: Ran 6126 in 1081.029s, failures=208, skipped=5, 0 errors — 208/208 Godot-absent (204 inherited + 4 new proof tests N2256–N2259).

## SSOT / DEFERRED

SSOT single-slice +2/+1/+1/+2 → 11722/1706/1628/3047; audit stays 1336. DEFERRED 293 (293 − 1 resolved + 1 new: "BeamDrill live liquid intake" — no live intake fills frame["liquids"] yet). Merged wave DEFERRED: 293 entries (DEFERRED-after-second-consumers-2.py).

## Godot debt

`C07BeamDrillLiquidRowsProof` — 6 keys: required_row_folds_min_when_starved, booster_row_folds_optional_when_starved, optional_capped_by_min_efficiency, row_caps_at_one_when_full, live_tick_folds_both_rows, live_tick_removes_liquid_when_running (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
