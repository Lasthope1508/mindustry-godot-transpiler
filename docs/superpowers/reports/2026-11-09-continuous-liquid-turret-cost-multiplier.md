# C05 ContinuousLiquidTurret cost multiplier — N2101

Date: 2026-11-09. Batch: N2101 (single slice). SSOT +2/+1/+0/+0 → 10837 / 1554 / 1441 / 2673; audit `totalSourceFunctions` stays 1335.

## What changed

The last unbound multiplier callback in C05. Java's `Consume.multiplier` is a per-consumer callback (Consume.java:18, default `b -> 1f`); unit factories override it with `b -> state.rules.unitCost(b.team)` (N2096–N2097) and `ContinuousLiquidTurret` overrides it with the ammo lookup in `init()` (ContinuousLiquidTurret.java:45-48): `var ammo = ammoTypes.get(b.liquids.current()); return ammo == null ? 1f : 1f / ammo.ammoMultiplier;` — the `ConsumeLiquidFilter` then pays `1f / ammo.ammoMultiplier` for the bullet type of the building's current liquid, and 1f when the current liquid has no ammo type.

- N2101 extends `SourceConsumeState.source_cost_multiplier_for_block_state(build)` (N2097) with the turret branch: when `block_implementation` is `ContinuousLiquidTurret`, it reads `current_liquid` (`b.liquids.current()` — the last received/loaded liquid, LiquidModule.java:80-83, read in the port from the liquid module's `current` via `SourceLiquidModuleState.source_current_state`) and `ammo_types` (the port form of `ammoTypes`, `ObjectMap<Liquid, BulletType>`, ContinuousLiquidTurret.java:14, mapping liquid name to the bullet type dict that carries `ammoMultiplier`, BulletType.java:95, default 2f) from the frame and returns `1.0 / ammoMultiplier`. Sublimate maps ozone to 1.2f and cyanogen to the 2f default (Blocks.java:4604-4631). A turret frame without the keys its branch needs keeps the 1.0 default, as do all other blocks (N2096–N2099 behavior unchanged — proven by the factory/drill/bare-build regression checks in the proof).

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_continuous_liquid_turret_cost_multiplier.py` (registration + exact-evidence + Godot proof): 3 tests OK.
- Godot proof `ContinuousLiquidTurretCostMultiplierProof` **18/18 true** on the real Main scene: ozone pays 1/1.2, cyanogen pays 1/2, water (no ammo type) pays 1.0, a missing current liquid or missing ammo map pays 1.0; the liquid module's `current` is read live and the frame built from it pays 1/1.2 for ozone; the unit-factory (1.0), drill (1.0) and bare-build (1.0) paths are unchanged, and the live drill frame still carries its consumers.
- Targeted gate (log `~/workspace/logs/targeted-n2101.log`): **5502 tests OK in 1435.571s, exit=0**.
- Full Python suite (log `~/workspace/logs/full-suite-n2101b.log`): **5502 tests OK in 1442.714s**. (The first full-suite run, log `full-suite-n2101.log`, died mid-run with no summary; the b rerun completed clean.)

## SSOT delta

+2 symbols (the two new inputs `current_liquid`, `ammo_types`) / +1 slice / +0 contracts (the owner contract is extended, not replaced) / +0 schemas → 10837 / 1554 / 1441 / 2673; audit `totalSourceFunctions` stays 1335. The owner mirrors into the `defense_*` shards (ContinuousLiquidTurret.java) and the `unit_building_*` shards (the unit-factory branch of the same function).

## Still open

- C05: wiring the turret tick to set the frame keys (`current_liquid` from the liquid module, `ammo_types` from the block) is a later slice — the proof passes frame dicts directly; wiring other buildings (turrets, factories) to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
