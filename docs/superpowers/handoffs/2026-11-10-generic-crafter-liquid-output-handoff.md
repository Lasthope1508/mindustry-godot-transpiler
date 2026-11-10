# Handoff — GenericCrafter warmup / liquid output / totalProgress in the live loop (N2118)

Date: 2026-11-10. Batch: N2118 (single slice, SSOT slice, no emitter change). Commit: TBD (set after the full suite passes).

## Done

- New `SourceFactoryBuildState.source_factory_warmup_target_state(block)` implements `GenericCrafterBuild.warmupTarget()` (GenericCrafter.java:287-289): returns 1f; the HeatCrafter override (`Mathf.clamp(heat / heatRequirement)`, HeatCrafter.java:70-72) is deferred — the frame carries no heat state yet. A null block has no target.
- New `SourceFactoryBuildState.source_factory_warmup_state(warmup, target, warmup_speed, seconds)` implements the `Mathf.approachDelta` step (GenericCrafter.java:239, 253): step = `Time.delta * warmupSpeed`, moved = warmup + clamp(target − warmup, −step, step); `Time.delta` is in seconds. warmupSpeed is the block's own, else the class default 0.019f (GenericCrafter.java:45); the only initializer override in Blocks.java is the blast drill (a Drill, not a factory).
- New `SourceFactoryBuildState.source_factory_liquid_output_state(block, liquids, liquid_ids, efficiency, seconds, time_scale)` implements the continuous liquid output half of `updateTile()` (GenericCrafter.java:241-246): `inc = getProgressIncrease(1f)` (the GenericCrafter override at base time 1f, so a full output liquid scales inc to zero), then each output liquid is handled once per tick with `min(output.amount * inc, liquidCapacity - held)`. `handleLiquid` is `liquids.add` (BuildingComp.java:872-874); `LiquidModule.add` (LiquidModule.java:110-115) is `liquids[liquid.id] += amount` with `current` set to the liquid. A block with no output liquids outputs nothing; a null block outputs nothing.
- New `SourceFactoryBuildState.source_factory_total_progress_state(total_progress, warmup, seconds)` implements `totalProgress += warmup * Time.delta` (GenericCrafter.java:259-260; `Time.delta` is in seconds, not ticks). It runs every tick, outside the efficiency branch.
- The tick driver `source_factory_tick_buildings_state(game, seconds)` (extended in place, still N2110) now approaches warmup, handles the output liquids and banks totalProgress every tick — totalProgress before the craft check, the Java order — and crafts when progress reaches 1.0. A driver-order fix moved the craft check after the totalProgress step to match GenericCrafter.java:259-264.
- New owner constants `PORT_GAME_SOURCE_FACTORY_BUILD_WARMUP_TARGET_STATE`, `PORT_GAME_SOURCE_FACTORY_BUILD_WARMUP_STATE`, `PORT_GAME_SOURCE_FACTORY_BUILD_LIQUID_OUTPUT_STATE`, `PORT_GAME_SOURCE_FACTORY_BUILD_TOTAL_PROGRESS_STATE` in `SourceRuntimeOwnerGameplayRegistry.gd`.
- No emitter change: the registry already carries `outputLiquids`, `liquidCapacity` and `craftTime` (N2113/N2117). The `content_registry_blocks` shard mirror was rebuilt anyway; all five `production_*` / registry shards on disk equal a fresh build.
- New test `tools/mindustry_godot_transpiler/tests/test_factory_liquid_output.py` (4 tests) and register script `tools/mindustry_godot_transpiler/register_factory_liquid_output.py` (4 functions, 21 symbols, 4 contracts, 8 schemas).
- SSOT +21/+1/+4/+8 → 11077 / 1569 / 1480 / 2751; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `production_*` shards.

## Verification

- New test module: 4 tests (registration, exact-evidence, tick outputs liquid when efficient, reference graph and actual C06 gate).
- Godot proof `C06FactoryLiquidOutputProof` **46/46 true** on the real Main scene: registry mixer craftTime 120 / liquidCapacity 36 / cryofluid 0.2 and electrolyzer ozone 4/60 + hydrogen 6/60; warmupTarget 1.0 (null 0.0); the approach step at 0.019/s with clamping both ways and zero-seconds unchanged; the liquid output on the mixer (empty → inc 1.0, +0.2 cryofluid; nearly full 35.9/36 → inc 0.5, +0.1; full → inc 0.0, +0.0), the smelter (no outputs → inc 0.0), the null block, and the electrolyzer (inc 1.0, ozone + hydrogen); totalProgress in seconds; live, a mixer (35,7) with titanium 5 and water 10.0 gains 0.2 cryofluid per tick (water 10.0 → 2.0, cryofluid 0 → 8.0 in 40 ticks, warmup → 40*0.019/60, totalProgress → 0.019*820/3600, efficiency 1.0, titanium kept) and an electrolyzer (40,7) gains 4/60 ozone + 6/60 hydrogen per tick (ozone 0 → 2.667, hydrogen 0 → 4.0, water 10.0 → 3.333).
- Targeted gate **5566 tests OK in 1700.069s** (log `~/workspace/logs/targeted-n2118.log`). Full Python suite **5566 tests OK in 1686.101s** (log `~/workspace/logs/full-suite-n2118.log`).

## Still open

- Deferred in this slice: `dumpOutputs()` (GenericCrafter.java:317+, item dump timer + liquid dumpLiquid per output liquid), the HeatCrafter `warmupTarget()` override (HeatCrafter.java:70-72), the `updateEffect` chance branch (GenericCrafter.java:247-249, visual only). C06 continues: UnitFactory-family RuntimeConsumer binding (deferred since N2109), then the factory→core→defense chain. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceFactoryBuildState.gd`
- `godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_slices.json`
- `godot-mindustry/src/generated/source_modules/production_symbols.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/C06FactoryLiquidOutputProof.gd`
- `godot-mindustry/tools/runtime_proofs/C06FactoryLiquidOutputProof.tscn`
- `tools/mindustry_godot_transpiler/register_factory_liquid_output.py`
- `tools/mindustry_godot_transpiler/tests/test_factory_liquid_output.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-10-generic-crafter-liquid-output.md`
- `docs/superpowers/handoffs/2026-11-10-generic-crafter-liquid-output-handoff.md`
