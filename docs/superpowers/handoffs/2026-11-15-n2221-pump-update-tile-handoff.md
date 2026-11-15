# Handoff N2221 — Pump updateTile Advance

**Status: DONE** (coordinator lượt 4 — wave advances-1). Slice `439604f7` trên branch `slice/N2221-pump-update-tile` (base `2b6e6a33`, đã push 16:17, remote tip 439604f7). Integration `integration/wave-advances-1-n2219-n2223`: cherry-pick `e94b044a` + SSOT gộp `bde67d63` (11470/1664/1587/2965).

## What changed

- `SourceMechanicalPumpBuildState.gd`: frame keys warmup/total_progress/cons_timer; pure `source_mechanical_pump_update_tile_advance_state(frame, ...)` → 5 keys in Java order (max_pump, liquid_amount, cons_timer, warmup, total_progress); driver does `liquids.add` via `source_add_state`; driver wiring after consumption, enabled-gated.
- New: `test_c07_mechanical_pump_update_tile.py`, `register_c07_mechanical_pump_update_tile.py`, `C07MechanicalPumpUpdateTileProof.gd/.tscn` (6 keys).

## Java ground truth

PumpBuild.updateTile (Pump.java:161-182). consumeTime 60f*5f (:22), warmupSpeed 0.019f (:23). maxPump/consTimer use delta() via edelta; warmup/totalProgress use raw Time.delta. consume() is a documented no-op (both defs have no item consumer). pumpAmount def constants: rotary 0.2f, impulse 0.22f.

## Tests

- Targeted post-register: 3/4 PASS, chỉ proof test fail `AssertionError: unexpectedly None` (Godot-absent).
- SSOT: +5/+1/+1/+2 → 11440/1660/1583/2957 (slice riêng), audit 1336, legacy 0. Exact exprs 23. DEFERRED 258. Shard đổi: 4 production shards.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07MechanicalPumpUpdateTileProof` — 6 keys: max_pump_capped_by_remaining_capacity, warmup_approaches_one_when_pumping, total_progress_advances_with_warmup, cons_timer_advances_and_wraps, no_pump_without_liquid_drop, live_tick_pumps_and_advances_warmup.

## Deferred (không trong slice này)

- dumpLiquid on the placed-pump path (scenario helper is bound to the scenario frame). Scenario pump path untouched. Note: the older "Pump warmup / totalProgress rows" DEFERRED entry is now stale — coordinator removes it from the merged list at integration.
