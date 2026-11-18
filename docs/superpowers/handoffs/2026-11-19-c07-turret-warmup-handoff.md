# Handoff — N2253 Turret warmup lerp advance (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~03:2x +07, lượt cron 03:15) — slice `41f09353`, main `294ff8b0`. Targeted 4/4 + family 116/116 + wiring 32/32 + neighbours 68/68 + proof matches:true 11/11 + gate Ran 6105, failures=203 toàn Godot-absent (đã xác minh độc lập).

- GREEN đã xong từ lượt 02:30 (pure function `source_turret_warmup_state` + 1 dòng driver tick + register + proof `C07TurretWarmupProof` đã có trong worktree, chưa commit). Lượt 02:45 xác minh độc lập:
- Targeted **4/4, 56 subtests, 21.32s** (`test_c07_turret_warmup.py`, Godot 4.6.2 Linux headless, port 7777 trống lúc chạy). Proof JSON `matches:true`, 8/8 keys true.
- Register `--verify` **48/48 exprs present**.
- Family + wiring: lượt 02:30 family **116 passed, 317 subtests, 50.16s**; wiring **32/32, 235 subtests, 123.02s**. Lượt 02:45 chạy gộp 6 module (warmup + aim_shoot + validate_target + bullet_spawn + power_status + live_loop) lần đầu 5 failed — toàn `test_reference_graph_and_actual_*` (proof Godot), do port-7777 flake (agent khác đang dùng Godot lúc đó); chạy lại tách riêng **đều PASS** (bullet_spawn 1 passed/8 subtests; power_status + live_loop + aim_shoot + validate_target 10 passed/154 subtests). Không phải regression.
- SSOT sau GREEN: **11603/1703/1637/3065** (đúng kỳ vọng); defense shard slices 182, contracts 181.
- Neighbours (17 module: 12 PointDefenseTurret + 3 ItemTurret + warmup + live_loop) **đang chạy trên main thread từ 02:52** (PID 12455/12456, log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2253-neighbours-main.log`) — KHÔNG chạy trùng, KHÔNG chạy proof song song (port 7777 đang bận).
- javalang + pytest importable. `git diff --check` sạch.

## Scope (đã khóa, xác minh từ đĩa — xem `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2253-turret-warmup-lerp-scope.md`)

- Slice warmup lerp advance cho duo: driver đọc `frame["shoot_warmup"]` (SourceTurretBuildState.gd:317) nhưng KHÔNG BAO GIỜ stamp lại — warmup không advance live. N2253 lấp gap này.
- 1 pure function `source_turret_warmup_state` (11 params, 3 result keys: shoot_warmup, warmup_hold, warmup_target) trong `SourceTurretBuildState.gd` (file turret chung — TurretBuild.updateTile) + 1 dòng driver tick TRƯỚC aim/shoot trong nhánh duo.
- PIN MỞ ĐÃ ĐÓNG ở RED: peek amount cho canConsume = entry cuối của `duo_entries` (stacks là dict {"item", "amount"} — SourceItemTurretBuildState.gd:420, useAmmo inline :541-543 `ammo_entries_after[ammo_entries_after.size() - 1]`, `_peek_turret_ammo_state_impl` đọc `stacks[stacks.size() - 1]`). can_consume = stacks non-empty AND (peek amount >= ammoPerShot 1 OR cheating).

## Java evidence (đã xác minh từ đĩa)

- `Turret.java:492` — isShooting = alwaysShooting || (player ? isShooting : logicControlled ? logicShooting : target != null) → duo: target != null sau verdict N2251.
- `Turret.java:502` — `float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;`
- `Turret.java:503-509` — hold set 1f khi target > 0 và !controlled, decay `warmupHold -= Time.delta / warmupMaintainTime`, target ép 1f khi hold > 0.
- `Turret.java:511-515` — linear ? approachDelta : lerpDelta với rate = shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f).
- `Turret.java:441-443` — controlled() = unit.isPlayer(); `:715-717` charging() = queuedBullets > 0 && shoot.firstShotDelay > 0 (duo firstShotDelay 0 → false); `:711` canConsume = `ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating())`.
- Class defaults: minWarmup 0f (:76), warmupMaintainTime 0f (:84), shootWarmupSpeed 0.1f (:136), linearWarmup false (:138); duo KHÔNG override.
- arc `Mathf.java:402-404` clamp [0,1]; `:415-417` approach = from + clamp(to−from, −speed, speed); `:420-422` approachDelta = approach × Time.delta; `:426-428` lerp; `:430-432` lerpDelta = lerp × clamp(progress × Time.delta).
- `Turret.java:733` — shoot gate dùng `shootWarmup >= minWarmup` (duo minWarmup 0 → luôn pass, nhưng warmup vẫn phải advance để frame đúng).
- Edge: maintain_time 0.0 → delta/0 = +inf → warmup_hold → −inf ngay tick set (đúng Java); test chỉ pin hold ≤ 0.0.
- hasAmmo() swap (`Turret.java:700-706`) là hasAmmo detail, chờ slice hasAmmo riêng — can_consume đọc peek amount as-is.

## Thiết kế slice (đã khóa ở RED, test đã pin)

- Pure function `source_turret_warmup_state(shoot_warmup, warmup_hold, is_shooting, can_consume, charging, controlled, efficiency, delta, shoot_warmup_speed, linear_warmup, warmup_maintain_time) -> Dictionary`, công thức theo đúng thứ tự Java (target → hold set → hold decay → rate → approach/lerp).
- Driver tick: đọc peek amount từ entry cuối duo_entries → duo_can_consume → gọi pure function với is_shooting = has_target AND validate.valid, charging/controlled/efficiency từ frame, delta = seconds, per-def duo (0.1 / false / 0.0) → stamp frame["shoot_warmup"] + frame["warmup_hold"] TRƯỚC lời gọi aim/shoot.
- 8 proof keys đã pin trong test: warmup_rises_toward_1_while_shooting, warmup_falls_toward_0_when_no_target, warmup_hold_keeps_target_1, warmup_hold_zero_maintain_no_extend, warmup_linear_approach_branch, warmup_efficiency_scales_rise, warmup_stamped_to_frame_before_aim, warmup_min_warmup_gate_still_passes_duo.
- SSOT kỳ vọng sau GREEN: symbols +3, Done +1, contracts +1, schema +2 → 11603/1703/1637/3065; defense shard slices 181 → 182, contracts 180 → 181.

## Tiếp theo: GATE N2253 (main thread)

- Neighbours đang chạy trên main thread (02:52) — chờ xong, đọc `n2253-neighbours-main.log`.
- **Lượt cron 03:15:** gate XONG XANH — Ran 6105 in 1162.347s, FAILED (failures=203, skipped=5, errors=0), log `tools/mindustry_godot_transpiler/full-suite-n2253-gate.log` (PID 12978, main thread, launch ~02:57, footer ~03:17). Xác minh độc lập: 203 FAIL headers, cả 203 đều `AssertionError: unexpectedly None`, 0 KeyError, 0 ERROR — toàn Godot-absent, đúng profile kỳ vọng (N2252: 202 → N2253: 203, +1 test Godot-dependent). Proof JSON đã đọc lại: `matches:true`, 11/11 true (8 keys). SSOT đã đọc lại từ đĩa: 11603/1703/1637/3065; defense slices 182, contracts 181.
- Slice đủ điều kiện commit + push: targeted 4/4 + family 116/116 + wiring 9/9 module OK + neighbours 68/68 + proof matches:true + register 48/48 + gate xanh (trừ Godot-absent). Hashes: slice `41f09353` / docs `50163cc1` / GOAL `66f44a0f`.
- Chưa commit/push (N2253 mới gate xanh lượt này).

## Deferred sau N2253

- N2254 candidate: recoil decay `Turret.java:519` + heat decay `:526` — cùng block updateTile, visual-only.
- charge advance `:527` (cần queuedBullets + firstShotDelay > 0) — đi cùng slice queuedBullets.
- effects/sound, queuedBullets (shotDelay > 0), findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
