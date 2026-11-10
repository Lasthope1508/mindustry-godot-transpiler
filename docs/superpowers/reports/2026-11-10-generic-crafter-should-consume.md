# C05 GenericCrafter shouldConsume() — N2113

Date: 2026-11-10. Batch: N2113 (single slice, SSOT slice). SSOT +8/+1/+1/+2 → 10965 / 1564 / 1463 / 2717; audit `totalSourceFunctions` stays 1335.

## What changed

N2112 bound the RuntimeConsumer actors, but the tick still passed the frame's enabled flag as should_consume, so a factory kept crafting with a full output. N2113 implements the `GenericCrafterBuild.shouldConsume()` body (GenericCrafter.java:203-231) and wires it into the live-loop tick.

- `SourceFactoryBuildState.source_factory_should_consume_state(frame, block, liquids, liquid_ids)` — an output item blocks when the held stack plus one output would exceed itemCapacity (`if(items.get(output.item) + output.amount > itemCapacity){`, GenericCrafter.java:205); an output liquid blocks when the held amount reaches liquidCapacity - 0.001f and the block does not dump the extra (`if(liquids.get(output.liquid) >= liquidCapacity - 0.001f){`, GenericCrafter.java:216, `if(!dumpExtraLiquid){`, GenericCrafter.java:217), unless ignoreLiquidFullness skips the liquid check entirely (GenericCrafter.java:212); when every output liquid is full the block cannot reproduce (`if(allFull){`, GenericCrafter.java:226). Otherwise the build consumes when enabled (`return enabled;`, GenericCrafter.java:230). Returns `should_consume`, `item_blocked`, `liquid_blocked`, `all_liquids_full`. New owner constant `PORT_GAME_SOURCE_FACTORY_BUILD_SHOULD_CONSUME_STATE` in `SourceRuntimeOwnerGameplayRegistry.gd`.
- The registry (`content_registry.py`) captures the block's `outputItems`/`outputLiquids` for the GenericCrafter family: the singular `outputItem`/`outputLiquid` (written to the plural arrays by `GenericCrafter.init()`, GenericCrafter.java:120-124), the `LiquidStack.with(...)` plural form (electrolyzer's ozone + hydrogen), and `liquidCapacity` — the initializer's own assignment (last wins, e.g. surge-crucible's `80f * 5`), else `Block.init()`'s computed default (Block.java:1407-1418: `round(10 * consumeAmount)`). A commented-out `//outputItem` does not resolve (slag-centrifuge's scrap line). New test `test_block_registry_captures_generic_crafter_outputs_and_liquid_capacity` in `test_content_registry.py`.
- The tick driver `SourceFactoryBuildState.source_factory_tick_buildings_state(game, seconds)` now calls shouldConsume every tick with the catalog's `liquid_id_by_name`, replacing the enabled-flag placeholder; a placed factory with a full output ticks at efficiency 0. The liquid module is read through its id-indexed array (`_liquid_amount_state`, LiquidModule.java:23,102); `dumpExtraLiquid` defaults true and `ignoreLiquidFullness` false (GenericCrafter.java:37-38).
- New test `tools/mindustry_godot_transpiler/tests/test_factory_should_consume.py` (4 tests: registration, exact-evidence, source-text, proof run) and register script `tools/mindustry_godot_transpiler/register_factory_should_consume.py`.

## Verification

- New test module: 4 tests OK (covered by the targeted gate).
- Godot proof `FactoryShouldConsumeProof` **30/30 true** on the real Main scene (new proof): a silicon-smelter (30,7) with silicon 9 consumes and with 10 is item-blocked; a cryofluid-mixer (35,7) with cryofluid 35.0 consumes and with 36.0 is all-liquids-full; an electrolyzer (40,7) with one liquid full still consumes with dumpExtraLiquid (default true) but blocks when it is false, and both full blocks; ignoreLiquidFullness consumes through a full output; a disabled build never consumes and a null block has no outputs; live, a blocked smelter/mixer tick at efficiency 0.0 with the mixer's water untouched, room restores 1.0 and the 0.2/tick drain resumes.
- Targeted gate (log `~/workspace/logs/targeted-n2113b.log`): **5545 tests OK in 1631.413s, exit=0** (clean rerun; first attempt `targeted-n2113.log` died at 917 tests when a stray-cleanup killed the gate itself).
- Full Python suite (log `~/workspace/logs/full-suite-n2113b.log`): **5545 tests OK in 1591.730s, exit=0**.

## SSOT delta

SSOT +8/+1/+1/+2 → 10965 symbols / 1564 slices / 1463 contracts / 2717 schemas; audit `totalSourceFunctions` stays 1335. N2113 registers 8 symbols and 1 new contract (the `SourceFactoryBuildState` shouldConsume function); the N2110 tick contract's rule and tests are extended, not re-registered. Owner mirrors into the `production_*` shards.

## Still open

- C05 next: wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer) to the live cheating value, and the C05 gate (lifecycle replacement, storage independence, consumer classification). The craft/progress slice owns `ConsumeItems.trigger` at `craft()` (GenericCrafter.java:301-303); shouldConsume only gates the start of a craft. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
