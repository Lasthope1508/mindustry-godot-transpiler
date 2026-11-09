# C05 ContinuousLiquidTurret tick reads ammoTypes from the registry — N2105

Date: 2026-11-09. Batch: N2105 (wiring slice, no SSOT slice). SSOT totals unchanged: 10852 / 1556 / 1444 / 2679; audit `totalSourceFunctions` stays 1335.

## What changed

N2103 left sublimate's ammo map as a source-backed constant in `SourceContinuousLiquidTurretBuildState.gd` because the registry carried no `ammoTypes` for it; N2104 captured the map into the registry. N2105 wires the tick to the registry entry.

- `SourceContinuousLiquidTurretBuildState.source_tick_buildings_state(game)` now reads the ammo map off the catalog block's registry properties — `block.properties.get("ammoTypes", {})` (the block's `ammoTypes`, `ObjectMap<Liquid, BulletType>`, ContinuousLiquidTurret.java:14, captured into `properties["ammoTypes"]` by N2104: sublimate's Blocks.java:4604-4631 map, ozone 1.2f, cyanogen the BulletType 2f default) — instead of the source-backed `SOURCE_CONTINUOUS_LIQUID_TURRET_AMMO_TYPES_BY_BLOCK` constant, which is deleted with its stale comment. A block that carries no `ammoTypes` keeps the `{}` default and the multiplier pays 1.0.
- The frame's `ammo_types` is now the registry entry itself (the same Dictionary object), so a registry mutation shows up in the frame after the next tick — proven live by the extended proof (a probe entry added to the registry entry appears in the frame after one tick, and removing it restores the frame).

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_continuous_liquid_turret_registry_ammo_tick.py` (2 tests): a source-text check that the constant is gone and the tick reads `block.properties.get("ammoTypes", {})`, plus a proof run of `ContinuousLiquidTurretLiveLoopProof`. Ran 2 tests OK in 17.736s.
- Godot proof `ContinuousLiquidTurretLiveLoopProof` **29/29 true** on the real Main scene (extended with 3 checks: `frame_ammo_types_matches_registry`, `frame_ammo_types_tracks_registry`, `frame_ammo_types_tracks_registry_restore`): a sublimate placed live still pays 1/1.2 for ozone, 1/2 for cyanogen and 1.0 for water through `simulate_factory` alone, now with the map coming from the registry.
- Targeted gate (log `~/workspace/logs/targeted-n2105.log`): **5512 tests OK in 1509.550s, exit=0** (0 FAIL sections; exactly one summary line).
- Full Python suite (log `~/workspace/logs/full-suite-n2105c.log`): **5512 tests OK in 1496.842s, exit=0** (0 FAIL sections; exactly one summary line).

Note: a cancelled worker started two full-suite runs before this batch was finished (`full-suite-n2105.log`, 5490 dots, no summary; `full-suite-n2105b.log`, killed at 3276 dots while it ran concurrently with the targeted gate) — neither finished, so neither is a result; the clean rerun is `full-suite-n2105c.log`, 5512 tests OK.

## SSOT delta

No SSOT slice delta — this is a wiring batch, not a register-script slice: no new `source_` function, no new symbols, totals stay 10852 symbols / 1556 slices / 1444 contracts / 2679 schemas; audit `totalSourceFunctions` stays 1335. No shard mirrors change (the changed function was registered by N2103 and already mirrors into the `defense_*` shards).

## Still open

- C05 next: bind a `RuntimeConsumer` for sublimate — the registry now carries `consumeLiquid` at 1/60 for ozone and cyanogen (N2104) and the tick reads the ammo map from the registry (N2105); wiring the consumer into the live loop is the next slice. Wiring other buildings (turrets, factories) to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
