# Handoff — GenericCrafter progress + craft() in the live loop (N2117)

Date: 2026-11-10. Batch: N2117 (single slice, hybrid: SSOT slice + registry emitter change). Commit: TBD (main turn commits after the full suite — full suite passed 5562 OK, see Verification).

## Done

- New `SourceFactoryBuildState.source_factory_progress_increase_state(craft_time, efficiency, seconds, time_scale)` implements `BuildingComp.getProgressIncrease` (BuildingComp.java:1203-1205): `1f / baseTime * edelta()`, with `edelta()` = efficiency × `delta()` (BuildingComp.java:1927-1929) and `delta()` = `Time.delta * timeScale` (BuildingComp.java:1922-1924); the port edelta is seconds × 60, so one tick at efficiency 1.0 is edelta 1.0 and a smelter gains 1/40.
- New `SourceFactoryBuildState.source_factory_crafter_progress_increase_state(block, liquids, liquid_ids, efficiency, seconds, time_scale)` implements the `GenericCrafterBuild.getProgressIncrease` override (GenericCrafter.java:266-285): `ignoreLiquidFullness` takes the base increase; otherwise the increase scales by `(liquidCapacity - held) / (amount * edelta())` per output liquid, `dumpExtraLiquid` taking `min(max, 1f)` and `!dumpExtraLiquid` taking the minimum scaling.
- New `SourceFactoryBuildState.source_factory_consume_state(frame, consumers, rows)` implements `BuildingComp.consume()` (BuildingComp.java:1911-1915): it triggers every consumer, but only the item rows remove anything (`ConsumeItems.trigger`, ConsumeItems.java:45-48, removes `round(stack.amount * multiplier)`); liquid rows are skipped here. `SourceConsumeItemsState.RuntimeConsumer.trigger(build)` is the new trigger body.
- New `SourceFactoryBuildState.source_factory_offload_state(game, frame, cell, block, item)` implements `BuildingComp.offload(Item)` (BuildingComp.java:1000-1016): `produced(item, 1)`, then the cdump-order proximity loop — the first neighbor that `acceptItem`s and `canDump`s takes the item, otherwise the building keeps it.
- New `SourceFactoryBuildState.source_factory_craft_state(game, frame, cell, block)` implements `GenericCrafterBuild.craft()` (GenericCrafter.java:301-315): `consume()`; each output item is offloaded once per amount; `progress %= 1f`. The consumers and rows are the frame's own bound actors and rows (N2112 binds them, N2116 reinitializes them), so craft takes no separate actor list — the 4-parameter form. A null block crafts nothing. Cheating does not gate craft-time consumption in Java: `consume()` has no cheat check (only per-tick `updateConsumption` early-returns), so a cheating factory still pays its items at the craft.
- The tick driver `source_factory_tick_buildings_state(game, seconds)` (extended in place, still N2110) now advances `frame["progress"]` by the GenericCrafter override when efficiency is above zero and crafts when progress reaches 1.0.
- Emitter: `mindustry_port/content_registry.py` captures `craftTime` for GenericCrafter/AttributeCrafter/HeatCrafter/HeatProducer (the block initializer's own assignment, else the class default 80, GenericCrafter.java:40). 31 blocks carry `craftTime` (silicon smelter 40.0, graphite press 90.0, cryofluid mixer 120.0). The `content_registry_blocks` shard mirror was rebuilt.
- New owner constants `PORT_GAME_SOURCE_FACTORY_BUILD_PROGRESS_INCREASE_STATE`, `PORT_GAME_SOURCE_FACTORY_BUILD_CRAFTER_PROGRESS_INCREASE_STATE`, `PORT_GAME_SOURCE_FACTORY_BUILD_CONSUME_STATE`, `PORT_GAME_SOURCE_FACTORY_BUILD_OFFLOAD_STATE`, `PORT_GAME_SOURCE_FACTORY_BUILD_CRAFT_STATE` in `SourceRuntimeOwnerGameplayRegistry.gd`.
- New test `tools/mindustry_godot_transpiler/tests/test_factory_craft.py` (4 tests) and register script `tools/mindustry_godot_transpiler/register_factory_craft.py` (5 functions, 38 symbols, 5 contracts, 10 schemas).
- SSOT +38/+1/+5/+10 → 11056 / 1568 / 1476 / 2743; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `production_*` shards.

## Verification

- New test module: 4 tests (registration, exact-evidence, tick crafts when progress completes, reference graph and actual C06 gate).
- Godot proof `C06FactoryCraftProof` **42/42 true** on the real Main scene: registry craftTime 40/90/120; base increase 1/40 at edelta 1.0; the GenericCrafter override on the smelter (base) and the cryofluid mixer (full → scaling 0, empty → scaling 1) plus the electrolyzer's two-liquid `dumpExtraLiquid` branches; consume triggers the item rows only; craft consumes + offloads + wraps progress; live, a smelter (20,7) crafts twice in 91 ticks (coal 5 → 3, sand 5 → 1, silicon 0 → 2) and a graphite press (30,7) crafts once (coal 6 → 4, graphite 0 → 1), the smelter's sand-out case reads efficiency 0.0 while the press stays at 1.0.
- Targeted gate **5562 tests OK in 1737.707s** (log `~/workspace/logs/targeted-n2117.log`). Full Python suite **5562 tests OK in 1711.823s** (log `~/workspace/logs/full-suite-n2117.log`).

## Still open

- Deferred in this slice: the continuous liquid output half of `updateTile()` (GenericCrafter.java:241-246, `handleLiquid` per tick), warmup / totalProgress tracking (GenericCrafter.java:238, 259-260), `dumpOutputs()` (GenericCrafter.java:317+). C06 continues: UnitFactory-family RuntimeConsumer binding (deferred since N2109), then the factory→core→defense chain. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceConsumeItemsState.gd`
- `godot-mindustry/src/game/SourceFactoryBuildState.gd`
- `godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd`
- `godot-mindustry/src/generated/MindustryContentRegistry.gd`
- `godot-mindustry/src/generated/content_registry.json`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/content_registry_blocks.json`
- `godot-mindustry/src/generated/source_modules/production_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_slices.json`
- `godot-mindustry/src/generated/source_modules/production_symbols.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/C06FactoryCraftProof.gd`
- `godot-mindustry/tools/runtime_proofs/C06FactoryCraftProof.tscn`
- `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py`
- `tools/mindustry_godot_transpiler/register_factory_craft.py`
- `tools/mindustry_godot_transpiler/tests/test_factory_craft.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-10-generic-crafter-craft.md`
- `docs/superpowers/handoffs/2026-11-10-generic-crafter-craft-handoff.md`
