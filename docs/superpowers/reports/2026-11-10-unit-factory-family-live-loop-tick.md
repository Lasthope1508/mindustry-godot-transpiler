# C05 Unit-factory family live-loop tick — N2109

Date: 2026-11-10. Batch: N2109 (single slice, SSOT slice; part of batch N2109–N2110). SSOT +25/+1/+4/+8 → 10918 / 1560 / 1455 / 2701; audit `totalSourceFunctions` stays 1335.

> NOTE: this slice was first built in parallel with the GenericCrafter
> family slice (N2110, `SourceFactoryBuildState`, 13 symbols, 3
> contracts, 6 schemas) under the same batch number N2109 by two
> workers; the other worker's register script overwrote the shared
> N2109 ledger row and failed this slice's registration test (26
> failures, all bookkeeping). The collision was resolved by renumbering
> the GenericCrafter design to N2110 and landing both slices as batch
> N2109–N2110; the N2109 ledger row lists this slice's 25 symbols and
> the N2110 row lists the GenericCrafter symbols.

## What changed

N2099 wired the drill tick to refresh its frame's `cheating` flag from the live rules and N2106–N2108 did the same for the ContinuousLiquidTurret tick, the power-graph consumer path and the turret family, but the unit-factory family had no tick in the live loop at all: no UnitFactory/Reconstructor/UnitAssembler build carried a frame, and `BuildingComp.updateConsumption()` (BuildingComp.java:1943-1951) could never take its cheating branch live. N2109 wires the family in.

- `SourceUnitFactoryBuildState.source_unit_factory_tick_frame_state(frame, block_implementation, team_id, rules_state)` — sets the frame keys the consumption path reads: `block_implementation` from `block.implementation`, `team_id` and `rules_state` from the sprite meta and the live game rules, `cheating` from `TeamComp.cheating()` via N2099's helper (TeamComp.java:17-19 `return team.rules().cheat;`). These are the three classes that set each consumer's multiplier to `Rules.unitCost` (UnitFactory.java:109, Reconstructor.java:149, UnitAssembler.java:175).
- `SourceUnitFactoryBuildState.source_unit_factory_bind_frame_state(sprite, block)` — binds an empty frame on a unit-factory sprite at placement (Block.java:1002 `newBuilding()`, through the Tile.setBlock proximity path).
- `SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state(game, seconds)` — called from `simulate_factory` every tick (`SourceFactoryRuntimeState.gd:187`) to refresh each placed unit-factory build's frame keys: UnitFactory/Reconstructor/UnitAssembler, whose builds run `updateTile()` every tick (UnitFactory.java:392, Reconstructor.java:317, UnitAssembler.java:429), each running `updateConsumption()` through the Building update.
- `SourceUnitFactoryBuildState.source_unit_factory_update_consumption_state(frame, has_consumers, enabled, production_valid, should_consume, efficiency_scale)` — runs the shared `SourceBuildingEfficiencyState.update_consumption_state` with the frame's live cheating flag (BuildingComp.java:1943-1951: when cheating, everything is valid and consumption is skipped; `skipped_consumption = not has_consumers or cheating`). No `RuntimeConsumer` actors are bound yet — the factory's actor binding is a later slice, like the ContinuousLiquidTurret binding in N2106 — so a cheating factory takes the early return and pays nothing, while a non-cheating one runs the machinery over its (still empty) actor list.

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_unit_factory_live_loop.py` (4 tests: registration, exact-evidence, source-text tick-wires-frame + update-consumption-reads-cheating, reference-graph + proof run) and register script `tools/mindustry_godot_transpiler/register_unit_factory_live_loop.py`.
- Godot proof `UnitFactoryLiveLoopProof` **31/31 true** on the real Main scene (new proof): a groundFactory (30,7), an additiveReconstructor (35,7) and a tankAssembler (40,7) placed live get their frames bound at placement and ticked every live-loop tick; the team's cheat flag flips all three frames live and uncheating restores them; cheating consumption skips at efficiency 1.0, disabled cheating is 0.0, non-cheating runs the machinery.
- Targeted gate (log `~/workspace/logs/targeted-n2109c.log`): **5532 tests OK in 1583.179s** (0 FAIL sections; exactly one summary line). The first gate run (`targeted-n2109.log`) failed on 26 bookkeeping failures — the parallel worker's register script had overwritten the shared N2109 ledger row, so this slice's registration test read the other design's 13 symbols and failed the owner check; no code defect in either design.
- Full Python suite (log `~/workspace/logs/full-suite-n2109b.log`): **5532 tests OK in 1566.387s** (0 FAIL sections; exactly one summary line).

## SSOT delta

SSOT +25/+1/+4/+8 → 10918 symbols / 1560 slices / 1455 contracts / 2701 schemas; audit `totalSourceFunctions` stays 1335. N2109 registers 25 symbols and 4 new contracts (the four `SourceUnitFactoryBuildState` functions). Owner mirrors into the `unit_building_*` shards.

## Still open

- C05 next: the GenericCrafter family landed as N2110 in the same batch; threading the frame cheating flag into the GenericCrafter `updateConsumption` efficiency path, binding the factory `RuntimeConsumer` actors (N2106 pattern), and wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer) to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
