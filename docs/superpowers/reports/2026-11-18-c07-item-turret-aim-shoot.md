# Báo cáo — N2250 ItemTurret aim/reload/shoot (C07)

Ngày: 2026-11-18 ~21:0x–22:0x +07. Slice trước N2249 DONE + PUSHED (main 8a0f8c71, SSOT 11577/1699/1633/3057).

## Kết luận scoping

N2250 làm được: slice đầu họ ItemTurret — aim/reload/shoot cho duo theo mẫu N2240. `ItemTurret` KHÔNG override `updateTile` (ItemTurret.java:23); toàn bộ aim/reload/shoot nằm ở `Turret.TurretBuild.updateTile()` (Turret.java:490–615). 1 pure function `source_item_turret_aim_shoot_state` (30 params, 10 keys) trong `SourceItemTurretBuildState.gd:251` + 1 dòng driver tick trong driver chung `source_turret_tick_buildings_state` (`SourceTurretBuildState.gd:234` guard `block_id == "duo"`, `:285` gọi pure function, stamp rotation / reload_counter về frame). Hoãn sang slice sau: bullet() spawn chi tiết, findTarget/validateTarget (pure function nhận `target_valid` làm param), warmup lerp advance, queuedBullets khi shotDelay > 0, các def ItemTurret khác ngoài duo.

## Java đã pin (đọc từ disk)

- Per-def duo (Blocks.java:3257): range 160, rotateSpeed 10, reload 20, shootCone 15, shootY 3, inaccuracy 2, ammoPerShot 1, consumeAmmoOnce true, shoot ShootAlternate(3.5), ammo copper/graphite/silicon reloadMultiplier 1.0/0.8/1.5, rangeChange 0/16/0.
- Điểm pin khác N2240: shoot gate Angles.angleDist < shootCone STRICT < (Turret.java:599); reload cap min(reloadCounter, reload) (Turret.java:719-724); shoot reset reloadCounter %= reload (Turret.java:738); canShoot within(target, range() + hitSize/1.9) (Turret.java:585); turnToTarget rotateSpeed * delta() * potentialEfficiency (Turret.java:665-667); updateShooting thêm !charging() && shootWarmup >= minWarmup (Turret.java:733-737); targetPosition dùng Predict.intercept khi predictTarget && bullet.speed >= 0.01 (Turret.java:464-465; quad tại Predict.java:87-104).
- Ammo plumbing: stacks là dict {"item", "amount"} theo `SourceTurretAmmoState.selected_turret_ammo_entries` / `peek/use_ammo_stack_state`; useAmmo tính inline theo đúng Turret.java:680-690, có chú thích trỏ `source_turret_use_ammo_state` đã đăng ký trong `SourceTurretBuildState.gd`.

## RED

- Test `tools/mindustry_godot_transpiler/tests/test_c07_item_turret_aim_shoot.py` (4 tests: registration / input-evidence / behavior / reference-graph) + register script `tools/mindustry_godot_transpiler/register_c07_item_turret_aim_shoot.py` + proof `C07ItemTurretAimShootProof` (.gd + .tscn).
- Chạy RED: **failures=2, errors=2** — đúng mẫu N2240/N2249.

## GREEN (main thread xác minh ~21:2x +07; lượt cron 22:00 chạy lại targeted)

- Pure function + helper `_angle_dist` (`SourceItemTurretBuildState.gd:202`) / `_move_toward_angle` (`:212`) + quad Predict.intercept inline; 10 keys trả về: rotation, reload_counter, dest, shot, target_pos, total_ammo_after, ammo_entries_after, shoot_event, barrel_counter_after, was_shooting.
- Register script `--verify` **115/115** exprs present. Ledger N2250 status done, `godot_owner = SourceItemTurretBuildState.source_item_turret_aim_shoot_state`. SSOT **11577/1699/1633/3057 → 11587/1700/1634/3059** (+10 symbols, +1 Done, +1 contract, +2 schema); defense shard slices 178 → 179, defense_api_contracts 177 → 178.
- Targeted **4/4 OK, 111 subtests, 17.78s** — lượt cron 22:00 chạy lại từ đầu (PATH += ~/workspace/godot-bin; lưu ý: `godot` KHÔNG có sẵn trên PATH mặc định). Family **16/16, 237 subtests, 60.29s** (item turret test + 3 module PointDefenseTurret: aim_shoot, power_status, target_acquire). Wiring **32/32, 250 subtests, 123.63s** (9 module live-loop/binding như N2240).
- Godot proof headless Linux: scene `C07ItemTurretAimShootProof.tscn` (.gd + .tscn mới), exit 0, 0 ERROR. JSON `godot-mindustry/tools/runtime_proofs/C07ItemTurretAimShootProof.json` (untracked, KHÔNG stage): **10 keys + matches, 11/11 true, matches:true** — aim_rotates_toward_target, aim_no_rotation_without_target, aim_ignores_out_of_range_target, reload_caps_and_shoots_in_cone, shoot_consumes_one_ammo, shoot_event_carries_bullet_origin, predict_intercept_leads_moving_target, no_shoot_when_charging_or_warmup_low, registry_valid, one_headquarter_per_ssot. JSON trên đĩa có mtime 22:02 +07 (từ lần chạy lại targeted lượt 22:00), matches:true.
- Log targeted cũ của worker (n2250-green.log 14:12 UTC) từng fail 1 key `predict_intercept_leads_moving_target: False` — worker đã sửa sau đó, main thread re-run 14:18 UTC xác nhận 4/4.
- `git diff --check` sạch.

## Gate — XANH (main thread)

- Gate full (main thread launch ~21:30, PID 2512, log `tools/mindustry_godot_transpiler/full-suite-n2250-gate.log`): **Ran 6093 in 1088.988s, FAILED (failures=200, skipped=5, errors=0)** — tất cả 200 đều `AssertionError: unexpectedly None` (Godot-absent), đếm 200 FAIL header = 200 assert, 0 ERROR header, khớp kỳ vọng Ran 6093 / failures 200. Gate xanh theo quy ước repo (failures toàn Godot-absent). Footer có lúc ~21:48 +07 (mtime log 14:48 UTC).
- Slice đủ điều kiện commit + push: targeted + family + wiring + proof + gate đều xanh.

## Môi trường

- Port 7777 trống trước mọi lần chạy, không va chạm agent khác.
- VM restart giữa chừng đã wipe javalang + pytest — main thread đã cài lại (javalang 0.13.0, pytest 9.2.0) trước khi chạy family/wiring; lượt 22:00 xác nhận cả hai còn importable.
- VM clock chạy UTC — file mtime ~15:0x UTC = ~22:0x +07.

## Hashes

- Slice `a2270c04` / docs `9639adbc` / GOAL `6d94d1ac` (handoff-status commit follows; main hash filled at push).
- Windows Godot proof là nợ trong GOAL.md §5 (proof Linux xanh, chưa chạy Windows).
- Bước tiếp theo: commit + push N2250 → sau N2250: bullet() spawn chi tiết / findTarget / warmup lerp / queuedBullets / các def ItemTurret khác ngoài duo (slice riêng); live coolant driver wiring + suppression/targets live list vẫn BLOCKED.
