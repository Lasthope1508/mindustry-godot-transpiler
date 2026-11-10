# Handoff — C05 gate: reinitialize_consumers for Factory + AdjacentFactory families (N2116)

Date: 2026-11-10. Batch: N2116 (single slice, SSOT slice). Commit: 7adf7e4.

## Done

- New `SourceFactoryBuildState.source_factory_reinitialize_consumers_state(frame, block, catalog, amounts)` and `SourceAdjacentFactoryBuildState.source_adjacent_factory_reinitialize_consumers_state(frame, block, catalog, amounts)` implement `Block.reinitializeConsumers()` (Block.java:1481-1497) over `Tile.changeBuild` (Tile.java:636-657): a replaced building gets fresh consumers — the consumeBuilder is re-read, the optional / non-optional / update arrays are rebuilt, and each consumer is applied again. New owner constants `PORT_GAME_SOURCE_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE` and `PORT_GAME_SOURCE_ADJACENT_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE`.
- The tick drivers (`source_factory_tick_buildings_state`, `source_adjacent_factory_tick_buildings_state`) now reinitialize through these instead of binding directly. A frame already stamped for this block takes the normal once-only bind path (`reinitialized=false`); a frame stamped for another block drops its old RuntimeConsumer actors (N2100's invalidate, the cache-invalidation half of reinitializeConsumers), clears its item and liquid stores for the fresh Building's own empty ItemModule/LiquidModule (BuildingComp.java:145-146, init creates a fresh ItemModule/LiquidModule per Building), and rebinds from the new block's consumeBuilder, stamping the new block id. A null block reinitializes nothing. This closes the port's sprite-reuse hole: `initialize_sprite` overwrites the block-id meta but keeps the family frame, so without this the tick kept running the old block's actors against the new block's rows — and indexed past the end of the actor list when the new block had more rows.
- New test `tools/mindustry_godot_transpiler/tests/test_c05_gate.py` (4 tests) and register script `tools/mindustry_godot_transpiler/register_c05_gate.py` (1 function, 16 symbols, 2 contracts, 4 schemas). The two older consumer-binding test modules pin the new driver call (`source_factory_reinitialize_consumers_state` / `source_adjacent_factory_reinitialize_consumers_state` in the tick) instead of the direct bind.
- SSOT +16/+1/+2/+4 → 11018 / 1567 / 1471 / 2733; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `production_*` shards.

## Verification

- New test module: 4 tests OK.
- Godot proof `C05GateProof` **48/48 true** on the real Main scene: lifecycle replacement (a replaced frame drops the old block's actors and rebinds the new block's rows), storage independence (the fresh Building's item/liquid stores start empty), and consumer classification (optional / non-optional / update arrays rebuilt from the new block's consumeBuilder).
- Targeted gate 5558 tests OK in 1643.735s (log `~/workspace/logs/targeted-n2116.log`). Full Python suite 5558 tests OK in 1656.246s (log `~/workspace/logs/full-suite-n2116.log`).

## Still open

- C05 is closed by this gate. Next: C06 factory→core→defense loop. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceAdjacentFactoryBuildState.gd`
- `godot-mindustry/src/game/SourceFactoryBuildState.gd`
- `godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/production_api_contracts.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/C05GateProof.gd`
- `godot-mindustry/tools/runtime_proofs/C05GateProof.tscn`
- `tools/mindustry_godot_transpiler/register_c05_gate.py`
- `tools/mindustry_godot_transpiler/tests/test_c05_gate.py`
- `tools/mindustry_godot_transpiler/tests/test_adjacent_factory_consumer_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_factory_consumer_binding.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-10-c05-gate.md`
- `docs/superpowers/handoffs/2026-11-10-c05-gate-handoff.md`
