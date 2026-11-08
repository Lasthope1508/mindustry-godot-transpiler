# Handoff — C04 mechanical pump placement binding (N2085)

Date: 2026-11-08. Commit: pending (targeted gate running).

## Done

- N2085 `SourceWorldInitialBuildRuntimeState.source_mechanical_pump_placement_state` — places a mechanical pump at (5,14) in the bootstrap world (Blocks.java:2298-2302, `pumpAmount = 7f/60f`, `liquidCapacity = 20f`), on the water region's north-west corner, via the initial-build plan through record_placed_block. The pump is size 1 and floating, so it sits on the shallow-water floor.
- Proof `MechanicalPumpPlacementProof` 5/5 true on the real Main scene (placement, live sprite at (5,14), floor `shallow-water`, graph now 12 consumers with needed 6.0/60, produced 0.12/60, coverage 0.02).
- Register script `tools/mindustry_godot_transpiler/register_mechanical_pump_placement_binding.py`; test `tools/mindustry_godot_transpiler/tests/test_mechanical_pump_placement_binding.py`.
- SSOT delta +8 symbols / +1 slice / +1 contract / +2 schemas (totals 10773 / 1540 / 1428 / 2647). Audit `totalSourceFunctions` stays 1335. No module shard changed (Blocks.java owner).

## Verification status

- Targeted gate: 3470 tests OK in 802.942s (rerun; the first run had 4 stale-pin failures, fixed to consumer_count 12).
- Full Python suite: 5468 tests OK in 1297.740s (log `~/workspace/logs/full-suite-n2085.log`).

## Next

- C04: the pump proximity scan (onProximityUpdate) and live-loop pump update (updateTile), then a conduit line from the pump to the drill and the live-loop liquid flow (the C04 gate: pump → conduit → Drill uses water automatically).
- C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C05–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
