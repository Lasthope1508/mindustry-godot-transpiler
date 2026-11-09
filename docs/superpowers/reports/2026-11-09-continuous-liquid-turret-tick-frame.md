# C05 ContinuousLiquidTurret tick frame wiring — N2102

Date: 2026-11-09. Batch: N2102 (single slice). SSOT +8/+1/+1/+2 → 10845 / 1555 / 1442 / 2675; audit `totalSourceFunctions` stays 1335.

## What changed

N2101 bound the turret multiplier branch, but only on hand-built frame dicts — no tick fed it live. N2102 wires the turret tick to set the frame keys the multiplier reads, so the multiplier is actually paid live. Java's tick is `ContinuousLiquidTurretBuild.updateTile()`; the multiplier lambda it feeds runs during `updateConsumption` and reads `b.liquids.current()` and the block's `ammoTypes` (ContinuousLiquidTurret.java:45-48): `var ammo = ammoTypes.get(b.liquids.current()); return ammo == null ? 1f : 1f / ammo.ammoMultiplier;`.

- N2102 `SourceContinuousLiquidTurretBuildState.source_tick_frame_state(frame, block_implementation, liquids, liquid_names_by_id, ammo_types)` — sets the frame keys before the consumers run, like the drill tick sets its keys (N2097): `block_implementation` from the block so the N2101 branch dispatches; `current_liquid` is `b.liquids.current()` — the last received/loaded liquid (LiquidModule.java:80-83) — read from the liquid module's `current` via `SourceLiquidModuleState.source_current_state` and resolved to its content name (Java resolves a liquid by id through `content.liquid(id)`; LiquidModule.java:24 seeds `current` with `content.liquid(0)`, the first liquid, water); `ammo_types` is the block's `ammoTypes` (`ObjectMap<Liquid, BulletType>`, ContinuousLiquidTurret.java:14) in port form. A module without a current id, or an id with no content name, leaves `current_liquid` null and the multiplier keeps its 1.0 default.

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_continuous_liquid_turret_tick_frame.py` (registration + exact-evidence + Godot proof): 3 tests.
- Godot proof `ContinuousLiquidTurretTickFrameProof` **19/19 true** on the real Main scene: a sublimate placed live at (30,7) gets its frame wired by the tick — ozone pays 1/1.2, cyanogen 1/2, water 1.0; a fresh module (current = water, the LiquidModule.java:24 seed) and a module with no current id keep the 1.0 default; the frame keys are refreshed on each tick call.
- Targeted gate (log `~/workspace/logs/targeted-n2102c.log`): **5505 tests OK in 1435.089s, exit=0** (the first two attempts died partway — worker-started, then the 17:47 +07 VM restart — with no summary; the clean rerun from the main turn finished).
- Full Python suite (log `~/workspace/logs/full-suite-n2102b.log`): **5505 tests OK in 1435.817s, exit=0** (the worker-started first attempt died at 166 dots with no summary; the clean rerun from the main turn finished).

## SSOT delta

+8 symbols / +1 slice / +1 contract / +2 schemas → 10845 / 1555 / 1442 / 2675; audit `totalSourceFunctions` stays 1335. The owner mirrors into the `defense_*` shards (ContinuousLiquidTurret.java).

## Still open

- C05: calling the tick wiring from the live loop (`simulate_factory`) every tick and binding the turret frame on placement are later slices — the proof wires a placed turret frame directly; capturing `ammoTypes` into the content registry (emitter) so the tick can read the ammo map off the block instead of taking it as a parameter is a later slice (sublimate carries no `consumeLiquid` or `ammoTypes` in the registry yet, so no `RuntimeConsumer` can be bound for it either); wiring other buildings (turrets, factories) to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
