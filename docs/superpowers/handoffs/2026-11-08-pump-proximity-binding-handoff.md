# Handoff — C04 pump proximity scan binding (N2086–N2087)

Date: 2026-11-08. Commit: pending (targeted gate running).

## Done

- N2086 `SourceWorldTerrainRuntimeState.source_floor_liquid_drop_state` — maps a floor block id to its liquidDrop and liquidMultiplier (Blocks.java floor definitions; deep-water/deep-tainted-water 1.5, pooled-cryofluid 0.5, the rest 1.0; non-liquid floors return null).
- N2087 `SourcePumpRuntimeState.source_pump_proximity_state` — the pump's onProximityUpdate (Pump.java:141-152): scans the linked tiles, sets liquidDrop and sums liquidMultiplier for pumpable tiles, stores the result on the pump sprite's meta frame. The pump at (5,14) finds water with amount 1.0.
- Proof `PumpProximityProof` 6/6 true on the real Main scene (floor mapping for shallow-water/deep-water/tar/stone; pump scan water + amount 1.0 + stored; sprite frame matches).
- Register script `tools/mindustry_godot_transpiler/register_pump_proximity_binding.py`; test `tools/mindustry_godot_transpiler/tests/test_pump_proximity_binding.py`.
- SSOT delta +9 symbols / +2 slices / +2 contracts / +4 schemas (totals 10782 / 1542 / 1430 / 2651). Audit `totalSourceFunctions` stays 1335. Production module shards mirror the N2087 owner (all 4 files); the N2086 owner (Blocks.java) mirrors into no shard.

## Verification status

- Targeted gate: 3473 tests OK in 805.660s, exit=0 (log `~/workspace/logs/targeted-n2086.log`).
- Full Python suite: 5471 tests OK in 1304.101s, exit=0 (log `~/workspace/logs/full-suite-n2086.log`).

## Next

- C04: the live-loop pump update (updateTile: pumping into liquids, then dumpLiquid), then a conduit line from the pump to the drill and the live-loop liquid flow (the C04 gate: pump → conduit → Drill uses water automatically).
- C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C05–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
