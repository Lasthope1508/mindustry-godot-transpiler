# Handoff N2219 — BurstDrill updateTile Advance

**Status: DONE** (coordinator lượt 4 — wave advances-1). Slice `c48e365b` trên branch `slice/N2219-burst-drill-update-tile` (base `2b6e6a33`, đã push 16:19, remote tip c48e365b). Integration `integration/wave-advances-1-n2219-n2223`: cherry-pick `97a5be46` + SSOT gộp `bde67d63` (11470/1664/1587/2965).

## What changed

- `SourceBurstDrillBuildState.gd`: frame keys progress/warmup/time_drilled/last_drill_speed/smooth_progress/invert_time; pure `source_burst_drill_update_tile_state(frame, ...)` → 10 result symbols; per-def tables (drillTime {eruption 281.25, impact 720.0}, liquidBoostIntensity {2.0, 1.75}); driver wiring after consumption, enabled-gated.
- New: `test_c07_burst_drill_update_tile.py`, `register_c07_burst_drill_update_tile.py`, `C07BurstDrillUpdateTileProof.gd/.tscn` (6 keys).

## Java ground truth

BurstDrillBuild.updateTile (BurstDrill.java:~73-122). getDrillTime override :53-55 (NO hardness term). speedCurve = Interp.pow2In (:19). invertedTime 200f (:26). Offload fallback `handleItem(self())` via `add_item_state`.

## Tests

- Targeted post-register: 3/4 PASS, chỉ proof test fail `AssertionError: unexpectedly None` (Godot-absent).
- SSOT: +10/+1/+1/+2 → 11445/1660/1583/2957 (slice riêng), audit 1336, legacy 0. Exact exprs 52. DEFERRED 258. Shard đổi: 4 production shards.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07BurstDrillUpdateTileProof` — 6 keys: progress_advances_when_efficient, warmup_approaches_progress_ratio, offload_at_drill_time, invert_time_set_on_offload, last_drill_speed_zero_when_blocked, live_tick_advances_progress.

## Deferred (không trong slice này)

- timerDump dump (no timer infra), shake/sound/drillEffect, offload neighbor routing.
