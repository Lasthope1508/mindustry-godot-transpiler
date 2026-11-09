# Handoff — C05 Turret family live-loop tick (N2108)

Date: 2026-11-10. Batch: N2108 (single slice, SSOT slice). Commit: `PENDING`.

## Done

- `SourceTurretBuildState.source_turret_tick_frame_state(frame, block_implementation, team_id, rules_state)` sets the frame keys the ammo path reads (`block_implementation` from `block.implementation`; `team_id` and `rules_state` from the sprite meta and the live game rules; `cheating` from `TeamComp.cheating()` via N2099's helper, TeamComp.java:17-19 `return team.rules().cheat;`).
- `SourceTurretBuildState.source_turret_bind_frame_state(sprite, block)` binds an empty frame on a Turret-family sprite at placement (Block.java:1002 `newBuilding()`, through the Tile.setBlock proximity path).
- `SourceTurretBuildState.source_turret_tick_buildings_state(game, seconds)` is called from `simulate_factory` every tick (`SourceFactoryRuntimeState.gd:171`) to refresh each placed Turret-family build's frame keys (ItemTurret/LiquidTurret/PowerTurret and their subclasses LaserTurret/ContinuousTurret, whose builds run `TurretBuild.updateTile()`, Turret.java:490; ContinuousLiquidTurret keeps its own driver, N2103).
- `SourceTurretBuildState.source_turret_use_ammo_state(frame, turret_properties, stacks, total_ammo)` implements `TurretBuild.useAmmo()` (Turret.java:680-690): `if(cheating()) return peekAmmo();`, otherwise `entry.amount -= ammoPerShot`, pop when empty, `totalAmmo -= ammoPerShot` clamped at 0 — a cheating duo fires without spending copper, a non-cheating one spends one per shot.
- New test `tools/mindustry_godot_transpiler/tests/test_turret_live_loop.py` (4 tests: registration, exact-evidence, source-text, proof run) and register script `tools/mindustry_godot_transpiler/register_turret_live_loop.py`.
- SSOT +22/+1/+4/+8 → 10893 symbols / 1559 slices / 1451 contracts / 2693 schemas; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `defense_*` shards.

## Verification

- New test module: 4 tests OK (covered by the targeted gate).
- Godot proof `TurretLiveLoopProof` 30/30 true on the real Main scene: the bootstrap duo (19,7) and lancer (25,7) plus a second duo placed live get their frames bound at placement and ticked every live-loop tick; the team's cheat flag flips all three frames live and uncheating restores them; a sublimate binds no turret frame.
- Targeted gate (log `~/workspace/logs/targeted-n2108b.log`): **5524 tests OK in 1523.101s, exit=0** (0 FAIL sections; exactly one summary line). The first gate run (`targeted-n2108.log`) died partway at 5141 dots with no summary; the clean rerun is `targeted-n2108b.log`, 5524 tests OK.
- Full Python suite (log `~/workspace/logs/full-suite-n2108b.log`): **5524 tests OK in 1533.679s, exit=0** (0 FAIL sections; exactly one summary line). The first attempt (`full-suite-n2108.log`, worker-started) died at 902 dots; the clean rerun from the main turn is `full-suite-n2108b.log`, 5524 tests OK.

## Still open

- C05 next: wiring the factory family's own ticks to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceTurretBuildState.gd`
- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd`
- `godot-mindustry/src/game/SourceRuntimeOwnerTurretRegistry.gd`
- `godot-mindustry/src/game/SourceTurretSourceTextState.gd`
- `godot-mindustry/src/game/SourceWorldTerrainRuntimeState.gd`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/defense_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/TurretLiveLoopProof.gd`
- `godot-mindustry/tools/runtime_proofs/TurretLiveLoopProof.tscn`
- `tools/mindustry_godot_transpiler/register_turret_live_loop.py`
- `tools/mindustry_godot_transpiler/tests/test_turret_live_loop.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-10-turret-family-live-loop-tick.md`
- `docs/superpowers/handoffs/2026-11-10-turret-family-live-loop-tick-handoff.md`
