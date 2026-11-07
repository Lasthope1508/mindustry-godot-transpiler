# C04 water region binding — N2084

Date: 2026-11-08. Batch: N2084 (single slice, first C04 batch).

## What changed

N2084 adds a water region to the bootstrap world, so a pump has water to pump (C04 gate: pump → conduit → Drill uses water). The shallow-water floor's liquidDrop is water (Blocks.java:224-234: `water = new Floor("shallow-water")`, `liquidDrop = Liquids.water;`, `isLiquid = true;`).

- New consts `WATER_MIN (5,14)` / `WATER_MAX (8,17)` in `SourcePlayableWorldLayoutDefaults.gd`, re-exported by `SourcePlayableScenarioDefaults.gd`, plus `water_cells()` mirroring `ore_copper_cells()`. The region is south of the drill, free of buildings and ore.
- `SourceWorldTerrainRuntimeState.source_water_region_state(world_tiles, water_block) -> Dictionary` → `{cells, count, reason}` — sets the floor of the 16 region cells to the water block. `source_game_world_tiles_state` applies it after the stone floor (the wiring is folded into this slice, the N2068 lesson).
- Proof `WaterRegionProof` 5/5 true on the real Main scene: the region function returns 16 cells with count 16; the live tiles at (5,14) and (8,17) have floor `shallow-water`, and the drill tile at (7,8) still has floor `stone`.

## Verification

- Targeted gate: the new binding test + the recent power/placement binding tests + `test_source_catalog_validator` + the audit/shard tests inside `test_source_symbols` + `test_liquid_consumer_hydration` + `test_playable` — **3464 tests OK in 781.002s**.
- Full Python suite: **5465 tests OK in 1276.264s** (log `~/workspace/logs/full-suite-n2084.log`).

## SSOT delta

+5 symbols / +1 slice / +1 contract / +2 schemas. Totals: 10765 symbols / 1539 slices / 1427 contracts / 2645 schemas. Audit `totalSourceFunctions` stays 1335 (no PortGame facade function added). No module shard changed (no module selection matches `content/Blocks.java`, the geometry/Teams precedent).

## Still open

- C04: the pump placement on the water (mechanical-pump, pumpAmount 7/60), the conduit line to the drill, and the live-loop liquid flow (the C04 gate). C03 full-power live case (coverage 1.0 with produced >= needed) is deferred — it needs 4 large solar panels, which would flip the world to surplus and break the battery discharge proof; the coverage-1.0 math is proven at the module level (via battery) and via the needed-0 branch.
- C02 live-loop sprite wiring + per-belt clogHeat persistence. C05–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
