# Handoff — C05 Adjacent factory families RuntimeConsumer binding (N2115)

Date: 2026-11-10. Batch: N2115 (single slice, SSOT slice). Commit: (by the main turn).

## Done

- New `SourceAdjacentFactoryBuildState.source_bind_consumer_state(frame, block, catalog, amounts)` binds one `RuntimeConsumer` actor per `consumeItem`/`consumeLiquid` row from the block's `consumeBuilder` (the drill model, N2097/N2100; the GenericCrafter binding in N2112), once (a rebind returns `bound=false` and adds no duplicate); a block without consume rows binds none. New owner constant `PORT_GAME_SOURCE_ADJACENT_FACTORY_BUILD_BIND_CONSUMER_STATE`.
- The tick driver `source_adjacent_factory_tick_buildings_state(game, seconds)` now binds each placed adjacent-family frame's consumers, then runs the bound actors through `BuildingComp.updateConsumption`'s first and second passes every tick with the live cheating flag from N2114 (item rows via `SourceConsumeItemsState`, liquid rows via `SourceConsumeLiquidState`, each paying through the N2097 cost-multiplier callback).
- The vanilla rows: separator slag 4/60 per tick (Blocks.java:1244), disassembler scrap 1 + slag 0.12 (Blocks.java:1263-1264), large-cliff-crusher hydrogen 1/60 (Blocks.java:3028) — its graphite booster is an assigned `consumeItem(...).boost()` row (Blocks.java:3030), captured as `boosterItem`, not a `consumeItem` row; incinerator and cliff-crusher consume power only (Blocks.java:1328, 3004) and bind none. No vanilla block uses SingleBlockProducer, whose dynamic item consumer (BlockProducer.java:39-45, `ConsumeItemDynamic`) is not a `consumeItem` row.
- New test `tools/mindustry_godot_transpiler/tests/test_adjacent_factory_consumer_binding.py` (4 tests) and register script `tools/mindustry_godot_transpiler/register_adjacent_factory_consumer_binding.py` (1 function, 7 symbols, 1 contract, 2 schemas).
- The N2114 proof `AdjacentFactoryLiveLoopProof` seeds slag (10.0) in its separator (N2115 binds its slag actor; an unseeded separator reads efficiency 0 through the first pass). The proof stays 50/50; no new keys. First gate attempt caught the failure at the 7th test and was relaunched after the fix.
- SSOT +7/+1/+1/+2 → 11002 / 1566 / 1469 / 2729; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `production_*` shards.

## Verification

- New test module: 4 tests OK.
- Godot proof `AdjacentFactoryConsumerBindingProof` 41/41 true on the real Main scene: separator (30,7) binds 1 (slag), disassembler (35,7) binds 2 (scrap 1, slag 0.12), incinerator (40,7) and cliff-crusher (42,7) bind none, large-cliff-crusher (45,7) binds 1 (hydrogen); 4 live ticks drain separator slag 10.0 → 9.7333, disassembler slag 10.0 → 9.52, large-crusher hydrogen 10.0 → 9.9333 while scrap stays put; no scrap → efficiency 0.0 and no power, restored → 1.0; cheating holds efficiency 1.0 with slag unchanged; uncheating resumes the drain.
- Targeted gate 5554 tests FAILED (failures=2, both port-7777 flakes; rerun of the 2 modules 11/11 OK, log `~/workspace/logs/targeted-n2115-rerun.log`). Full Python suite 5554 tests OK in 1620.991s (log `~/workspace/logs/full-suite-n2115b.log`).

## Still open

- C05 next: the C05 gate (lifecycle replacement, storage independence, consumer classification). C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceAdjacentFactoryBuildState.gd`
- `godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_slices.json`
- `godot-mindustry/src/generated/source_modules/production_symbols.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/AdjacentFactoryConsumerBindingProof.gd`
- `godot-mindustry/tools/runtime_proofs/AdjacentFactoryConsumerBindingProof.tscn`
- `godot-mindustry/tools/runtime_proofs/AdjacentFactoryLiveLoopProof.gd`
- `tools/mindustry_godot_transpiler/register_adjacent_factory_consumer_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_adjacent_factory_consumer_binding.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-10-adjacent-factory-consumer-binding.md`
- `docs/superpowers/handoffs/2026-11-10-adjacent-factory-consumer-binding-handoff.md`
