# Handoff — C04 conduit rotation + updateTile (N2091–N2092)

Date: 2026-11-08. Commit: pending (targeted gate running).

## Done

- N2091 `SourceWorldInitialBuildRuntimeState.source_conduit_rotation_state` — the rotation per conduit cell (Conduit.java:48, `rotate = true`): the 5 north-running conduits (5,13)-(5,9) point north (rotation 1) and the 2 east-running conduits (5,8), (6,8) point east (rotation 0), so `tile.nearby(rotation)` reaches the next conduit or the drill; `build_world` applies the rotations to the conduit sprites' "rotation" meta after the block layer.
- N2092 `SourceConduitRuntimeState.source_conduit_update_state` (new file) — the conduit's updateTile (Conduit.java:249-255): smoothLiquid lerps toward currentAmount / liquidCapacity (0.05), and when the conduit holds more than 0.0001 liquid and its flow timer (timerFlow, 1s) fires, it calls moveLiquidForward(leaks, liquids.current()) via the bound moveLiquid (pressure fractions); the flow timer and smoothLiquid live on the conduit sprite's meta frame. `simulate_factory` calls it for each conduit cell each frame. The drill's liquidCapacity is 30 (Block.java:1407-1418).
- Proof `ConduitUpdateProof` 5/5 true on the real Main scene (rotations live on the sprites; one second of flow pushes (first - second) to the next conduit; a 0.1s update moves nothing).
- Register script `tools/mindustry_godot_transpiler/register_conduit_update_binding.py`; test `tools/mindustry_godot_transpiler/tests/test_conduit_update_binding.py`.
- SSOT delta +11 symbols / +2 slices / +2 contracts / +4 schemas (totals 10813 / 1547 / 1435 / 2661). Audit `totalSourceFunctions` stays 1335. Neither owner mirrors into a module shard.

## Verification status

- Targeted gate: 3482 tests OK in 845.188s, exit=0 (log `~/workspace/logs/targeted-n2091.log`).
- Full Python suite: 5480 tests OK in 1330.005s, exit=0 (log `~/workspace/logs/full-suite-n2091b.log`; the first run was interrupted by a VM restart at 16:48 and rerun).

## Next

- C04: the drill water booster, then the live-loop liquid flow (the C04 gate: pump → conduit → Drill uses water as a booster).
- C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C05–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
