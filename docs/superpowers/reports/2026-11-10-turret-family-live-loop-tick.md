# C05 Turret family live-loop tick — N2108

Date: 2026-11-10. Batch: N2108 (single slice, SSOT slice). SSOT +22/+1/+4/+8 → 10893 / 1559 / 1451 / 2693; audit `totalSourceFunctions` stays 1335.

## What changed

N2099 wired the drill tick to refresh its frame's `cheating` flag from the live rules and N2106/N2107 did the same for the ContinuousLiquidTurret tick and the power-graph consumer path, but the turret family had no tick in the live loop at all: no Turret-family build carried a frame, and `TurretBuild.useAmmo()` (Turret.java:680-690) was never reached live. N2108 wires the family in.

- `SourceTurretBuildState.source_turret_tick_frame_state(frame, block_implementation, team_id, rules_state)` — sets the frame keys the ammo path reads: `block_implementation` from `block.implementation`, `team_id` and `rules_state` from the sprite meta and the live game rules, `cheating` from `TeamComp.cheating()` via N2099's helper (TeamComp.java:17-19 `return team.rules().cheat;`).
- `SourceTurretBuildState.source_turret_bind_frame_state(sprite, block)` — binds an empty frame on a Turret-family sprite at placement (Block.java:1002 `newBuilding()`, through the Tile.setBlock proximity path).
- `SourceTurretBuildState.source_turret_tick_buildings_state(game, seconds)` — called from `simulate_factory` every tick (`SourceFactoryRuntimeState.gd:171`) to refresh each placed Turret-family build's frame keys: ItemTurret/LiquidTurret/PowerTurret and their subclasses LaserTurret/ContinuousTurret, whose builds run `TurretBuild.updateTile()` (Turret.java:490). ContinuousLiquidTurret keeps its own driver (N2103).
- `SourceTurretBuildState.source_turret_use_ammo_state(frame, turret_properties, stacks, total_ammo)` — implements `TurretBuild.useAmmo()` (Turret.java:680-690): `if(cheating()) return peekAmmo();`, otherwise `entry.amount -= ammoPerShot`, pop when empty, `totalAmmo -= ammoPerShot` clamped at 0. A cheating duo fires without spending copper; a non-cheating one spends one per shot.

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_turret_live_loop.py` (4 tests: registration, exact-evidence, source-text tick-wires-frame + useAmmo-reads-cheating, reference-graph + proof run) and register script `tools/mindustry_godot_transpiler/register_turret_live_loop.py`.
- Godot proof `TurretLiveLoopProof` **30/30 true** on the real Main scene (new proof): the bootstrap duo (19,7) and lancer (25,7) plus a second duo placed live get their frames bound at placement and ticked every live-loop tick; the team's cheat flag flips all three frames live and uncheating restores them; a sublimate binds no turret frame.
- Targeted gate (log `~/workspace/logs/targeted-n2108b.log`): **5524 tests OK in 1523.101s, exit=0** (0 FAIL sections; exactly one summary line). The first gate run (`targeted-n2108.log`) died partway at 5141 dots with no summary; the clean rerun is `targeted-n2108b.log`, 5524 tests OK.
- Full Python suite (log `~/workspace/logs/full-suite-n2108b.log`): **5524 tests OK in 1533.679s, exit=0** (0 FAIL sections; exactly one summary line). The first attempt (`full-suite-n2108.log`, worker-started) died at 902 dots when the worker's execution ended; the clean rerun from the main turn is `full-suite-n2108b.log`, 5524 tests OK.

## SSOT delta

SSOT +22/+1/+4/+8 → 10893 symbols / 1559 slices / 1451 contracts / 2693 schemas; audit `totalSourceFunctions` stays 1335. N2108 registers 22 symbols and 4 new contracts (the four `SourceTurretBuildState` functions). Owner mirrors into the `defense_*` shards.

## Still open

- C05 next: wiring the factory family's own ticks to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
