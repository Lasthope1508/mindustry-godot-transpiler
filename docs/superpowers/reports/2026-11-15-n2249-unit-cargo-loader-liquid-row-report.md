# N2249 UnitCargoLoader liquid consumer row — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave second-consumers-1, base `c2d27fb0`).

## Source

- ConsumeLiquid.efficiency (ConsumeLiquid.java:42-47): `float ed = build.edelta() * build.efficiencyScale();` / `if(ed <= 0.00000001f) return 0f;` / `return Math.min(build.liquids.get(liquid) / (amount * ed * multiplier.get(build)), 1f);`. First pass assumes efficiency 1f (BuildingComp.java:1964), so edelta() = delta() = source_delta * time_scale (BuildingComp.java:1922-1929).
- ConsumeLiquid.update (ConsumeLiquid.java:37-39): `build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));` — only when `update && efficiency > 0` (BuildingComp.java:1999), edelta from the FOLDED efficiency.
- Fold: `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);` (BuildingComp.java:1969-1976); starved non-power row stops power draw (`if(cons != block.consPower && result <= 0.0000001f){`, BuildingComp.java:1972) — the shared fold already does this from is_power false.
- Multiplier defaults to 1f (`public Floatf<Building> multiplier = b -> 1f;`, Consume.java:18); the def does NOT override it (Blocks.java:2270-2283 has no multiplier call).
- Def unit-cargo-loader (Blocks.java:2270-2283, single def): size 3, consumePower 8f/60f (:2276), consumeLiquid nitrogen 10f/60f (:2279, the SECOND consumer — this slice), itemCapacity 200.
- Cite corrections: ConsumeLiquid.update is :37-39 (not :40-43 as the scope brief said), efficiency is :42-47 (not :45-51). Verified by grep at this pin.

## Implementation

- `SourceUnitCargoLoaderBuildState.gd`:
  - Pure `source_unit_cargo_loader_liquid_consumer_row_state(frame, has_liquid_consumer, liquid_id, amount, source_delta, time_scale, efficiency_scale=1.0, multiplier=1.0)` → 2 result symbols: row, has_liquid_row. Row shape mirrors the power row: `{"has_liquid_row": bool, "row": {"result": float, "is_power": false}}`. Liquid amount reads via `SourceLiquidModuleState.source_get_state` with the Fracker guard (liquids.has("liquids") + bounds check); Java's liquids.get returns 0.0 for a liquid never added (LiquidModule.java:102-104).
  - Tick wiring: frame liquids sync from the sprite meta BEFORE the fold (Fracker:327 precedent); liquid row appends to `required_results` when the block has a consumeLiquid property; machinery gate widens to (power or liquid) because hasConsumers counts ALL consumers (Block.java:1449); source_delta/time_scale hoisted so the row, the removal and the advance share them.
  - Second-pass removal is a DIRECT removal after `apply_update_consumption_state` under the same guard as Java (`update && efficiency > 0`), edelta from the folded efficiency, through the shared `source_remove_state` (PayloadLoader cache_sums precedent; caps at the held amount, LiquidModule.java:125-128). The AdjacentFactory updates-actor precedent (SourceAdjacentFactoryBuildState.gd:382) does NOT fit: it dispatches through RuntimeConsumer actors carrying liquids/cache_sums/cost_multiplier + source_delta/time_scale, and this driver has no actor infrastructure (no frame "consumers" cache, no cost_multiplier Callable).
  - `_initial_frame` adds `"liquids": {}` (Fracker precedent). Documented limits (1) of the power-row function now records the liquid row live (N2249).
  - Shard note: NO shard changes. The slice registers under UnitCargoLoader.java (the N2165/N2211/N2234 family precedent); the consumer shards select java_source under /world/consumers/ AND require a generated_owner on every mirrored slice — this slice has no generated bridge owner, so it must NOT register under ConsumeLiquid.java (verified: first register run under ConsumeLiquid.java crashed the shard build with `KeyError: 'generated_owner'`).

## Commits

- Slice commit on branch `slice/N2249-unit-cargo-loader-liquid-row` (9 files: driver + proof .gd/.tscn + register + test + report + handoff + spec line + GOAL.md; đã push, remote tip verified by ls-remote — `8d98e988`).
- SSOT slice riêng +2/+1/+1/+2 → 11708/1699/1621/3033; audit 1336, legacy 0.

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 25/25, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2165 power + N2211 gate + N2234 advance: 9/12 PASS, 3 fail đều là proof Godot-absent — không regression.
- Full wave gate: Ran 6110 in 1143.879s, failures=204, skipped=5, 0 errors — 204/204 Godot-absent (197 inherited + 7 new proof tests N2249–N2255).

## SSOT / DEFERRED

- SSOT slice riêng +2/+1/+1/+2 → 11708/1699/1621/3033; audit 1336. **NO shard changes** (see Shard note above).
- DEFERRED 294 (294 − 1 resolved: UnitCargoLoader liquid consumer row + 1 new: liquid consumer build/display rows — ConsumeLiquid.build ReqImage :31-34, display Stat.input :49-52, presentation/stats not tick state).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07UnitCargoLoaderLiquidRowProof` — 6 keys: row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running.
