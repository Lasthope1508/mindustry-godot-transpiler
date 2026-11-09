# C05 consumer cache invalidation — N2100

Date: 2026-11-09. Batch: N2100 (single slice, sixth C05 batch). SSOT +6/+1/+1/+2 → 10835 / 1553 / 1441 / 2673; audit `totalSourceFunctions` stays 1335.

## What changed

Java rebuilds a block's consumers from scratch on reinit and keeps no cached actors: `Block.reinitializeConsumers()` (Block.java:1481-1497) rebuilds the consumer arrays from `consumeBuilder`, resets `itemFilter`/`liquidFilter` and re-applies each consumer; `DataPatcher` calls it when a block's "consumes" JSON is re-read on reload (DataPatcher.java:604, 615); `BuildingComp.updateConsumption` then reads `block.nonOptionalConsumers`, `block.optionalConsumers` and `block.updateConsumers` fresh every tick (BuildingComp.java:1969, 1980, 2000). The port, by contrast, caches in three places: the bound rows on the block meta (`source_block_liquid_consumers`), the apply result derived from those rows (`source_block_liquid_apply` — `ConsumeLiquid.apply` sets `block.liquidFilter[liquid.id] = true`, ConsumeLiquid.java:26-28, after reinit rebuilds the filter at Block.java:1491), and the `RuntimeConsumer` actors in the building frame (`consumers`, built once by the drill tick). All three go stale when the block is reinitialized — the old actor keeps the old amount and the tick keeps using it.

- N2100 `SourceConsumeLiquidState.source_invalidate_consumer_cache_state(block, frame)` — drops all three caches together (both block metas and the frame's `consumers` array) and reports what was dropped: `{bound_rows_invalidated, apply_invalidated, frame_consumers_before, frame_consumers_invalidated}`. The next tick rebinds from the block's current `consumeBuilder` and rebuilds the actors through the tick's existing `is_empty()` path. A null block or a frame without cached actors invalidates nothing.

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_consumer_cache_invalidation.py` (registration + exact-evidence + Godot proof): 3 tests OK.
- Godot proof `ConsumerCacheInvalidationProof` **16/16 true** on the real Main scene: a null block and an empty frame invalidate nothing; the drill's frame holds one consumer bound at amount 0.05 and the block carries the bound rows + apply meta; after the block's `consumeBuilder` is changed to 0.1, the stale actor still reads 0.05 and the stale rows still read 0.05 — then invalidation drops both metas and clears the frame, and the rebuild binds a new actor at 0.1 with fresh rows.
- Targeted gate (log `~/workspace/logs/targeted-n2100.log`): **5499 tests OK in 1432.199s, exit=0**.
- Full Python suite, first run (log `~/workspace/logs/full-suite-n2100.log`): 5499 tests, FAILED (failures=5) in 1469.444s — all five are the MCP port-7777 `ERROR:` string in pre-existing live proofs (`test_drill_live_consumption`, `test_liquid_consumer_apply_hydration`, `test_liquid_consumer_hydration`, `test_liquid_module_storage`, `test_placed_liquid_ownership`); each proof's own JSON is all-true (`matches: true`), so they are environment flakes from two suites running concurrently, not an N2100 regression. Rerun of the five affected modules (log `~/workspace/logs/rerun-n2100-flakes.log`): **17 tests OK in 51.641s, exit=0**.
- Full Python suite, clean reruns (logs `~/workspace/logs/full-suite-n2100b/c/d.log`): each died partway with no summary (b: ~240 tests, c: ~230, d: ~3200 dots, 0 failures seen) and no gate process is running now — the first run + flakes rerun above stand as the suite evidence.

## SSOT delta

+6 symbols / +1 slice / +1 contract / +2 schemas → 10835 / 1553 / 1441 / 2673; audit `totalSourceFunctions` stays 1335. The owner mirrors into the `block_*` shards (Block.java, all 4 files).

## Still open

- C05: wiring other buildings (turrets, factories) to the live cheating value; the `ContinuousLiquidTurret.java:45` custom multiplier lambda. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
