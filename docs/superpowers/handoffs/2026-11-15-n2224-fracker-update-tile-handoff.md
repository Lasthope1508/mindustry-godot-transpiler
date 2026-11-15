# Handoff N2224 — Fracker updateTile Advance

**Status: DONE** (coordinator lượt 4 — wave advances-2). Slice `46f65f31` trên branch `slice/N2224-fracker-update-tile` (base `542b383e`, đã push 16:56, remote tip 46f65f31). Integration `integration/wave-advances-2-n2224-n2228`: cherry-pick `94be3ec4` + SSOT gộp `e76dd9c8` (11507/1669/1592/2975).

## What changed

- `SourceFrackerBuildState.gd`: frame keys accumulator/warmup/pump_time/last_pump/max_pump/fraction (+ `items`, mới); pure `source_fracker_update_tile_advance_state(frame, ...)` → 7 result symbols; tái dùng pure N2220 qua preload với pump_amount 0.25f; consume() LÀM qua inventory.remove_item_state (trừ 1 sand).
- New: `test_c07_fracker_update_tile.py`, `register_c07_fracker_update_tile.py`, `C07FrackerUpdateTileProof.gd/.tscn` (6 keys).

## Java ground truth

FrackerBuild.updateTile (Fracker.java:30-44): efficiency > 0 → accumulator consume check → super.updateTile() → accumulator += delta() * efficiency; else warmup decay + lastPump = 0 + dumpLiquid, NO super call. itemUseTime def oil-extractor = **60f** (Blocks.java:2974), không phải class default 100f (:7). pumpAmount 0.25f (Blocks:2969); result oil (Blocks:2966), capacity 40f (:2971).

## Tests

- Targeted post-register: 3/4 PASS, chỉ proof test fail `AssertionError: unexpectedly None` (Godot-absent).
- SSOT: +7/+1/+1/+2 → 11477/1665/1588/2967 (slice riêng), audit 1336, legacy 0. Exact exprs 60. DEFERRED 259. Shard đổi: 4 production shards. Siblings 9/9 non-proof PASS.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07FrackerUpdateTileProof` — 6 keys: accumulator_advances_with_efficiency, consume_at_item_use_time, super_advance_pumps_oil, warmup_decays_when_no_efficiency, last_pump_zero_when_idle, frame_defaults_zero.

## Deferred (không trong slice này)

- dumpLiquid else-branch; sand item intake (không có live fill cho frame["items"]).
