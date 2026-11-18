# Handoff — N2250 ItemTurret aim/reload/shoot (C07) [DONE — gate xanh, chờ commit/push]

## Status: DONE (gate xanh, lượt cron 22:00 2026-11-18 +07) — GREEN targeted + family + wiring + proof + gate full; report + spec + GOAL đã cập nhật; CHƯA commit/push, origin/main == 8a0f8c71 (N2249)

- Targeted 4/4, 111 subtests, 16.00s (main thread re-run, PATH += ~/workspace/godot-bin; lưu ý: `godot` KHÔNG có sẵn trên PATH mặc định — lần chạy đầu không có PATH đã fail nhanh `unexpectedly None`, không phải lỗi slice).
- Family 16/16, 237 subtests, 60.29s (item turret test + 3 module PointDefenseTurret: aim_shoot, power_status, target_acquire).
- Wiring 32/32, 250 subtests, 123.63s (9 module live-loop/binding như N2240).
- Godot proof `C07ItemTurretAimShootProof`: 10 keys / matches:true (trong targeted proof test; file `C07ItemTurretAimShootProof.json` trên đĩa cũng matches:true). Log targeted cũ của worker (n2250-green.log 14:12) từng fail 1 key `predict_intercept_leads_moving_target: False` — worker đã sửa sau đó, main thread re-run 14:18 xác nhận 4/4.
- Register `--verify`: 115/115 exprs present; ledger N2250 status done.
- SSOT xác minh từ đĩa: symbols 11587 / Done 1700 / contracts 1634 / schemas 3059 (đúng kỳ vọng sau GREEN).
- VM restart giữa chừng đã wipe javalang + pytest — main thread đã cài lại (javalang 0.13.0, pytest 9.2.0) trước khi chạy family/wiring.
- Port 7777 trống trước mọi lần chạy, không va chạm agent khác.
- Còn lại: commit + push theo mẫu N2249 (slice + docs + GOAL + hashes + handoff-status, rồi fix-up nếu Status lệch). Gate full ĐÃ XANH (main thread launch ~21:30, PID 2512, log `tools/mindustry_godot_transpiler/full-suite-n2250-gate.log`): Ran 6093 in 1088.988s, FAILED (failures=200, skipped=5, errors=0) — 200 FAIL header = 200 × `AssertionError: unexpectedly None` (Godot-absent), 0 ERROR header, footer ~21:48 +07. Docs đã xong lượt cron 22:00: report `reports/2026-11-18-c07-item-turret-aim-shoot.md`, handoff này, spec Done 1699 → 1700 + row N2250, GOAL §5 thêm nợ Windows N2250. Lượt 22:00 chạy lại targeted 4/4 OK, 111 subtests, 17.78s; proof JSON trên đĩa mtime 22:02 +07, matches:true.

## Scope (đã khóa, xác minh từ đĩa — xem `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2250-item-turret-scope.md`)

- Slice đầu họ ItemTurret: aim/reload/shoot theo mẫu N2240.
  `ItemTurret` KHÔNG override `updateTile` (ItemTurret.java:23);
  toàn bộ aim/reload/shoot nằm ở `Turret.TurretBuild.updateTile()`
  (Turret.java:490–615).
- Driver: driver chung `source_turret_tick_buildings_state` trong
  `SourceTurretBuildState.gd:160` đã tick mọi `TurretBuild`. Dòng
  tick N2250 thêm vào đó, guard `block_id == "duo"`, gọi pure
  function mới trong `SourceItemTurretBuildState.gd`.
- 1 pure function `source_item_turret_aim_shoot_state` trả 10 keys:
  rotation, reload_counter, dest, shot, target_pos,
  total_ammo_after, ammo_entries_after, shoot_event,
  barrel_counter_after, was_shooting.
- Per-def duo (Blocks.java:3257): range 160, rotateSpeed 10,
  reload 20, shootCone 15, shootY 3, inaccuracy 2, ammoPerShot 1,
  consumeAmmoOnce true, shoot ShootAlternate(3.5), ammo
  copper/graphite/silicon reloadMultiplier 1.0/0.8/1.5,
  rangeChange 0/16/0.
- Điểm pin khác N2240 (đã xác minh từ đĩa):
  - shoot gate Angles.angleDist < shootCone STRICT < (Turret.java:599);
  - reload cap min(reloadCounter, reload) (Turret.java:719-724);
  - shoot reset reloadCounter %= reload (Turret.java:738);
  - canShoot within(target, range() + hitSize/1.9) (Turret.java:585);
  - turnToTarget rotateSpeed * delta() * potentialEfficiency
    (Turret.java:665-667);
  - updateShooting thêm !charging() && shootWarmup >= minWarmup
    (Turret.java:733-737);
  - targetPosition dùng Predict.intercept khi predictTarget &&
    bullet.speed >= 0.01 (Turret.java:464-465; quad tại
    Predict.java:87-104, KHÔNG phải :104-122 như scope cũ ghi).
- Ammo plumbing: stacks là dict {"item", "amount"} theo
  `SourceTurretAmmoState.selected_turret_ammo_entries` /
  `peek/use_ammo_stack_state`; useAmmo tính inline theo đúng
  Turret.java:680-690, có chú thích trỏ
  `source_turret_use_ammo_state` đã đăng ký trong
  `SourceTurretBuildState.gd`.
- Hoãn sang slice sau: bullet() spawn chi tiết, findTarget/
  validateTarget (pure function nhận `target_valid` làm param),
  warmup lerp advance, queuedBullets khi shotDelay > 0, các def
  ItemTurret khác ngoài duo.
- `SourceItemTurretBuildState.gd` (333 dòng) KHÔNG có helper
  `_angle_dist`/`_move_toward_angle` riêng — GREEN cần helper
  tương tự N2240 (SourcePointDefenseTurretBuildState.gd:224/:234).

## SSOT baseline (đo từ đĩa 2026-11-18, = trạng thái N2249)

- symbols 11577 / slices done 1699 / contracts 1633 / schemas 3057.
- Audit: totalSourceFunctions 1337, legacyUnregisteredOwnerCount 0.
- SSOT kỳ vọng sau GREEN: symbols +10, Done +1, contracts +1,
  schema +2 → 11587/1700/1634/3059; defense shard slices 178 → 179.

## RED plan (đã xong)

1. Test RED `test_c07_item_turret_aim_shoot.py` (4 tests, mẫu
   N2240/N2249) + register script
   `register_c07_item_turret_aim_shoot.py` + `--verify` 115/115.
2. Targeted RED: failures=2, errors=2 (xem Status trên).

## GREEN plan (lượt sau)

1. Pure function + helper `_angle_dist`/`_move_toward_angle` (+
   quad Predict.intercept inline) trong
   `SourceItemTurretBuildState.gd`, theo đúng chữ ký và các dòng
   assertIn mà test RED đã pin (30 params, thứ tự như test).
2. 1 dòng driver tick trong `SourceTurretBuildState.gd` (guard
   `block_id == "duo"`, duo 160.0/10.0/20.0/15.0, stamp rotation /
   reload_counter về frame).
3. Chạy register main (KHÔNG chạy ở bước RED) → ledger N2250,
   rồi targeted 4/4 → family + wiring → Godot proof mới
   `C07ItemTurretAimShootProof` (.gd + .tscn, headless Godot 4.6.2
   Linux, kiểm tra port 7777 trống trước; 8 proof keys đã pin
   trong test).
4. Gate full: CHỈ main thread launch. Không commit/push khi chưa
   đủ điều kiện (test + proof + gate xanh).
