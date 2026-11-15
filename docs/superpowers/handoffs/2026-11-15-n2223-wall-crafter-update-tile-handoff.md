# Handoff N2223 — WallCrafter updateTile Advance

**Status: DONE** (coordinator lượt 4 — wave advances-1). Slice `1827aaf6` trên branch `slice/N2223-wall-crafter-update-tile` (base `2b6e6a33`, đã push 16:21, remote tip 1827aaf6). Integration `integration/wave-advances-1-n2219-n2223`: cherry-pick `c1ed1449` + SSOT gộp `bde67d63` (11470/1664/1587/2965).

## What changed

- `SourceWallCrafterBuildState.gd`: frame keys time/warmup/total_time/last_efficiency (+ eff, offloaded, items); frame inputs efficiency_factor/item_valid/has_liquid_booster; pure `source_wall_crafter_update_tile_advance_state(frame, ...)`; offload via `inventory.offload_item_state`; driver wiring after consumption, enabled-gated.
- New: `test_c07_wall_crafter_update_tile.py`, `register_c07_wall_crafter_update_tile.py`, `C07WallCrafterUpdateTileProof.gd/.tscn` (6 keys).

## Java ground truth

WallCrafterBuild.updateTile (WallCrafter.java:187-223). getEfficiency :141-180 (adjacent solid-tile scan — no port helper yet). liquidBoostIntensity 1.6f (:35), itemBoostIntensity 1.6f (:47). output = sand. drillTime: cliff-crusher **110f**, large 48f. **hasLiquidBooster = false for BOTH defs** (large def's hydrogen consumer has no `.boost()`, Blocks.java:3028).

## Tests

- Targeted post-register: 3/4 PASS, chỉ proof test fail `AssertionError: unexpectedly None` (Godot-absent).
- SSOT: +7/+1/+1/+2 → 11442/1660/1583/2957 (slice riêng), audit 1336, legacy 0. Exact exprs 50. DEFERRED 258. Shard đổi: 4 production shards.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07WallCrafterUpdateTileProof` — 6 keys: warmup_approaches_one_when_efficient, time_advances_with_eff_and_edelta, offload_at_drill_time, last_efficiency_folds_eff_timescale, total_time_advances_with_warmup, live_tick_advances_warmup_and_time.

## Deferred (không trong slice này)

- getEfficiency live fill, timerUse consume, timerDump dump, offload neighbor routing, updateEffect chance, disabled early return.

## Finding for a later slice

- N2170/N2201 driver comments call hydrogen "a booster" — wrong: hasLiquidBooster is false for both defs. Needs a fix slice/comment cleanup (coordinator serial).
