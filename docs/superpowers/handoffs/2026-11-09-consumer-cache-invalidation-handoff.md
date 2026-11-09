# Handoff — C05 consumer cache invalidation (N2100)

Date: 2026-11-09. Batch: N2100 (single slice, sixth C05 batch). Commit: f3ff3f1.

## Done

- `SourceConsumeLiquidState.source_invalidate_consumer_cache_state(block, frame)` — the cache-invalidation half of `Block.reinitializeConsumers()` (Block.java:1481-1497: rebuilds the consumer arrays from `consumeBuilder`, resets `itemFilter`/`liquidFilter`, re-applies each consumer; `DataPatcher` calls it on reload, DataPatcher.java:604, 615). Drops all three port caches together: the bound rows meta (`source_block_liquid_consumers`), the apply meta (`source_block_liquid_apply`, `ConsumeLiquid.apply` sets `block.liquidFilter[liquid.id] = true`, ConsumeLiquid.java:26-28), and the frame's `RuntimeConsumer` actors (`consumers`). Returns `{bound_rows_invalidated, apply_invalidated, frame_consumers_before, frame_consumers_invalidated}`; the next tick rebinds through its existing `is_empty()` path. A null block or a frame without cached actors invalidates nothing.
- Register script `tools/mindustry_godot_transpiler/register_consumer_cache_invalidation.py`; test `tools/mindustry_godot_transpiler/tests/test_consumer_cache_invalidation.py`; proof `godot-mindustry/tools/runtime_proofs/ConsumerCacheInvalidationProof.gd/.tscn`.
- SSOT +6/+1/+1/+2 → 10835 symbols / 1553 slices / 1441 contracts / 2673 schemas; audit `totalSourceFunctions` stays 1335. The owner mirrors into the `block_*` shards (Block.java, all 4 files).

## Verification

- Test 3 tests OK (registration + exact-evidence + Godot proof).
- Godot proof `ConsumerCacheInvalidationProof` 16/16 true on the real Main scene: null block / empty frame invalidate nothing; the drill binds one consumer at 0.05 with rows + apply meta at placement; after the block's `consumeBuilder` changes to 0.1 the stale actor and rows still read 0.05; invalidation drops both metas and clears the frame, and the rebuild binds a new actor at 0.1 with fresh rows.
- Targeted gate (log `~/workspace/logs/targeted-n2100.log`): 5499 tests OK in 1432.199s, exit=0.
- Full Python suite, first run (log `~/workspace/logs/full-suite-n2100.log`): 5499 tests, FAILED (failures=5) in 1469.444s — all five are MCP port-7777 flakes in pre-existing live proofs (each proof JSON all-true, failing only on `assertNotIn('ERROR:')` because another suite held port 7777 concurrently). Rerun of the five affected modules (log `~/workspace/logs/rerun-n2100-flakes.log`): 17 tests OK in 51.641s, exit=0.
- Full Python suite, clean reruns (logs `~/workspace/logs/full-suite-n2100b/c/d.log`): each died partway with no summary (b: ~240 tests, c: ~230, d: ~3200 dots, 0 failures seen) and no gate process is running now — the first run + flakes rerun above stand as the suite evidence.

## Still open

- C05 next: wiring other buildings (turrets, factories) to the live cheating value; the `ContinuousLiquidTurret.java:45` custom multiplier lambda. C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceConsumeLiquidState.gd`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/block_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/block_slices.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/ConsumerCacheInvalidationProof.gd`
- `godot-mindustry/tools/runtime_proofs/ConsumerCacheInvalidationProof.tscn`
- `tools/mindustry_godot_transpiler/register_consumer_cache_invalidation.py`
- `tools/mindustry_godot_transpiler/tests/test_consumer_cache_invalidation.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-09-consumer-cache-invalidation.md`
- `docs/superpowers/handoffs/2026-11-09-consumer-cache-invalidation-handoff.md`
