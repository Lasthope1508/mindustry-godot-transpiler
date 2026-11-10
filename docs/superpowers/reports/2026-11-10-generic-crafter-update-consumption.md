# C05 GenericCrafter updateConsumption efficiency adapter — N2111

Date: 2026-11-10. Batch: N2111 (single slice, SSOT slice). SSOT +12/+1/+1/+2 → 10943 / 1562 / 1459 / 2709; audit `totalSourceFunctions` stays 1335.

## What changed

N2110 wired the factory family's frame keys live (the tick refreshes the `cheating` flag from `team.rules().cheat` every `simulate_factory` tick), but nothing read that flag on the consumption path: a cheating silicon-smelter still ran the full consumer machinery. N2111 threads the flag through, the GenericCrafter equivalent of N2109's unit-factory adapter.

- `SourceFactoryBuildState.source_factory_update_consumption_state(frame, has_consumers, enabled, production_valid, should_consume, efficiency_scale)` — runs the shared `SourceBuildingEfficiencyState.update_consumption_state` with the frame's live cheating flag (BuildingComp.java:1943-1951). When cheating, the early return fires (`if(!block.hasConsumers || cheating()){`): `potentialEfficiency` from `enabled` and `productionValid`, `efficiency` from `shouldConsume`, no consumer updated, `shouldConsumePower` true. A non-cheating factory runs the machinery over its (still empty) actor list. `skipped_consumption` is the Java early-return condition itself. The tick runs after `updateConsumption` through `Building.update()` (BuildingComp.java:2262-2274), so this adapter is the consumption half of `GenericCrafterBuild.updateTile()` (GenericCrafter.java:235).
- New owner constant `PORT_GAME_SOURCE_FACTORY_BUILD_UPDATE_CONSUMPTION_STATE` in `SourceRuntimeOwnerGameplayRegistry.gd` (next to the other factory constants).

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_factory_update_consumption.py` (4 tests: registration, exact-evidence, source-text, proof run) and register script `tools/mindustry_godot_transpiler/register_factory_update_consumption.py`.
- Godot proof `FactoryUpdateConsumptionProof` **24/24 true** on the real Main scene (new proof): a silicon-smelter and a graphite-press placed live get their frames wired by the live-loop tick; while the team cheats both frames carry `cheating=true` and the adapter skips consumption at efficiency 1.0 (disabled cheating factory: 0.0); without cheating the same call runs the machinery (efficiency 1.0, not skipped; no-consume: 0.0; no consumers: skipped); uncheating restores the false flag.
- Targeted gate (log `~/workspace/logs/targeted-n2111.log`): **5536 tests OK in 1588.883s, exit=0**.
- Full Python suite (log `~/workspace/logs/full-suite-n2111.log`): **5536 tests OK in 1584.643s, exit=0**; the first attempt (log `full-suite-n2111-killed-by-restart.log`) died in the VM restart at ~01:48.

## SSOT delta

SSOT +12/+1/+1/+2 → 10943 symbols / 1562 slices / 1459 contracts / 2709 schemas; audit `totalSourceFunctions` stays 1335. N2111 registers 12 symbols and 1 new contract (the `SourceFactoryBuildState` adapter). Owner mirrors into the `production_*` shards.

## Still open

- C05 next: binding the GenericCrafter family `RuntimeConsumer` actors (one per consumeItem/consumeLiquid row, the drill model, N2097/N2100) so the non-cheating consumption path actually consumes, the `GenericCrafterBuild.shouldConsume()` body (GenericCrafter.java:203), and wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer) to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
