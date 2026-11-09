# Handoff — C05 ContinuousLiquidTurret live-loop tick and placement frame binding (N2103)

Date: 2026-11-09. Batch: N2103 (single slice). Commit: 4a875e9.

## Done

- `SourceContinuousLiquidTurretBuildState.source_bind_frame_state(sprite, block)` — binds the turret frame on the sprite at placement (Block.java:1002 `newBuilding()` creates the Building when the block is placed; bound through the Tile.setBlock proximity path in `SourceWorldTerrainRuntimeState`, the same path that binds the drill frame). A ContinuousLiquidTurret sprite gets an empty frame bound; any other block, or an already-bound sprite, binds nothing.
- `SourceContinuousLiquidTurretBuildState.source_tick_buildings_state(game)` — called from `simulate_factory` every tick: iterates the placed buildings, skips non-turrets, binds a missing frame instead of crashing the loop, and refreshes each placed ContinuousLiquidTurret's frame keys from its live liquid module via N2102's `source_tick_frame_state`, so the N2101 cost multiplier is actually paid live. Sublimate's ammo map is the source-backed Blocks.java:4604-4631 constant (ozone 1.2f, cyanogen the 2f default) until the emitter captures ammoTypes into the content registry.
- Register script `tools/mindustry_godot_transpiler/register_continuous_liquid_turret_live_loop.py`; test `tools/mindustry_godot_transpiler/tests/test_continuous_liquid_turret_live_loop.py`; proof `godot-mindustry/tools/runtime_proofs/ContinuousLiquidTurretLiveLoopProof.gd/.tscn`.
- SSOT +7/+1/+2/+4 → 10852 symbols / 1556 slices / 1444 contracts / 2679 schemas; audit `totalSourceFunctions` stays 1335. The tick driver mirrors into the `defense_*` shards (ContinuousLiquidTurret.java); the bind contract mirrors into no shard (Block.java; like N2098).

## Verification

- Test 3 tests (registration + exact-evidence + Godot proof). RED before implementation (2 errors + 1 failure), GREEN after.
- Godot proof `ContinuousLiquidTurretLiveLoopProof` 26/26 true on the real Main scene: a sublimate placed live at (30,7) gets its frame bound at placement and pays 1/1.2 for ozone, 1/2 for cyanogen and 1.0 for water through `simulate_factory` alone, refreshing on each tick (ozone again 1/1.2 after water); a second sublimate at (35,7) is bound at placement too and the driver ticks both.
- Targeted gate (log `~/workspace/logs/targeted-n2103.log`): 5508 tests OK in 1440.805s, exit=0.
- Full Python suite: first run died partway (log `full-suite-n2103.log`, 166 dots, no summary — killed, not a code failure); rerun b died at 5422/5508 dots (VM restart 19:48 +07); rerun c died partway (3238 dots, no summary); clean rerun d (log `full-suite-n2103d.log`): **5508 tests OK in 1460.601s, exit=0**.

## Still open

- C05 next: capturing `ammoTypes` into the content registry (emitter) so the tick can read the ammo map off the block instead of the source-backed sublimate map (sublimate carries no `consumeLiquid` or `ammoTypes` in the registry yet, so no `RuntimeConsumer` can be bound for it either); wiring other buildings (turrets, factories) to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceContinuousLiquidTurretBuildState.gd`
- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd`
- `godot-mindustry/src/game/SourceWorldTerrainRuntimeState.gd`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/defense_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/ContinuousLiquidTurretLiveLoopProof.gd`
- `godot-mindustry/tools/runtime_proofs/ContinuousLiquidTurretLiveLoopProof.tscn`
- `tools/mindustry_godot_transpiler/register_continuous_liquid_turret_live_loop.py`
- `tools/mindustry_godot_transpiler/tests/test_continuous_liquid_turret_live_loop.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-09-continuous-liquid-turret-live-loop.md`
- `docs/superpowers/handoffs/2026-11-09-continuous-liquid-turret-live-loop-handoff.md`
