# Handoff — C05 GenericCrafter updateConsumption efficiency adapter (N2111)

Date: 2026-11-10. Batch: N2111 (single slice, SSOT slice). Commit: TBD.

## Done

- `SourceFactoryBuildState.source_factory_update_consumption_state(frame, has_consumers, enabled, production_valid, should_consume, efficiency_scale)` runs the shared `SourceBuildingEfficiencyState.update_consumption_state` with the frame's live cheating flag (BuildingComp.java:1943-1951; no `RuntimeConsumer` actors are bound yet — the factory's actor binding is a later slice, like the ContinuousLiquidTurret binding in N2106). The frame's cheating flag is wired live by the N2110 tick, and the tick runs after `updateConsumption` through `Building.update()` (BuildingComp.java:2262-2274), so this adapter is the consumption half of `GenericCrafterBuild.updateTile()` (GenericCrafter.java:235).
- New owner constant `PORT_GAME_SOURCE_FACTORY_BUILD_UPDATE_CONSUMPTION_STATE` in `SourceRuntimeOwnerGameplayRegistry.gd`.
- New test `tools/mindustry_godot_transpiler/tests/test_factory_update_consumption.py` (4 tests: registration, exact-evidence, source-text, proof run) and register script `tools/mindustry_godot_transpiler/register_factory_update_consumption.py`.
- SSOT +12/+1/+1/+2 → 10943 / 1562 / 1459 / 2709; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `production_*` shards.

## Verification

- New test module: 4 tests OK (covered by the targeted gate).
- Godot proof `FactoryUpdateConsumptionProof` 24/24 true on the real Main scene: a silicon-smelter and a graphite-press placed live get their frames wired by the live-loop tick; while the team cheats both frames carry `cheating=true` and the adapter skips consumption at efficiency 1.0 (disabled cheating factory: 0.0); without cheating the same call runs the machinery (efficiency 1.0, not skipped; no-consume: 0.0; no consumers: skipped); uncheating restores the false flag.
- Targeted gate (log `~/workspace/logs/targeted-n2111.log`): **5536 tests OK in 1588.883s, exit=0**.
- Full Python suite (log `~/workspace/logs/full-suite-n2111.log`): **5536 tests OK in 1584.643s, exit=0**; the first attempt (log `full-suite-n2111-killed-by-restart.log`) died in the VM restart at ~01:48.

## Still open

- C05 next: binding the GenericCrafter family `RuntimeConsumer` actors (one per consumeItem/consumeLiquid row, the drill model, N2097/N2100) so the non-cheating consumption path actually consumes, the `GenericCrafterBuild.shouldConsume()` body (GenericCrafter.java:203), and wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer) to the live cheating value. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceFactoryBuildState.gd`
- `godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_slices.json`
- `godot-mindustry/src/generated/source_modules/production_state_schema.json`
- `godot-mindustry/src/generated/source_modules/production_symbols.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/FactoryUpdateConsumptionProof.gd`
- `godot-mindustry/tools/runtime_proofs/FactoryUpdateConsumptionProof.tscn`
- `tools/mindustry_godot_transpiler/register_factory_update_consumption.py`
- `tools/mindustry_godot_transpiler/tests/test_factory_update_consumption.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-10-generic-crafter-update-consumption.md`
- `docs/superpowers/handoffs/2026-11-10-generic-crafter-update-consumption-handoff.md`
