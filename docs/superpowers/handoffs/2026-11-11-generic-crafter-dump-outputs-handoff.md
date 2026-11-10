# Handoff — GenericCrafter dumpOutputs() in the live loop (N2119)

Date: 2026-11-11. Batch: N2119 (single slice, SSOT slice, emitter change for `liquidOutputDirections`). Commit: 47a470e.

## Done

- New `SourceFactoryBuildState.source_factory_dump_interval_state(dump_time, time_scale)` implements the dump interval `dumpTime / timeScale` (GenericCrafter.java:319): dumpTime is Block.dumpTime, 5 (Block.java:438; no factory initializer overrides it); timeScale is the building time scale, 1f by default (BuildingComp.java:98). A zero time scale makes the interval infinite.
- New `SourceFactoryBuildState.source_factory_dump_timer_state(dump_timer, seconds, dump_time, time_scale)` implements `TimerComp.timer(timerDump, dumpTime / timeScale)` (GenericCrafter.java:319; TimerComp.java:10-13): returns false for an infinite interval, otherwise fires when the accumulated timer reaches the interval and resets it to 0.0. Time advances in seconds, so the port accumulates the Godot delta in seconds.
- New `SourceFactoryBuildState.source_factory_dump_liquid_state(game, cell, block, liquids, liquid_ids, liquid_name, output_dir)` implements `BuildingComp.dumpLiquid(liquid, 2f, dir)` (BuildingComp.java:886-908): returns when the building holds <= 0.0001; a null game or block, or an unknown liquid, dumps nothing. The transfer flow is `(held/cap - dest/destCap) * cap / 2`, capped by the destination's free space, and the frame's `cdump` cursor is updated to the neighbor actually dumped to.
- New `SourceFactoryBuildState.source_factory_dump_outputs_state(game, frame, cell, block, liquids, liquid_ids, seconds, time_scale)` implements `GenericCrafterBuild.dumpOutputs()` (GenericCrafter.java:317-332): the item rows dump only when `outputItems != null && timer(timerDump, dumpTime / timeScale)` fires (one item per fired timer, via `BuildingComp.dump(Item)` to the first accepting belt neighbor); every output liquid dumps every tick via `dumpLiquid(outputLiquids[i].liquid, 2f, dir)` with `dir = liquidOutputDirections.length > i ? liquidOutputDirections[i] : -1` (GenericCrafter.java:327-328). A null block dumps nothing; a liquid-only block never starts its dump timer.
- The tick driver `source_factory_tick_buildings_state(game, seconds)` (extended in place, still N2110) now calls `dumpOutputs()` every tick after the craft check — the Java order (GenericCrafter.java:259-264 calls `craft()` then `dumpOutputs()` via `updateTile()`).
- New owner constants `PORT_GAME_SOURCE_FACTORY_BUILD_DUMP_INTERVAL_STATE`, `PORT_GAME_SOURCE_FACTORY_BUILD_DUMP_TIMER_STATE`, `PORT_GAME_SOURCE_FACTORY_BUILD_DUMP_LIQUID_STATE`, `PORT_GAME_SOURCE_FACTORY_BUILD_DUMP_OUTPUTS_STATE` in `SourceRuntimeOwnerGameplayRegistry.gd`.
- Emitter change: `content_registry.py` now captures `liquidOutputDirections` per GenericCrafter-family block — the block initializer's own array (the electrolyzer's `{1, 3}`, Blocks.java:1395), else the class default `{-1}` (GenericCrafter.java:34). Registry: cryofluid-mixer `[-1]`, electrolyzer `[1, 3]`, silicon-smelter `[-1]`. The `content_registry_blocks` shard mirror was rebuilt; all five `production_*` / registry shards on disk equal a fresh build.
- New test `tools/mindustry_godot_transpiler/tests/test_factory_dump_outputs.py` (4 tests) and register script `tools/mindustry_godot_transpiler/register_factory_dump_outputs.py` (4 functions, 36 symbols, 4 contracts, 8 schemas).
- SSOT +36/+1/+4/+8 → 11113 / 1570 / 1484 / 2759; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `production_*` shards.

## Verification

- New test module: 4 tests (registration, exact-evidence, tick dumps outputs, reference graph and actual C06 gate).
- Godot proof `C06FactoryDumpOutputsProof` **42/42 true** on the real Main scene: registry mixer/electrolyzer/smelter `liquidOutputDirections` (`[-1]`, `[1, 3]`, `[-1]`) and mixer output cryofluid; dump interval 5.0 at unit scale, 2.5 at double, 10.0 at half, infinite at zero scale; the dump timer cold (no dump), firing near five and at exactly five (reset to 0.0), and no dump at infinite scale; dumpLiquid guards (null game, null block, unknown liquid, empty module — all nothing); dumpOutputs guards (null block nothing; smelter timer cold keeps silicon 5; fired timer with no belt keeps silicon 5 and resets the timer; a liquid-only mixer with 8.0 cryofluid and no neighbor dumps nothing and keeps 8.0); the liquid transfer (mixer 8.0 cryofluid → conduit (37,7): flow 4.0, mixer after 4.0, conduit 4.0, `cdump` cursor matches the frame); the electrolyzer dump (ozone 2.0 → 1.0 north to (40,5), hydrogen 3.0 → 1.5 south to (40,9), no item dump); the item dump (smelter silicon 5 with fired timer dumps one silicon to the east belt, frame silicon 4, belt queue one silicon); live, a mixer (45,7) with titanium 5 and water 10.0 and a conduit (47,7) over 40 ticks (water 10.0 → 2.0, progress 40/120, efficiency 1.0, cryofluid held strictly between 0 and the no-dump 8.0, conduit gained, titanium kept).
- The proof-placement fix (this batch's earlier gate failure): a conduit placed on a factory footprint cell replaces the factory in `placed_blocks`, so the proof now places conduits on true ring cells — mixer (35,7) size 2 → conduit (37,7); electrolyzer (40,7) size 3 → conduits (40,5)/(40,9); live mixer (45,7) → conduit (47,7).
- Targeted gate **5570 tests OK in 1713.079s** (log `~/workspace/logs/targeted-n2119.log`). Full Python suite **5570 tests OK in 1715.314s** (log `~/workspace/logs/full-suite-n2119.log`).

## Still open

- Deferred in this slice: the HeatCrafter `warmupTarget()` override (HeatCrafter.java:70-72), the `updateEffect` chance branch (GenericCrafter.java:247-249, visual only), liquid dump destinations other than conduits (a neighboring factory does not acceptLiquid a foreign output liquid; other liquid blocks have no port accept rule yet). C06 continues: UnitFactory-family RuntimeConsumer binding (deferred since N2109), then the factory→core→defense chain. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

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
- `godot-mindustry/tools/runtime_proofs/C06FactoryDumpOutputsProof.gd`
- `godot-mindustry/tools/runtime_proofs/C06FactoryDumpOutputsProof.tscn`
- `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py`
- `tools/mindustry_godot_transpiler/register_factory_dump_outputs.py`
- `tools/mindustry_godot_transpiler/tests/test_content_registry.py`
- `tools/mindustry_godot_transpiler/tests/test_factory_dump_outputs.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-11-generic-crafter-dump-outputs.md`
- `docs/superpowers/handoffs/2026-11-11-generic-crafter-dump-outputs-handoff.md`
