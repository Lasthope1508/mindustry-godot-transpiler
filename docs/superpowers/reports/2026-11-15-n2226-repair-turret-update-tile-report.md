# N2226 RepairTurret updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-2, integration branch `integration/wave-advances-2-n2224-n2228`, base `542b383e`).

## Source

- RepairTurretBuild.updateTile (RepairTurret.java:187-218): coolant multiplier; target clear when dead / out-of-range / full-health; offset zero; heal branch angleDist < 30 → heal repairSpeed*strength*edelta()*multiplier; rotation slerpDelta 0.5f*efficiency*timeScale; strength lerpDelta 0.08f*Time.delta; timerTarget 20 re-acquire via Units.closest (cadence deferred — no timer helper).
- Units.closest ported faithfully: nearby = strict `dst2 < (radius + hitSize/2)²` (Position.java:44-46), filter isValid + damaged (`health < maxHealth - 0.001f`, HealthComp.java:47-49), min dst2 with strict < (first wins ties).
- Per-def stats (Blocks.java:6386-6406): repairSpeed 0.45f/3f, repairRadius 60f/145f, length 5f/6f, beamWidth 0.73f/1.1f, pulseRadius 5f/6.1f.
- Building position from the origin cell via `tile_drawx/drawy_state` + offset `((size+1)%2)*tilesize/2` (Block.java:761).

## Implementation

- `SourceRepairTurretBuildState.gd`:
  - Pure `source_repair_turret_update_tile_advance_state(frame, source_delta, time_scale, repair_speed, repair_radius, building_x, building_y, candidates)` → 6 result symbols: target, offset, strength, rotation, heal_amount, healed.
  - Driver calls after the consumption fold, enabled-gated (N2195 precedent).
  - Multiplier = 1.0 (power-only first pass; the acceptCoolant branch waits for the coolant row). Heal application defers — the advance returns heal_amount as a pure result.
  - **Re-acquire pure: DONE** (not deferred wholesale). The candidates list is an explicit param; an empty list = the timer does not fire (target kept), a non-empty list = the tick has a query and OVERWRITES the target unconditionally like Java (:216, even back to null). Only the 20-tick timer cadence defers (no timer helper) — the driver always passes `[]`, so live never re-acquires yet.
  - Strength trap: Java passes `0.08f * Time.delta` as progress and lerpDelta multiplies Time.delta again — the port passes `0.08 * source_delta` as progress to the shared helper, so the double-delta is exact. Slerp uses a local helper `_repair_turret_slerp_delta` (N2191 precedent, no separate symbol).
  - Per-def repairSpeed/repairRadius are driver constants via `_repair_speed_for_block`/`_repair_radius_for_block` (the catalog has NEITHER field for this family — Separator craftTime precedent; fallback repair-point).
  - Target dict contract: dead, distance (= dst − hitSize/2), health/max_health (the full-health branch only fires when BOTH keys are present — a dict without health data is not treated as full), x/y, hit_size/damaged/valid.
  - `_initial_frame` kept as `{"target": null}` (N2223 precedent — advance keys are filled by the tick, defaults via `frame.get`).

## Commits

- Slice `04494ee9` (worker-N2226, branch `slice/N2226-repair-turret-update-tile`, 5 files +1214/−4; đã push 17:00, remote tip 04494ee9).
- Integration cherry-pick `865eab15`; SSOT gộp `e76dd9c8` (wave advances-2): 11507/1669/1592/2975 (slice riêng +6/+1/+1/+2 → 11476/1665/1588/2967).

## Tests

- RED đúng mẫu trước GREEN (failures=2, errors=2: KeyError N2226 ×2 + thiếu advance function + proof Godot-absent).
- Targeted post-register: 3/4 PASS (registration, exact-evidence 78/78, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Family regression: N2174 power + N2212 gate still 3/4 (only their own proof tests fail Godot-absent).
- Targeted wave (5 module): Ran 20, 15 PASS + 5 proof Godot-absent. Neighbours 12 module power+gate+link: Ran 48, 36 PASS + 12 proof Godot-absent, 0 error.
- Full gate wave advances-2: Ran 5969 in 1029.991s, failures=169, skipped=5, 0 errors — 169/169 Godot-absent (164 inherited + 5 new proof tests N2224–N2228).

## SSOT / DEFERRED

- SSOT slice riêng +6/+1/+1/+2 → 11476/1665/1588/2967; audit 1336, legacy 0. **KHÔNG shard nào đổi** — chỉ 4 file SSOT chính (tiền lệ N2212: không có repair-turret shard).
- DEFERRED 258 (258 − 1 resolved RepairTurret advance + 1 new "RepairTurret updateTile live fill"). Entry "RepairTurret live target acquire" GIỮ NGUYÊN verbatim theo brief.
- DEFERRED gộp sau wave advances-2: 260 entries (258 − 8 resolved + 10 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07RepairTurretUpdateTileProof` — 6 keys: target_clears_when_dead_or_out_of_range, rotation_slerps_toward_target, strength_approaches_one_when_healing, heal_amount_folds_repair_speed_strength, reacquire_picks_closest_damaged_candidate, live_tick_writes_advance_frame_keys (live-tick key thay cho `frame_defaults_zero` như tiền lệ N2223 — defaults đã được static assert pin trong row-state test). Toàn bộ số proof đã verify bằng float64 trước khi viết (slerp 90→45, 350→355; strength 0.08/tick, >0.99 sau 60 tick; heal 0.225 live).
