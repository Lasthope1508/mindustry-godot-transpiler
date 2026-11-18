# Báo cáo — N2253 Turret warmup lerp advance (C07)

Ngày: 2026-11-19 ~02:00–03:2x +07. Slice trước N2252 DONE + PUSHED (main 7cf4d813, SSOT 11600/1702/1636/3063).

## Kết luận scoping

N2253 làm được: slice warmup lerp advance cho Turret (duo) — driver đọc `frame["shoot_warmup"]` (SourceTurretBuildState.gd:317) nhưng KHÔNG BAO GIỜ stamp lại, nên warmup không advance live. N2253 lấp gap này theo đúng `TurretBuild.updateTile()` (Turret.java:502-514). 1 pure function `source_turret_warmup_state` (11 params, 3 keys: shoot_warmup, warmup_hold, warmup_target) trong `SourceTurretBuildState.gd:161` + 1 dòng driver tick TRƯỚC aim/shoot trong nhánh duo (`SourceTurretBuildState.gd:391` gọi pure function, `:392-393` stamp `frame["shoot_warmup"]` + `frame["warmup_hold"]`). Hoãn sang slice sau: recoil decay (Turret.java:519) + heat decay (:526) — N2254 candidate, visual-only; charge advance (:527, cần queuedBullets + firstShotDelay > 0) — đi cùng slice queuedBullets; effects/sound; queuedBullets khi shotDelay > 0; findTarget (vẫn BLOCKED — cần live entity scan); các def ItemTurret khác ngoài duo.

## Java đã pin (đọc từ disk)

- `Turret.java:492` — isShooting = alwaysShooting || (player ? isShooting : logicControlled ? logicShooting : target != null) → duo: target != null sau verdict N2251.
- `Turret.java:502` — `float warmupTarget = (isShooting && canConsume()) || charging() ? 1f : 0f;`
- `Turret.java:503-509` — hold set 1f khi target > 0 và !controlled, decay `warmupHold -= Time.delta / warmupMaintainTime`, target ép 1f khi hold > 0.
- `Turret.java:511-515` — linear ? approachDelta : lerpDelta với rate = shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f).
- `Turret.java:441-443` — controlled() = unit.isPlayer(); `:715-717` charging() = queuedBullets > 0 && shoot.firstShotDelay > 0 (duo firstShotDelay 0 → false); `:711` canConsume = `ammo.size > 0 && (ammo.peek().amount >= ammoPerShot || cheating())`.
- Class defaults: minWarmup 0f (:76), warmupMaintainTime 0f (:84), shootWarmupSpeed 0.1f (:136), linearWarmup false (:138); duo KHÔNG override.
- arc `Mathf.java:402-404` clamp [0,1]; `:415-417` approach = from + clamp(to−from, −speed, speed); `:420-422` approachDelta = approach × Time.delta; `:426-428` lerp; `:430-432` lerpDelta = lerp × clamp(progress × Time.delta).
- `Turret.java:733` — shoot gate dùng `shootWarmup >= minWarmup` (duo minWarmup 0 → luôn pass, nhưng warmup vẫn phải advance để frame đúng).
- Edge: maintain_time 0.0 → delta/0 = +inf → warmup_hold → −inf ngay tick set (đúng Java); test chỉ pin hold ≤ 0.0.
- **PIN MỞ ĐÃ ĐÓNG ở RED**: peek amount cho canConsume = entry cuối của `duo_entries` (stacks là dict {"item", "amount"} — SourceItemTurretBuildState.gd:420, useAmmo inline :541-543, `_peek_turret_ammo_state_impl` đọc `stacks[size-1]`); can_consume = stacks non-empty AND (peek amount ≥ 1 OR cheating).

## RED

- Test `tools/mindustry_godot_transpiler/tests/test_c07_turret_warmup.py` (4 tests: registration / input-evidence / behavior / reference-graph) + register script `tools/mindustry_godot_transpiler/register_c07_turret_warmup.py` + proof `C07TurretWarmupProof` (.gd + .tscn).
- Chạy RED (lượt cron 02:0x): Ran 4, FAILED (failures=2, errors=2) — RED chuẩn (registration KeyError 'N2253', behavior thiếu hàm `source_turret_warmup_state`, proof thiếu `C07TurretWarmupProof.tscn`). Register `--verify` **48/48 exprs present**.

## GREEN (lượt cron 02:30, xác minh độc lập lượt 02:45)

- Pure function + comment Java lines đã pin trong `SourceTurretBuildState.gd:161`, đúng chữ ký test RED đã khóa (11 params, thứ tự như test). Driver tick `SourceTurretBuildState.gd:391-393`: trong nhánh duo, TRƯỚC aim/shoot; đọc peek amount từ entry cuối duo_entries → duo_can_consume; gọi pure function với is_shooting = has_target AND validate.valid, charging/controlled/efficiency từ frame, delta = seconds, per-def duo (0.1 / false / 0.0); stamp `frame["shoot_warmup"]` + `frame["warmup_hold"]`.
- Register script main đã chạy → ledger N2253 status done. SSOT **11600/1702/1636/3063 → 11603/1703/1637/3065** (+3 symbols, +1 Done, +1 contract, +2 schema — đúng kỳ vọng); defense shard slices 181 → 182, defense_api_contracts 180 → 181.
- Targeted **4/4 OK, 56 subtests, 21.32s** — lượt cron 02:45 (Godot 4.6.2 Linux headless, port 7777 trống lúc chạy). Family `-k item_turret` + warmup: **116 passed, 317 subtests, 50.16s** (lượt 02:30). Wiring **32/32, 235 subtests, 123.02s** (lượt 02:30; main thread chạy lại 9 module riêng lúc 03:0x, tất cả OK — log `n2253-wiring-main.log`). Neighbours 17 module: batch đầu 7 failed / 61 passed (toàn flake port-7777); chạy lại đúng bộ **68 passed, 836 subtests, 238.17s, 0 failed** (main thread, log `n2253-neighbours-main.log`).
- Godot proof headless Linux: scene `C07TurretWarmupProof.tscn` (.gd + .tscn mới), exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07TurretWarmupProof.json`: **8 keys + matches, 11/11 true, matches:true** — warmup_rises_toward_1_while_shooting, warmup_falls_toward_0_when_no_target, warmup_hold_keeps_target_1, warmup_hold_zero_maintain_no_extend, warmup_linear_approach_branch, warmup_efficiency_scales_rise, warmup_stamped_to_frame_before_aim, warmup_min_warmup_gate_still_passes_duo, registry_valid, one_headquarter_per_ssot.
- `git diff --check` sạch.

## Gate — XANH (trừ Godot-absent), footer về ~03:17 +07 (log `tools/mindustry_godot_transpiler/full-suite-n2253-gate.log`)

- Gate (PID 12978, main thread, launch ~02:57 +07, đúng cwd `tools/mindustry_godot_transpiler/`): **Ran 6105 tests in 1162.347s — FAILED (failures=203, skipped=5, errors=0)**. Đã xác minh độc lập lượt cron 03:15: 203 FAIL headers, cả 203 đều `AssertionError: unexpectedly None`, 0 KeyError, 0 ERROR — toàn Godot-absent, đúng profile kỳ vọng (N2252: 202; N2253 +1 test Godot-dependent → 203). Gate xanh theo chuẩn repo (chỉ fail vì thiếu engine).
- Slice đủ điều kiện commit + push: targeted + family + wiring + neighbours + proof + gate đều xanh.

## Môi trường

- Port 7777 trống trước mọi lần chạy proof, không va chạm agent khác; ps sạch trước khi launch neighbours và gate. Flake port-7777 trong batch neighbours (7 fail lượt đầu, 5 fail lượt gộp 6 module lúc 02:45) đều pass khi chạy lại tách riêng — không phải regression.
- javalang 0.13.0 + pytest 9.2.0 còn importable lúc 02:45 (không cần cài lại).
- VM clock chạy UTC — file mtime ~20:1x UTC = ~03:1x +07.

## Hashes

- Slice `41f09353` / docs `50163cc1` / GOAL `66f44a0f`.
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: sau N2253: N2254 candidate recoil/heat decay (Turret.java:519/:526); findTarget (vẫn BLOCKED) hoặc family tiếp theo trong backlog; live coolant driver wiring + suppression/targets live list vẫn BLOCKED.
