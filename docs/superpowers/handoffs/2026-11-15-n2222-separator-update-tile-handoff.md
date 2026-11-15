# Handoff N2222 — Separator updateTile Advance

**Status: DONE** (coordinator lượt 4 — wave advances-1). Slice `34861097` trên branch `slice/N2222-separator-update-tile` (base `2b6e6a33`, đã push 16:22, remote tip 34861097). Integration `integration/wave-advances-1-n2219-n2223`: cherry-pick `f26f7498` + SSOT gộp `bde67d63` (11470/1664/1587/2965).

## What changed

- `SourceSeparatorBuildState.gd`: frame keys progress/warmup/total_progress/seed (+ cdump); pure `source_separator_update_tile_state(frame, ...)`; faithful Arc Rand port (xorshift128+) as a private helper for the weighted result pick; consume() via `inventory.remove_item_state`; `created()` seed init live (Point2.pack from origin cell); driver wiring after consumption, enabled-gated.
- New: `test_c07_separator_update_tile.py`, `register_c07_separator_update_tile.py`, `C07SeparatorUpdateTileProof.gd/.tscn` (6 keys).

## Java ground truth

SeparatorBuild.updateTile (Separator.java:**130–167** — scope said 128–166). getProgressIncrease is the BASE at BuildingComp.java:1203-1205 — Separator extends Block, NOT GenericCrafter. created() seed :82–84. craftTime Blocks.java:1240/:1258 (separator 35f, disassembler 15f). Arc Mathf.randomSeed (Mathf.java:297-302): 2-state xorshift128+ Rand, raw seed, discard 1 nextInt() on power-of-two max.

## Tests

- Targeted post-register: 3/4 PASS, chỉ proof test fail `AssertionError: unexpectedly None` (Godot-absent).
- SSOT: +8/+1/+1/+2 → 11443/1660/1583/2957 (slice riêng), audit 1336, legacy 0. Exact exprs 66. DEFERRED 259 (258 − 2 + 3). Shard đổi: 4 production shards.
- Rand port verified vs Python reference (2 independent implementations): 1030/1030 seed/bound cases match.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07SeparatorUpdateTileProof` — 6 keys: progress_advances_when_efficient, warmup_approaches_one_when_efficient, total_progress_advances_with_warmup, craft_completes_at_progress_one, offload_picks_weighted_result, live_tick_advances_progress_and_warmup.

## Deferred (không trong slice này)

- timerDump dump (no timer helper), offload neighbor routing (empty routing context → own-inventory fallback), shouldAmbientSound row.

## Finding for a later slice

- `SourceMathState.random_seed_int` is NOT faithful to Arc (single-state murmur seeded with seed*99999 + power-of-two masking, vs Arc's 2-state xorshift128+ with raw seed + discard). Needs an audit/fix slice if that helper is used elsewhere.
