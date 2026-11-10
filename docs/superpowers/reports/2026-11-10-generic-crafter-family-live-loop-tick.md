# C05 GenericCrafter family live-loop tick — N2110

Date: 2026-11-10. Batch: N2110 (single slice, SSOT slice; part of batch N2109–N2110). SSOT +13/+1/+3/+6 → 10931 / 1561 / 1458 / 2707; audit `totalSourceFunctions` stays 1335.

> NOTE: this slice was first built in parallel with the unit-factory
> family slice (N2109, `SourceUnitFactoryBuildState`, 25 symbols, 4
> contracts, 8 schemas) under the same batch number N2109 by two
> workers, which overwrote the shared ledger row and failed N2109's
> registration test. The collision was resolved by renumbering this
> GenericCrafter design to N2110 and landing both slices as batch
> N2109–N2110; the N2109 ledger row lists the unit-factory symbols
> and the N2110 row lists this slice's 13 symbols.

## What changed

N2099 wired the drill tick to refresh its frame's `cheating` flag from the live rules and N2107/N2108 did the same for the power-graph consumer path and the turret family, but the factory family had no tick in the live loop at all: no GenericCrafter-family build carried a frame, and `BuildingComp.updateConsumption()` (BuildingComp.java:1943-1951) could never take its cheating branch live. N2110 wires the family in.

- `SourceFactoryBuildState.source_factory_tick_frame_state(frame, block_implementation, team_id, rules_state)` — sets the frame keys the consumption path reads: `block_implementation` from `block.implementation`, `team_id` and `rules_state` from the sprite meta and the live game rules, `cheating` from `TeamComp.cheating()` via N2099's helper (TeamComp.java:17-19 `return team.rules().cheat;`).
- `SourceFactoryBuildState.source_factory_bind_frame_state(sprite, block)` — binds an empty frame on a factory-family sprite at placement (Block.java:1002 `newBuilding()`, through the Tile.setBlock proximity path).
- `SourceFactoryBuildState.source_factory_tick_buildings_state(game, seconds)` — called from `simulate_factory` every tick (`SourceFactoryRuntimeState.gd`) to refresh each placed factory-family build's frame keys: GenericCrafter/AttributeCrafter/HeatCrafter/HeatProducer, whose builds run `GenericCrafterBuild.updateTile()` (GenericCrafter.java:235). Separator, Incinerator and WallCrafter extend Block directly and SingleBlockProducer extends BlockProducer, so none of them is a GenericCrafterBuild and they are not wired here.

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_factory_live_loop.py` (4 tests: registration, exact-evidence, source-text tick-wires-frame + driver-runs-from-live-loop, reference-graph + proof run) and register script `tools/mindustry_godot_transpiler/register_factory_live_loop.py`.
- Godot proof `FactoryLiveLoopProof` **24/24 true** on the real Main scene (new proof): a silicon-smelter and a graphite-press placed live get their frames bound at placement and ticked every live-loop tick; the team's cheat flag flips both frames live and uncheating restores them; the drill and the duo bind no factory frame.
- Targeted gate (log `~/workspace/logs/targeted-n2109c.log`): **5532 tests OK in 1583.179s** (0 FAIL sections; exactly one summary line).
- Full Python suite (log `~/workspace/logs/full-suite-n2109b.log`): **5532 tests OK in 1566.387s** (0 FAIL sections; exactly one summary line).

## SSOT delta

SSOT +13/+1/+3/+6 → 10931 symbols / 1561 slices / 1458 contracts / 2707 schemas; audit `totalSourceFunctions` stays 1335. N2110 registers 13 symbols and 3 new contracts (the three `SourceFactoryBuildState` functions). Owner mirrors into the `production_*` shards.

## Still open

- C05 next: threading the frame cheating flag into the factory `updateConsumption` efficiency path (BuildingComp.java:1944-1945) so a cheating factory actually skips consumption, and wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer) to the live cheating value. The unit-factory family (UnitFactory/Reconstructor/UnitAssembler) landed as N2109 in the same batch, including its `updateConsumption` adapter. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
