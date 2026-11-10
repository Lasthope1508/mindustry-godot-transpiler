# Handoff — C05 Unit-factory family live-loop tick (N2109)

Date: 2026-11-10. Batch: N2109 (single slice, SSOT slice; part of batch N2109–N2110). Commit: `TBD`.

## Done

- `SourceUnitFactoryBuildState.source_unit_factory_tick_frame_state(frame, block_implementation, team_id, rules_state)` sets the frame keys the consumption path reads (`block_implementation` from `block.implementation`; `team_id` and `rules_state` from the sprite meta and the live game rules; `cheating` from `TeamComp.cheating()` via N2099's helper, TeamComp.java:17-19 `return team.rules().cheat;`).
- `SourceUnitFactoryBuildState.source_unit_factory_bind_frame_state(sprite, block)` binds an empty frame on a unit-factory sprite at placement (Block.java:1002 `newBuilding()`, through the Tile.setBlock proximity path).
- `SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state(game, seconds)` is called from `simulate_factory` every tick (`SourceFactoryRuntimeState.gd:187`) to refresh each placed unit-factory build's frame keys (UnitFactory/Reconstructor/UnitAssembler, whose builds run `updateTile()` every tick — UnitFactory.java:392, Reconstructor.java:317, UnitAssembler.java:429 — each running `updateConsumption()` through the Building update).
- `SourceUnitFactoryBuildState.source_unit_factory_update_consumption_state(frame, has_consumers, enabled, production_valid, should_consume, efficiency_scale)` runs the shared `SourceBuildingEfficiencyState.update_consumption_state` with the frame's live cheating flag (BuildingComp.java:1943-1951: when cheating, everything is valid and consumption is skipped; `skipped_consumption = not has_consumers or cheating`). No `RuntimeConsumer` actors are bound yet — the factory's actor binding is a later slice, like the ContinuousLiquidTurret binding in N2106.
- New test `tools/mindustry_godot_transpiler/tests/test_unit_factory_live_loop.py` (4 tests: registration, exact-evidence, source-text, proof run) and register script `tools/mindustry_godot_transpiler/register_unit_factory_live_loop.py`.
- SSOT +25/+1/+4/+8 → 10918 / 1560 / 1455 / 2701; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `unit_building_*` shards.

## Verification

- New test module: 4 tests OK (covered by the targeted gate).
- Godot proof `UnitFactoryLiveLoopProof` 31/31 true on the real Main scene: a groundFactory (30,7), an additiveReconstructor (35,7) and a tankAssembler (40,7) placed live get their frames bound at placement and ticked every live-loop tick; the team's cheat flag flips all three frames live and uncheating restores them; cheating consumption skips at efficiency 1.0, disabled cheating is 0.0, non-cheating runs the machinery.
- Targeted gate (log `~/workspace/logs/targeted-n2109c.log`): **5532 tests OK in 1583.179s** (0 FAIL sections; exactly one summary line). The first gate run (`targeted-n2109.log`) failed on 26 bookkeeping failures — the parallel worker's register script had overwritten the shared N2109 ledger row, so this slice's registration test read the other design's 13 symbols and failed the owner check; no code defect in either design.
- Full Python suite (log `~/workspace/logs/full-suite-n2109b.log`): **5532 tests OK in 1566.387s** (0 FAIL sections; exactly one summary line).

## Still open

- C05 next: the GenericCrafter family landed as N2110 in the same batch; threading the frame cheating flag into the GenericCrafter `updateConsumption` efficiency path, binding the factory `RuntimeConsumer` actors (N2106 pattern), and wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer) to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Collision note — resolved, read before the next batch

This slice was first built in parallel with the GenericCrafter family slice (`SourceFactoryBuildState`, 13 symbols, proof `FactoryLiveLoopProof`) under the same batch number N2109 by two workers. The other worker's register script overwrote the shared N2109 ledger row, so this slice's registration test failed its owner check in the first targeted gate (`~/workspace/logs/targeted-n2109.log`, 26 failures, all bookkeeping). The collision was resolved by renumbering the GenericCrafter design to N2110 and landing both slices as batch N2109–N2110: the N2109 row lists this slice's 25 unit-factory symbols, the N2110 row lists the 13 GenericCrafter symbols, and both families' drivers stay wired into `simulate_factory` (they are disjoint implementation lists with different frame meta keys, so no placed block gets two frames).

## Files

- `godot-mindustry/src/game/SourceUnitFactoryBuildState.gd`
- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd`
- `godot-mindustry/src/game/SourceRuntimeOwnerUnitBuildingRegistry.gd`
- `godot-mindustry/src/game/SourceWorldTerrainRuntimeState.gd`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/unit_building_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/unit_building_slices.json`
- `godot-mindustry/src/generated/source_modules/unit_building_state_schema.json`
- `godot-mindustry/src/generated/source_modules/unit_building_symbols.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/UnitFactoryLiveLoopProof.gd`
- `godot-mindustry/tools/runtime_proofs/UnitFactoryLiveLoopProof.tscn`
- `tools/mindustry_godot_transpiler/register_unit_factory_live_loop.py`
- `tools/mindustry_godot_transpiler/tests/test_unit_factory_live_loop.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-10-unit-factory-family-live-loop-tick.md`
- `docs/superpowers/handoffs/2026-11-10-unit-factory-family-live-loop-tick-handoff.md`
