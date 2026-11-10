# Handoff — C05 GenericCrafter shouldConsume() body (N2113)

Date: 2026-11-10. Batch: N2113 (single slice, SSOT slice). Commit: ca05555.

## Done

- `SourceFactoryBuildState.source_factory_should_consume_state(frame, block, liquids, liquid_ids)` implements `GenericCrafterBuild.shouldConsume()` (GenericCrafter.java:203-231): output-item blocking at `itemCapacity`, output-liquid blocking at `liquidCapacity - 0.001f` with the `dumpExtraLiquid` / `ignoreLiquidFullness` branches and the all-liquids-full rule, else `enabled`. The tick driver calls it every tick with the catalog's `liquid_id_by_name`, so a placed factory with a full output ticks at efficiency 0.
- Registry captures `outputItems`/`outputLiquids`/`liquidCapacity` for the GenericCrafter family in `content_registry.py` (singular forms, `LiquidStack.with(...)` plural form, last-wins initializer assignment else the `Block.init()` computed default; commented-out assignments do not resolve).
- New owner constant `PORT_GAME_SOURCE_FACTORY_BUILD_SHOULD_CONSUME_STATE` in `SourceRuntimeOwnerGameplayRegistry.gd`.
- New test `tools/mindustry_godot_transpiler/tests/test_factory_should_consume.py` (4 tests: registration, exact-evidence, source-text, proof run) and register script `tools/mindustry_godot_transpiler/register_factory_should_consume.py`.
- SSOT +8/+1/+1/+2 → 10965 / 1564 / 1463 / 2717; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `production_*` shards.

## Verification

- New test module: 4 tests OK (covered by the targeted gate).
- Godot proof `FactoryShouldConsumeProof` 30/30 true on the real Main scene: smelter silicon 9 consumes / 10 item-blocked; mixer cryofluid 35.0 consumes / 36.0 all-liquids-full; electrolyzer one liquid full still consumes with dumpExtraLiquid (default true) but blocks when false, both full blocks; ignoreLiquidFullness consumes through a full output; disabled never consumes; null block consumes; live, a blocked smelter/mixer tick at efficiency 0 with water untouched, room restores 1.0 and the drain.
- Targeted gate (log `~/workspace/logs/targeted-n2113b.log`): **5545 tests OK in 1631.413s, exit=0** (clean rerun; first attempt `targeted-n2113.log` died at 917 tests when a stray-cleanup killed the gate itself).
- Full Python suite (log `~/workspace/logs/full-suite-n2113b.log`): **5545 tests OK in 1591.730s, exit=0**.

## Still open

- C05 next: wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer) to the live cheating value, and the C05 gate (lifecycle replacement, storage independence, consumer classification). The craft/progress slice owns `ConsumeItems.trigger` at `craft()` (GenericCrafter.java:301-303). C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceFactoryBuildState.gd`
- `godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd`
- `godot-mindustry/src/generated/MindustryContentRegistry.gd`
- `godot-mindustry/src/generated/content_registry.json`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_slices.json`
- `godot-mindustry/src/generated/source_modules/production_state_schema.json`
- `godot-mindustry/src/generated/source_modules/production_symbols.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/FactoryShouldConsumeProof.gd`
- `godot-mindustry/tools/runtime_proofs/FactoryShouldConsumeProof.tscn`
- `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py`
- `tools/mindustry_godot_transpiler/register_factory_should_consume.py`
- `tools/mindustry_godot_transpiler/tests/test_content_registry.py`
- `tools/mindustry_godot_transpiler/tests/test_factory_should_consume.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-10-generic-crafter-should-consume.md`
- `docs/superpowers/handoffs/2026-11-10-generic-crafter-should-consume-handoff.md`
