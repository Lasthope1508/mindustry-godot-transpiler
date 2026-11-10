# Handoff — C05 GenericCrafter RuntimeConsumer binding (N2112)

Date: 2026-11-10. Batch: N2112 (single slice, SSOT slice). Commit: 073d4c9.

## Done

- `SourceFactoryBuildState.source_bind_consumer_state(frame, block, catalog, amounts)` binds one `RuntimeConsumer` actor per `consumeItem`/`consumeLiquid` row from the block's `consumeBuilder` (the drill model, N2097/N2100; binds once, a block without rows binds none), and the tick driver `source_factory_tick_buildings_state(game, seconds)` now binds each placed factory frame's consumers, then runs the bound actors through `BuildingComp.updateConsumption`'s second pass every tick with the live cheating flag from N2110/N2111.
- `SourceConsumeItemsState.source_bind_item_consumers_state(block, content_catalog)` and `SourceConsumeItemsState.source_runtime_consumer_state(definition, items, cost_multiplier)` — a `RuntimeConsumer` actor (RefCounted) per item row, implementing `ConsumeItems.efficiency()` (`consumeTriggerValid() || items.has(...)`); `Consume.update` has no body (Consume.java:52), so items leave only at `craft()` via trigger — a later slice.
- New owner constant `PORT_GAME_SOURCE_FACTORY_BUILD_BIND_CONSUMER_STATE` in `SourceRuntimeOwnerGameplayRegistry.gd`.
- New test `tools/mindustry_godot_transpiler/tests/test_factory_consumer_binding.py` (4 tests: registration, exact-evidence, source-text, proof run) and register script `tools/mindustry_godot_transpiler/register_factory_consumer_binding.py`.
- SSOT +14/+1/+3/+6 → 10957 / 1563 / 1462 / 2715; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `production_*` shards.

## Verification

- New test module: 4 tests OK (covered by the targeted gate).
- Godot proof `FactoryConsumerBindingProof` 33/33 true on the real Main scene: a silicon-smelter (30,7) binds 2 actors (coal 1, sand 2), a cryofluid-mixer (35,7) binds 2 (titanium 1, water 0.2), an electric-heater (40,7, HeatProducer) binds none, a null block binds none; 4 live ticks drain the mixer's water 10.0 → 9.2 while item stacks stay put; with the smelter's items gone efficiency reads 0.0 and restoring them restores 1.0; while the team cheats the frames carry `cheating=true`, efficiency stays 1.0 and water is unchanged; uncheating restores the live values and water drops again.
- Targeted gate (log `~/workspace/logs/targeted-n2112.log`): **5540 tests OK in 1604.451s, exit=0**.
- Full Python suite (log `~/workspace/logs/full-suite-n2112f.log`): **5540 tests OK in 1615.108s, exit=0**; attempts a–e died mid-run without a summary line.

## Still open

- C05 next: the `GenericCrafterBuild.shouldConsume()` body (GenericCrafter.java:203, output-space checks), wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer) to the live cheating value, and the C05 gate (lifecycle replacement, storage independence, consumer classification). C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceConsumeItemsState.gd`
- `godot-mindustry/src/game/SourceFactoryBuildState.gd`
- `godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_slices.json`
- `godot-mindustry/src/generated/source_modules/production_symbols.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/FactoryConsumerBindingProof.gd`
- `godot-mindustry/tools/runtime_proofs/FactoryConsumerBindingProof.tscn`
- `tools/mindustry_godot_transpiler/register_factory_consumer_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_factory_consumer_binding.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-10-generic-crafter-consumer-binding.md`
- `docs/superpowers/handoffs/2026-11-10-generic-crafter-consumer-binding-handoff.md`
