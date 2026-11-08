# C04 conduit rotation + updateTile — N2091–N2092

Date: 2026-11-08. Batch: N2091–N2092 (two slices, sixth C04 batch).

## What changed

N2091 is the conduit rotation placement: conduits are rotatable (Conduit.java:48, `rotate = true`), and the bootstrap line needs each conduit pointing at the next cell toward the drill — the 5 north-running conduits (5,13)-(5,9) point north (rotation 1) and the 2 east-running conduits (5,8), (6,8) point east (rotation 0) — so `tile.nearby(rotation)` in moveLiquidForward reaches the next conduit or the drill. `build_world` applies the rotations to the conduit sprites' "rotation" meta after the block layer (wiring folded into the slice). Rotation convention (Java): 0 east, 1 north, 2 west, 3 south; in the runtime's y-down coordinates north is (0,-1).

N2092 is the conduit's updateTile (Conduit.java:249-255): smoothLiquid lerps toward `liquids.currentAmount() / liquidCapacity` (0.05), and when the conduit holds more than 0.0001 liquid and its flow timer (timerFlow, 1s) fires, it calls `moveLiquidForward(leaks, liquids.current())` — the bound moveLiquid (pressure fractions, BuildingComp.java:939+) to the block in its rotation direction, or leaks a puddle (`leakAmount = liquids.get(liquid) / 1.5f`, BuildingComp.java:930-935) when there is no building ahead. The flow timer and smoothLiquid live on the conduit sprite's meta frame, so they persist across frames. `simulate_factory` calls the update for each conduit cell each frame (wiring folded into the slice). The drill's liquidCapacity is 30 (Block.java:1407-1418: a block with a liquid consumer and no explicit liquidCapacity gets `round(10 * max(1, consumer amount * 60))`; the mechanical drill consumes water 0.05f, so 30). The leak branch's puddle deposit is not modeled in this runtime (no puddle system in the live loop); the leaked amount leaves the conduit.

- `SourceWorldInitialBuildRuntimeState.source_conduit_rotation_state(tile_size) -> Dictionary` → `{block_id, rotations, count}`. Rotations keyed by conduit cell.
- `SourceConduitRuntimeState.source_conduit_update_state(game, cell, delta) -> Dictionary` → `{liquid, flowed, smooth_liquid, flow_timer}`. One second of flow moves (source - destination) to the next conduit (pressure equalization with equal capacities); a small delta does not fire the flow timer.
- Proof `ConduitUpdateProof` 5/5 true on the real Main scene: the rotations are 1 for (5,13) and (5,9), 0 for (5,8) and (6,8), and live on the sprites; one second of pumping + the pump dump fills (5,13), and the conduit update with delta 1.0 pushes (first - second) to (5,12) so the two conduits swap amounts; a 0.1s update moves nothing. The proof asserts deltas, not absolutes, because the live loop already ticked the pump (and its dump) during setup.

## Verification

- Targeted gate: the new binding test + the recent placement/power binding tests + `test_power_graph_live_update_binding` + `test_source_catalog_validator` + the audit/shard tests inside `test_source_symbols` + `test_liquid_consumer_hydration` + `test_playable` — **3482 tests OK in 845.188s, exit=0** (log `~/workspace/logs/targeted-n2091.log`).
- Full Python suite: **5480 tests OK in 1330.005s, exit=0** (log `~/workspace/logs/full-suite-n2091b.log`; the first full-suite run was interrupted by a VM restart at 16:48 and rerun).

## SSOT delta

+11 symbols / +2 slices / +2 contracts / +4 schemas. Totals: 10813 symbols / 1547 slices / 1435 contracts / 2661 schemas. Audit `totalSourceFunctions` stays 1335 (no PortGame facade function added). Neither owner mirrors into a module shard (Blocks.java and Conduit.java match no module selection).

## Still open

- C04: the drill water booster (the mechanical drill consumes water 0.05f as a booster, 1.6x speed — Drill.java:38 liquidBoostIntensity) and the live-loop liquid flow (the C04 gate: pump → conduit → Drill uses water as a booster). C03 full-power live case deferred. C02 live-loop sprite wiring + per-belt clogHeat persistence. C05–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
