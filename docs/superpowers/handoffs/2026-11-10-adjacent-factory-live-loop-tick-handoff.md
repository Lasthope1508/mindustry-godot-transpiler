# Handoff — C05 Adjacent factory families live-loop tick (N2114)

Date: 2026-11-10. Batch: N2114 (single slice, SSOT slice). Commit: (main turn fills in).

## Done

- New `SourceAdjacentFactoryBuildState.gd` wires the Separator/Incinerator/WallCrafter/SingleBlockProducer families into the live loop: `source_adjacent_factory_tick_frame_state(frame, block_implementation, team_id, rules_state)` sets the frame keys with the live cheating flag (`TeamComp.cheating()`), `source_adjacent_factory_bind_frame_state(sprite, block)` binds the frame at placement (Block.java:1002), `source_adjacent_factory_tick_buildings_state(game, seconds)` is called from `simulate_factory` every tick and runs the consumption half of each family's updateTile with its own shouldConsume body gating the shared machinery.
- `source_adjacent_factory_update_consumption_state(frame, has_consumers, enabled, production_valid, should_consume, efficiency_scale)` runs the shared updateConsumption machinery with the frame's live cheating flag (BuildingComp.java:1943-1951 early return); new owner constant `PORT_GAME_SOURCE_ADJACENT_FACTORY_BUILD_UPDATE_CONSUMPTION_STATE`.
- `source_adjacent_factory_should_consume_state(frame, block)` implements each family's own shouldConsume(): Separator held-minus-inputs vs itemCapacity, WallCrafter held output vs itemCapacity (no enabled check), Incinerator Building default (enabled), BlockProducer default plus a recipe (SingleBlockProducer returns the block's result, default Blocks.router); new owner constant `PORT_GAME_SOURCE_ADJACENT_FACTORY_BUILD_SHOULD_CONSUME_STATE`.
- Registry captures the WallCrafter `output` in `content_registry.py` (cliff-crusher and large-cliff-crusher now carry `output: "sand"`); new test `test_block_registry_captures_wall_crafter_output`.
- New test `tools/mindustry_godot_transpiler/tests/test_adjacent_factory_live_loop.py` (4 tests) and register script `tools/mindustry_godot_transpiler/register_adjacent_factory_live_loop.py` (5 functions, 30 symbols, 5 contracts, 10 schemas).
- SSOT +30/+1/+5/+10 → 10995 / 1565 / 1468 / 2727; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `production_*` shards.

## Verification

- New test module: 4 tests OK.
- Godot proof `AdjacentFactoryLiveLoopProof` 50/50 true on the real Main scene: separator (30,7), incinerator (35,7), cliff-crusher (40,7) placed live, frames bound on placement, driver ticks 3, cheat flip/uncheat restores, adapter cheating-skips / plain-runs-machinery, every shouldConsume branch (separator room/full, disassembler consumeItem subtraction, crusher sand 9/10 + disabled-no-enabled-check, incinerator enabled/disabled, SingleBlockProducer recipe/no-recipe via a stand-in block object, null block); live, a buffer-full separator ticks at efficiency 0 and room restores 1.0.
- First proof run was 48/50: the crusher was placed at (50,7), outside the 48×32 world, so placement fell back to the legacy init (no frame bind, derelict team). Moved to (40,7); rerun 50/50.
- Targeted gate **5550 tests OK** (log `~/workspace/logs/targeted-n2114d.log`, 1620.540s).
- Full Python suite **5550 tests OK in 1622.198s** (log `~/workspace/logs/full-suite-n2114.log`).

## Still open

- C05 next: binding the adjacent families' RuntimeConsumer actors (one per consumeItem/consumeLiquid row, the drill model, N2097/N2100/N2112) so the non-cheating consumption path actually consumes, and the C05 gate (lifecycle replacement, storage independence, consumer classification). C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceAdjacentFactoryBuildState.gd`
- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd`
- `godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd`
- `godot-mindustry/src/game/SourceWorldTerrainRuntimeState.gd`
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
- `godot-mindustry/tools/runtime_proofs/AdjacentFactoryLiveLoopProof.gd`
- `godot-mindustry/tools/runtime_proofs/AdjacentFactoryLiveLoopProof.tscn`
- `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py`
- `tools/mindustry_godot_transpiler/register_adjacent_factory_live_loop.py`
- `tools/mindustry_godot_transpiler/tests/test_adjacent_factory_live_loop.py`
- `tools/mindustry_godot_transpiler/tests/test_content_registry.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-10-adjacent-factory-live-loop-tick.md`
- `docs/superpowers/handoffs/2026-11-10-adjacent-factory-live-loop-tick-handoff.md`
