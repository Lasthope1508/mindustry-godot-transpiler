# Handoff — UnitFactory-family RuntimeConsumer binding (N2120)

Date: 2026-11-11. Batch: N2120 (single slice, SSOT slice, emitter change for `unitPlans`). Commit: TBD (targeted gate running; the main turn commits/pushes after the gate).

## Done

- New `SourceUnitFactoryBuildState.source_bind_consumer_state(frame, block, catalog, amounts)` binds one `RuntimeConsumer` actor per `consumeItem`/`consumeLiquid` row from the block's `consumeBuilder` (the drill model, N2097/N2100; the GenericCrafter binding in N2112) plus one per requirement of the frame's current plan (the `ConsumeItemDynamic`, UnitFactory.java:84). A UnitFactory block carries no static rows — its items come from the plan — so a ground-factory with no plan binds none, with the dagger plan binds 2 (silicon 10, lead 10); a Reconstructor binds its `consumeItems` stacks (additive-reconstructor silicon 40 + graphite 40, Blocks.java:6307); a UnitAssembler binds its `consumeLiquid` rows (tank-assembler cyanogen 0.15, Blocks.java:6537). Actors bind once (a rebind returns `bound=false`, no duplicates); a bound frame records `frame["block_id"]` and `frame["bound_plan"]`. Each actor pays through the N2097 cost-multiplier callback (`Rules.unitCost` for this family, UnitFactory.java:109, Reconstructor.java:149, UnitAssembler.java:175).
- New `SourceUnitFactoryBuildState.source_unit_factory_plan_requirements_state(block, plan_index)` reads the current plan's unit, build time and requirements from the registry's `unitPlans` (UnitPlan, UnitFactory.java:207-218; `UnitFactoryBuild.unit()`, UnitFactory.java:264-266, reads `plans.get(currentPlan)`). A null block, a block without plans, or an index outside the plans has no requirements — the `ConsumeItemDynamic` then reads `ItemStack.empty` (UnitFactory.java:84). The config handler clamps an out-of-range index to -1 (UnitFactory.java:60-62); `updateTile` forces plan 0 when the block is not configurable (UnitFactory.java:392-394).
- New `SourceUnitFactoryBuildState.source_unit_factory_reinitialize_consumers_state(frame, block, catalog, amounts)` implements `Block.reinitializeConsumers()` (Block.java:1481-1497) over `Tile.changeBuild` (Tile.java:636-657) and over a plan change (UnitFactory config resets progress, not the ItemModule, UnitFactory.java:60-62): a frame already on this block and plan takes the normal once-only bind path (`reinitialized=false`); a frame stamped for another block drops its old actors (N2100's invalidate), clears its item and liquid stores for the fresh Building's own empty ItemModule/LiquidModule (BuildingComp.java:145-146), and rebinds from the new block's rows; a frame stamped for another plan drops its old actors and rebinds from the new plan's requirements, keeping the held items and liquids. A null block reinitializes nothing.
- The tick driver `source_unit_factory_tick_buildings_state(game, seconds)` (extended in place, still N2109) now runs the consumption half of `updateTile()` every tick: it reinitializes through the path above, then runs the bound actors through `BuildingComp.updateConsumption`'s first and second passes with the live cheating flag. `shouldConsume` is the frame's enabled flag until the per-class bodies land; `hasConsumers` is the block-level `Block.hasConsumers` (consumeItem/consumeLiquid/consumePower/unitPlans in the registry). The power consumer stays the power graph's domain (N2080/N2107).
- New owner constants `PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_BIND_CONSUMER_STATE`, `PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_PLAN_REQUIREMENTS_STATE`, `PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE` in `SourceRuntimeOwnerUnitBuildingRegistry.gd`.
- Emitter change: `content_registry.py` now captures `unitPlans` per UnitFactory block — `plans = Seq.with(new UnitPlan(...))` (ground/air/naval factories) and `plans.add(new UnitPlan(...))` (the single-plan Erekir fabricators). Registry: ground-factory 3 plans (dagger silicon 10 + lead 10 / 900 ticks, crawler, nova), air-factory 2, naval-factory 2, tank-fabricator 1 (stell beryllium 40 + silicon 50 / 2100 ticks), ship-fabricator 1, mech-fabricator 1. The `content_registry_blocks` shard mirror was rebuilt; all shards on disk equal a fresh build.
- New test `tools/mindustry_godot_transpiler/tests/test_unit_factory_consumer_binding.py` (4 tests) and register script `tools/mindustry_godot_transpiler/register_unit_factory_consumer_binding.py` (3 functions, 20 symbols, 3 contracts, 6 schemas).
- SSOT +20/+1/+3/+6 → 11133 / 1571 / 1487 / 2765; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `unit_building_*` shards (`unit_building_state_schema` legitimately excludes the three new per-function schemas by design — it derives only from tick-driver contracts, the N2118 `production_state_schema` precedent).
- Coordination: two agents built this slice in the same tree. The cron agent wrote the emitter change (Seq.with plans only), the GDScript and the registry constants, and finished. This turn reconciled the two copies instead of redoing the work: removed the duplicate prefixed bind function (the tick wires through the file-local `source_bind_consumer_state`, the N2112 factory pattern) and the duplicated preload block and owner constant, fixed two wrong `shouldConsume()` line numbers in a tick comment (UnitFactory.java:446, Reconstructor.java:368 — not 449/366), added the missing `source_owner` to the plan-requirements returns, and extended the emitter to the fabricators' `plans.add(...)` form with a test. Both edited GDScript files parse clean (`godot --check-only`, exit 0).

## Verification

- New test module: 4 tests (registration, exact-evidence, tick binds runtime consumers, reference graph and actual unit-factory consumer binding). Standalone run: 4/4 OK in 15.817s. Extended registry test `test_block_registry_captures_unit_factory_plans` (now also covers the `plans.add` fabricator form): 1/1 OK.
- Godot proof `UnitFactoryConsumerBindingProof` **45/45 true** on the real Main scene (counted from the JSON): the ground-factory binds its dagger plan (silicon 10, lead 10) and none without a plan, the additive-reconstructor binds 2 (silicon 40, graphite 40), the tank-assembler binds 1 (cyanogen 0.15); plan-change reinitialize rebinds to the crawler plan (silicon 8, coal 10) keeping the held items, block-change reinitialize rebinds to the reconstructor rows clearing the items, same-block reinitialize is a no-op; 4 live ticks drain the assembler's cyanogen 10.0 → 9.4 while items stay put; no items → efficiency 0.0 and no power, restored → 1.0; team unitCostMultiplier 2.0 → efficiency 0.0, restored → 1.0; cheating holds efficiency 1.0 with cyanogen unchanged, uncheating resumes the drain.
- Targeted gate: **5575 tests OK in 1725.671s** (log `~/workspace/logs/targeted-n2120.log`). Full Python suite: **5575 tests OK in 1718.966s** (log `~/workspace/logs/full-suite-n2120.log`).

## Still open

- Deferred in this slice: the per-class `shouldConsume()` bodies (UnitFactory.java:446, Reconstructor.java:368, UnitAssembler.java:389 — the tick passes the frame enabled flag until they land), the plan stacks leaving only at unit completion via `ConsumeItemDynamic.trigger` (ConsumeItemDynamic.java:53-56 — the production slice owns the trigger), the UnitAssembler plan dynamics (`ConsumePayloadDynamic` over the plan's payload stacks, `ConsumeItemDynamic` over `plan().itemReq`, `ConsumeLiquidsDynamic` over `plan().liquidReq`, UnitAssembler.java:158-160 — the registry captures no assembler plans yet). C06 continues: the factory→core→defense chain (a session proof driving the whole existing chain end-to-end is the next candidate). C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
- Pre-existing spec gaps (not this batch's to backfill): the N2119 migration-log row is still missing (the log jumps N2118 → N2120), and the N2119 checklist row's proof count says 42/42 while the proof JSON has 43 keys. N2111–N2116 checklist/cube rows are still missing (only migration-log rows exist).

## Files

- `godot-mindustry/src/game/SourceUnitFactoryBuildState.gd`
- `godot-mindustry/src/game/SourceRuntimeOwnerUnitBuildingRegistry.gd`
- `godot-mindustry/src/generated/MindustryContentRegistry.gd`
- `godot-mindustry/src/generated/content_registry.json`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/content_registry_blocks.json`
- `godot-mindustry/src/generated/source_modules/unit_building_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/unit_building_slices.json`
- `godot-mindustry/src/generated/source_modules/unit_building_symbols.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/UnitFactoryConsumerBindingProof.gd`
- `godot-mindustry/tools/runtime_proofs/UnitFactoryConsumerBindingProof.tscn`
- `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py`
- `tools/mindustry_godot_transpiler/register_unit_factory_consumer_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_content_registry.py`
- `tools/mindustry_godot_transpiler/tests/test_unit_factory_consumer_binding.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-11-unit-factory-consumer-binding.md`
- `docs/superpowers/handoffs/2026-11-11-unit-factory-consumer-binding-handoff.md`
