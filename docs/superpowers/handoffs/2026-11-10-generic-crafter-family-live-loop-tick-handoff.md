# Handoff — C05 GenericCrafter family live-loop tick (N2110)

Date: 2026-11-10. Batch: N2110 (single slice, SSOT slice; part of batch N2109–N2110). Commit: `TBD`.

## Done

- `SourceFactoryBuildState.source_factory_tick_frame_state(frame, block_implementation, team_id, rules_state)` sets the frame keys the consumption path reads (`block_implementation` from `block.implementation`; `team_id` and `rules_state` from the sprite meta and the live game rules; `cheating` from `TeamComp.cheating()` via N2099's helper, TeamComp.java:17-19 `return team.rules().cheat;`).
- `SourceFactoryBuildState.source_factory_bind_frame_state(sprite, block)` binds an empty frame on a factory-family sprite at placement (Block.java:1002 `newBuilding()`, through the Tile.setBlock proximity path).
- `SourceFactoryBuildState.source_factory_tick_buildings_state(game, seconds)` is called from `simulate_factory` every tick (`SourceFactoryRuntimeState.gd`) to refresh each placed factory-family build's frame keys (GenericCrafter/AttributeCrafter/HeatCrafter/HeatProducer, whose builds run `GenericCrafterBuild.updateTile()`, GenericCrafter.java:235; AttributeCrafterBuild does not override updateTile, HeatCrafterBuild/HeatProducerBuild call super.updateTile() first). Separator, Incinerator and WallCrafter extend Block directly and SingleBlockProducer extends BlockProducer, so none of them is a GenericCrafterBuild.
- New test `tools/mindustry_godot_transpiler/tests/test_factory_live_loop.py` (4 tests: registration, exact-evidence, source-text, proof run) and register script `tools/mindustry_godot_transpiler/register_factory_live_loop.py`.
- SSOT +13/+1/+3/+6 → 10931 / 1561 / 1458 / 2707; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `production_*` shards.

## Verification

- New test module: 4 tests OK (covered by the targeted gate).
- Godot proof `FactoryLiveLoopProof` 24/24 true on the real Main scene: a silicon-smelter and a graphite-press placed live get their frames bound at placement and ticked every live-loop tick; the team's cheat flag flips both frames live and uncheating restores them; the drill and the duo bind no factory frame.
- Targeted gate (log `~/workspace/logs/targeted-n2109c.log`): **5532 tests OK in 1583.179s** (0 FAIL sections; exactly one summary line).
- Full Python suite (log `~/workspace/logs/full-suite-n2109b.log`): **5532 tests OK in 1566.387s** (0 FAIL sections; exactly one summary line).

## Still open

- C05 next: threading the frame cheating flag into the factory `updateConsumption` efficiency path (BuildingComp.java:1944-1945) so a cheating factory actually skips consumption, and wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer) to the live cheating value. The unit-factory family (UnitFactory/Reconstructor/UnitAssembler) landed as N2109 in the same batch, including its `updateConsumption` adapter. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Collision note — resolved, read before the next batch

This slice was first built in parallel with the unit-factory family slice (UnitFactory/Reconstructor/UnitAssembler, `SourceUnitFactoryBuildState`, 4 functions incl. `source_unit_factory_update_consumption_state`, proof `UnitFactoryLiveLoopProof`, test `test_unit_factory_live_loop`, register script `register_unit_factory_live_loop.py`) under the same batch number N2109 by two workers. The worker's register script overwrote the shared N2109 ledger row, so the unit-factory registration test failed its owner check in the first targeted gate (`~/workspace/logs/targeted-n2109.log`, 26 failures, all bookkeeping). The collision was resolved by renumbering this GenericCrafter design to N2110 and landing both slices as batch N2109–N2110: the N2109 row lists the 25 unit-factory symbols, the N2110 row lists this slice's 13 GenericCrafter symbols, and both families' drivers stay wired into `simulate_factory` (they are disjoint implementation lists with different frame meta keys, so no placed block gets two frames).

## Files

- `godot-mindustry/src/game/SourceFactoryBuildState.gd`
- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd`
- `godot-mindustry/src/game/SourceWorldTerrainRuntimeState.gd`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_slices.json`
- `godot-mindustry/src/generated/source_modules/production_state_schema.json`
- `godot-mindustry/src/generated/source_modules/production_symbols.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/FactoryLiveLoopProof.gd`
- `godot-mindustry/tools/runtime_proofs/FactoryLiveLoopProof.tscn`
- `tools/mindustry_godot_transpiler/register_factory_live_loop.py`
- `tools/mindustry_godot_transpiler/tests/test_factory_live_loop.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-10-generic-crafter-family-live-loop-tick.md`
- `docs/superpowers/handoffs/2026-11-10-generic-crafter-family-live-loop-tick-handoff.md`
