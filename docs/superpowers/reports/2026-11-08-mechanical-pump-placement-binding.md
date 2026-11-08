# C04 mechanical pump placement binding — N2085

Date: 2026-11-08. Batch: N2085 (single slice, second C04 batch).

## What changed

N2085 places a mechanical pump in the bootstrap world, on the water region from N2084, so the C04 gate has a water source. The pump extracts water from the shallow-water floor (Blocks.java:2298-2302: `mechanicalPump = new Pump("mechanical-pump")`, `pumpAmount = 7f / 60f`, `liquidCapacity = 20f`).

- New consts `PUMP_POS (5,14)` in `SourcePlayableWorldLayoutDefaults.gd`, `BLOCK_MECHANICAL_PUMP "mechanical-pump"` in `SourcePlayableContentDefaults.gd`, `INITIAL_BUILD_ROLE_MECHANICAL_PUMP` — all re-exported by `SourcePlayableScenarioDefaults.gd`.
- `SourceWorldInitialBuildRuntimeState.source_mechanical_pump_placement_state(tile_size) -> Dictionary` → `{block_id, role, cell, x, y, pump_amount 7/60, liquid_capacity 20.0}`. The pump is size 1 and floating, placed on the water region's north-west corner (5,14), so its linked tiles include water tiles it can pump from. `initial_build_plan_state` appends it after the lancer.
- Proof `MechanicalPumpPlacementProof` 5/5 true on the real Main scene: the placement returns the right block/role/cell/amount/capacity; the live sprite at (5,14) is the pump; the tile at (5,14) has floor `shallow-water`; the placed power graph now has 12 consumers (the pump is a usage-0 consumer in the runtime's classification, like the drill/core/conveyors/duo), with power_needed 6.0/60, power_produced 0.12/60 and coverage 0.02 unchanged.

## Verification

- Targeted gate: the new binding test + the water region + the recent power/placement binding tests + `test_power_graph_live_update_binding` + `test_source_catalog_validator` + the audit/shard tests inside `test_source_symbols` + `test_liquid_consumer_hydration` + `test_playable` — **3470 tests OK in 802.942s**. The first run (3467 tests, 4 failures) was the stale pins: the pump is a usage-0 power consumer, so the N2077/N2078/N2079/N2080/N2081 proofs pinning consumer_count 11 now see 12; the pins were updated to 12 (origins 13 → 14, footprint keys 29 → 30 in the grouping proof) and the rerun is clean.
- Full Python suite: **5468 tests OK in 1297.740s** (log `~/workspace/logs/full-suite-n2085.log`).

## SSOT delta

+8 symbols / +1 slice / +1 contract / +2 schemas. Totals: 10773 symbols / 1540 slices / 1428 contracts / 2647 schemas. Audit `totalSourceFunctions` stays 1335 (no PortGame facade function added). No module shard changed (no module selection matches `content/Blocks.java`, the geometry/Teams precedent).

## Still open

- C04: the pump proximity scan (onProximityUpdate: amount and liquidDrop from the linked water tiles), the live-loop pump update (updateTile: pumping into liquids, then dumpLiquid to the conduits), the conduit line from the pump to the drill, and the live-loop liquid flow (the C04 gate). C03 full-power live case deferred. C02 live-loop sprite wiring + per-belt clogHeat persistence. C05–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
