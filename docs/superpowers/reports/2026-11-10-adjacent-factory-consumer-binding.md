# C05 Adjacent factory families RuntimeConsumer binding — N2115

Date: 2026-11-10. Batch: N2115 (single slice, SSOT slice). SSOT +7/+1/+1/+2 → 11002 / 1566 / 1469 / 2729; audit `totalSourceFunctions` stays 1335.

## What changed

N2114 wired the adjacent families into the live loop, but the machinery still ran over an empty actor list: a non-cheating separator kept its slag forever and a disassembler kept its scrap and slag. N2115 binds the actors, the adjacent-family equivalent of the GenericCrafter binding in N2112 (the drill model, N2097/N2100).

- `SourceAdjacentFactoryBuildState.source_bind_consumer_state(frame, block, catalog, amounts)` — binds one `RuntimeConsumer` actor per `consumeItem`/`consumeLiquid` row from the block's `consumeBuilder`, once (a rebind returns `bound=false` and adds no duplicate); a block with no rows binds none. New owner constant `PORT_GAME_SOURCE_ADJACENT_FACTORY_BUILD_BIND_CONSUMER_STATE` in `SourceRuntimeOwnerGameplayRegistry.gd`.
- The vanilla rows: the separator consumes slag 4/60 per tick (Blocks.java:1244), the disassembler scrap 1 plus slag 0.12 (Blocks.java:1263-1264), the large-cliff-crusher hydrogen 1/60 (Blocks.java:3028) — its graphite booster is an assigned `consumeItem(...).boost()` row (Blocks.java:3030), captured as `boosterItem`, not a `consumeItem` row, so it binds no item actor; the incinerator and the cliff-crusher consume power only (Blocks.java:1328, 3004) and bind none; the power consumer stays the power graph's domain (N2080/N2107). No vanilla block uses SingleBlockProducer, whose dynamic item consumer (`BlockProducer.java:39-45`, `ConsumeItemDynamic`) is not a `consumeItem` row either.
- The tick driver `SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_buildings_state(game, seconds)` now binds each placed adjacent-family frame's consumers, then runs the bound actors through `BuildingComp.updateConsumption`'s first and second passes (`update_consumption_state` + `apply_update_consumption_state`) every tick, with the live cheating flag from N2114. Item rows use `SourceConsumeItemsState.source_bind_item_consumers_state` / `source_runtime_consumer_state` (N2112) and liquid rows `SourceConsumeLiquidState.source_bind_liquid_consumers_state` / `source_runtime_consumer_state` (N2106); `ConsumeItems.efficiency()` (`consumeTriggerValid() || items.has(...)`, ConsumeItems.java:52) gates efficiency on the stacks held, and `ConsumeLiquid.update` drains `amount * edelta * multiplier` every tick (ConsumeLiquid.java:38-40).
- The N2114 proof `AdjacentFactoryLiveLoopProof` seeds slag (10.0) in its separator: N2115 binds the separator's slag actor, so an unseeded separator reads efficiency 0 through the first pass and the proof's live-loop efficiency-1.0 checks failed (first gate attempt caught it at the 7th test). The proof stays 50/50; no new keys.

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_adjacent_factory_consumer_binding.py` (4 tests: registration, exact-evidence, source-text, proof run) and register script `tools/mindustry_godot_transpiler/register_adjacent_factory_consumer_binding.py`.
- Godot proof `AdjacentFactoryConsumerBindingProof` **41/41 true** on the real Main scene (new proof): a separator (30,7) binds 1 actor (slag), a disassembler (35,7) binds 2 (scrap 1, slag 0.12), an incinerator (40,7) and a cliff-crusher (42,7) bind none, a large-cliff-crusher (45,7) binds 1 (hydrogen, booster graphite is no row), a null block binds none; 4 live ticks drain the separator's slag 10.0 → 9.7333 (4/60 per tick) and the disassembler's slag 10.0 → 9.52 (0.12/tick) and the large crusher's hydrogen 10.0 → 9.9333 (1/60 per tick) while the disassembler's scrap stays put; with the disassembler's scrap gone efficiency reads 0.0 and restoring it restores 1.0; while the team cheats the frames carry `cheating=true`, efficiency stays 1.0 and slag is unchanged; uncheating restores the live values and slag drops again.
- Targeted gate 5554 tests FAILED (failures=2, both port-7777 flakes; rerun of the 2 modules 11/11 OK, log `~/workspace/logs/targeted-n2115-rerun.log`). Full Python suite 5554 tests OK in 1620.991s (log `~/workspace/logs/full-suite-n2115b.log`).

## SSOT delta

SSOT +7/+1/+1/+2 → 11002 symbols / 1566 slices / 1469 contracts / 2729 schemas; audit `totalSourceFunctions` stays 1335. N2115 registers 7 symbols and 1 new contract (the `SourceAdjacentFactoryBuildState` binder); the tick driver contract is extended in place under N2114. Owner mirrors into the `production_*` shards.

## Still open

- C05 next: the C05 gate (lifecycle replacement, storage independence, consumer classification). C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
