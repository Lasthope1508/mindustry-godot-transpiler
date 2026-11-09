# C05 ContinuousLiquidTurret live-loop tick and placement frame binding — N2103

Date: 2026-11-09. Batch: N2103 (single slice). SSOT +7/+1/+2/+4 → 10852 / 1556 / 1444 / 2679; audit `totalSourceFunctions` stays 1335.

## What changed

N2102 wired the turret tick, but nothing called it from the live loop and no frame was bound when a sublimate was placed — so the N2101 multiplier was only paid on hand-built frame dicts. N2103 closes that gap: the frame is bound at placement and the tick wiring runs from `simulate_factory` every tick.

- N2103 `SourceContinuousLiquidTurretBuildState.source_bind_frame_state(sprite, block)` — binds the turret frame on the sprite at placement. Java: a placed block's Building is created by `Block.newBuilding()` (Block.java:1002 `public final Building newBuilding(){ return buildType.get(); }`); the port's frame is that Building state, bound through the Tile.setBlock proximity path in `SourceWorldTerrainRuntimeState` — the same path that binds the drill frame on proximity update. A ContinuousLiquidTurret sprite gets an empty frame bound; any other block, or an already-bound sprite, binds nothing.
- N2103 `SourceContinuousLiquidTurretBuildState.source_tick_buildings_state(game)` — called from `simulate_factory` every tick, next to the pump/conduit updates. It iterates the placed buildings, skips anything that is not a ContinuousLiquidTurret, binds the frame if one is somehow missing, and refreshes the frame keys from the live liquid module via N2102's `source_tick_frame_state` (`ContinuousLiquidTurretBuild.updateTile()` calls `super.updateTile()`, ContinuousTurret.java:86-87, running updateConsumption and the multiplier lambda). Sublimate's ammo map is the source-backed Blocks.java:4604-4631 map (ozone 1.2f, cyanogen the BulletType 2f default) held as a constant in the build state until the emitter captures ammoTypes into the content registry.

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_continuous_liquid_turret_live_loop.py` (registration + exact-evidence + Godot proof): 3 tests. Test RED before implementation (2 errors + 1 failure: `KeyError: 'N2103'`, proof parse errors on the missing members), GREEN after (3 tests OK).
- Godot proof `ContinuousLiquidTurretLiveLoopProof` **26/26 true** on the real Main scene: a sublimate placed live at (30,7) gets its frame bound at placement (empty until the first tick), a non-turret block binds nothing and the scenario drill carries no turret frame; the driver ticks the one placed turret (fresh module, water, 1.0) and the live loop keeps it at 1.0; ozone pays 1/1.2, cyanogen 1/2, water 1.0, and ozone again 1/1.2 through `simulate_factory` alone; a second sublimate at (35,7) is bound at placement too and the driver ticks both, the second paying 1/1.2 for ozone live.
- Targeted gate (log `~/workspace/logs/targeted-n2103.log`): **5508 tests OK in 1440.805s, exit=0**.
- Full Python suite: first run died partway (log `full-suite-n2103.log`, 166 dots, no summary — killed, not a code failure); rerun b died at 5422/5508 dots (VM restart 19:48 +07); rerun c died partway (3238 dots, no summary); clean rerun d (log `full-suite-n2103d.log`): **5508 tests OK in 1460.601s, exit=0**.

## SSOT delta

+7 symbols / +1 slice / +2 contracts / +4 schemas → 10852 / 1556 / 1444 / 2679; audit `totalSourceFunctions` stays 1335. The tick driver mirrors into the `defense_*` shards (ContinuousLiquidTurret.java); the bind contract mirrors into no shard (Block.java; like N2098).

## Still open

- C05: capturing `ammoTypes` into the content registry (emitter) so the tick reads the ammo map off the block instead of the source-backed sublimate map in the build state (sublimate carries no `consumeLiquid` or `ammoTypes` in the registry yet, so no `RuntimeConsumer` can be bound for it either); wiring other buildings (turrets, factories) to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
