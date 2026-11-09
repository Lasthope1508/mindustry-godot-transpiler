# Handoff — C05 ContinuousLiquidTurret tick reads ammoTypes from the registry (N2105)

Date: 2026-11-09. Batch: N2105 (wiring slice, no SSOT slice). Commit: af7288d.

## Done

- `SourceContinuousLiquidTurretBuildState.source_tick_buildings_state(game)` now reads the ammo map off the catalog block's registry properties — `block.properties.get("ammoTypes", {})` (the block's `ammoTypes`, ContinuousLiquidTurret.java:14, captured into `properties["ammoTypes"]` by N2104) — instead of the source-backed `SOURCE_CONTINUOUS_LIQUID_TURRET_AMMO_TYPES_BY_BLOCK` constant, which is deleted with its stale comment. A block that carries no `ammoTypes` keeps the `{}` default and the multiplier pays 1.0.
- `godot-mindustry/tools/runtime_proofs/ContinuousLiquidTurretLiveLoopProof.gd` extended with 3 checks: the frame's `ammo_types` matches the registry entry (`frame_ammo_types_matches_registry`), tracks a registry mutation after the next tick (`frame_ammo_types_tracks_registry`), and restores when the mutation is removed (`frame_ammo_types_tracks_registry_restore`).
- New test `tools/mindustry_godot_transpiler/tests/test_continuous_liquid_turret_registry_ammo_tick.py` (2 tests: source-text check + proof run).
- SSOT totals unchanged (wiring batch, no register script): 10852 symbols / 1556 slices / 1444 contracts / 2679 schemas; audit `totalSourceFunctions` stays 1335.

## Verification

- New test module: 2 tests OK in 17.736s.
- Godot proof `ContinuousLiquidTurretLiveLoopProof` 29/29 true on the real Main scene: a sublimate placed live still pays 1/1.2 for ozone, 1/2 for cyanogen and 1.0 for water through `simulate_factory` alone, now with the map coming from the registry; the frame's `ammo_types` is the registry entry and tracks its mutations.
- Targeted gate (log `~/workspace/logs/targeted-n2105.log`): **5512 tests OK in 1509.550s, exit=0** (0 FAIL sections; exactly one summary line).
- Full Python suite (log `~/workspace/logs/full-suite-n2105c.log`): **5512 tests OK in 1496.842s, exit=0** (0 FAIL sections; exactly one summary line).

Note: a cancelled worker started two full-suite runs before this batch was finished (`full-suite-n2105.log`, 5490 dots, no summary; `full-suite-n2105b.log`, killed at 3276 dots while it ran concurrently with the targeted gate) — neither finished, so neither is a result; the clean rerun is `full-suite-n2105c.log`, 5512 tests OK.

## Still open

- C05 next: bind a `RuntimeConsumer` for sublimate — the registry now carries `consumeLiquid` at 1/60 for ozone and cyanogen (N2104) and the tick reads the ammo map from the registry (N2105); wiring the consumer into the live loop is the next slice. Wiring other buildings (turrets, factories) to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceContinuousLiquidTurretBuildState.gd`
- `tools/mindustry_godot_transpiler/tests/test_continuous_liquid_turret_registry_ammo_tick.py`
- `godot-mindustry/tools/runtime_proofs/ContinuousLiquidTurretLiveLoopProof.gd`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-09-continuous-liquid-turret-registry-ammo-tick.md`
- `docs/superpowers/handoffs/2026-11-09-continuous-liquid-turret-registry-ammo-tick-handoff.md`
