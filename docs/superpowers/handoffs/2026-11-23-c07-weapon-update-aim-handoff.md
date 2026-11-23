# Handoff — N2541 Weapon.update() leg 2 (C07) [DONE + PUSHED (slice fcd53003, docs 83bb2389, GOAL e220cb2f)]

## Status: DONE + PUSHED (lượt cron 07:15 +07 ngày 2026-11-23; slice fcd53003, docs 83bb2389, GOAL e220cb2f; push xong mới ghi origin/main ở đây sau khi push)

- N2540 DONE + PUSHED ~05:15 +07 ngày 2026-11-23, origin/main == 1f7aed4a
  (5 commit: slice 27a829fe + docs 4d2b0fc7 + GOAL df0858e9 + status 5bfd0ebd + hashes 1f7aed4a).
- N2541 DONE (slice fcd53003): targeted 4/4 (54 subtests, 17.00s lượt đóng
  slice, xác minh lại bởi main thread; lượt implement 16.26s);
  register `--verify` 47/47 (18 exact exprs + 20 input + 9 output, chạy lại
  lượt đóng slice); proof matches:true (9/9 semantic keys +
  registry_valid + one_headquarter_per_ssot + matches = 12/12 true, đọc
  trực tiếp C07WeaponUpdateAimProof.json, tái sinh 00:17:53Z bởi targeted
  re-run lượt đóng slice, nội dung không đổi; chạy headless Godot 4.6.2
  Linux trên VM, port 7777 free trước khi chạy, không chạy song song với
  agent kia). Neighbours 347/347 SẠCH (NEIGHBOURS-EXIT 0 23:37:59Z, 347
  passed trong 1165.29s, gồm test_c07_weapon_update_aim.py 4/4); wiring
  32 OK (WIRING-EXIT 0 23:40:03Z, Ran 32 tests trong 123.374s). Gate
  (log full-suite-n2541-gate.log): GATE-START 23:47:44Z, GATE-EXIT 1
  00:09:16Z — Ran 6373 trong 1289.522s, failures=270, skipped=5,
  errors=0, toàn Godot-absent (270 FAIL block, TẤT CẢ
  `AssertionError: unexpectedly None`; 0 KeyError, 0
  `return_schema_linkage`, 0 ERROR; +4 tests / +1 failure vs gate N2540,
  đúng mẫu). `git diff --check` SẠCH (lượt đóng slice, trước commit 1).
- Chain lượt 1 (NEIGHBOURS-START 22:46:36Z) chết do VM restart #33 ~23:04Z
  (uptime 1:15 lúc 00:19Z → boot ~23:04Z; partial log dừng giữa
  test_c07_weapon_update_aim.py). Restart #33 KHÔNG wipe javalang/pytest
  (javalang 0.13.0 import OK, pytest 9.2.0 vẫn chạy, không cần cài lại).
  Chain lượt 2 relaunch main thread 23:18:33Z, sống qua cửa 60s (lesson
  N2523). Gate chạy đủ tới EXIT (script n2541-gate-only-main.sh, Godot
  cố tình OFF PATH — đúng thiết kế chain, nên reference-graph test fail
  Godot-absent trong gate).

## Slice N2541 — scope đã chốt (Weapon.java:313-315, :350-371, :373, bulletRotation :455-457, update() leg 2)

- 1 pure function `source_weapon_update_aim_state` (20 params, 9 return
  keys `mount_x, mount_y, mount_rotation, mount_target_rotation,
  weapon_rotation, bullet_x, bullet_y, shoot_angle, mount_shoot`) trong
  `godot-mindustry/src/game/SourceWeaponsCoreState.gd:366` (sau
  `source_weapon_update_decay_state`, trước `set_rotation_state`),
  + 1 delegate cùng tên trong `SourceWeaponsState.gd:194-195`,
  KHÔNG driver tick.
- Java (Weapon.java:313-315, :350-371, :373):
  `float mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),` /
  `mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);` /
  `if(rotate && (mount.rotate || mount.shoot) && can){` /
  `float axisX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),` /
  `axisY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);` /
  `mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation;` /
  `mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta);` /
  `if(rotationLimit < 360){ float dst = Angles.angleDist(mount.rotation, baseRotation);` /
  `if(dst > rotationLimit/2f){ mount.rotation = Angles.moveToward(mount.rotation, baseRotation, dst - rotationLimit/2f); } }` /
  `}else if(!rotate){ mount.rotation = baseRotation;` /
  `mount.targetRotation = unit.angleTo(mount.aimX, mount.aimY); }` /
  `float weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),` /
  `bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),` /
  `bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY),` /
  `shootAngle = bulletRotation(unit, mount, bulletX, bulletY);` /
  `if(alwaysShooting) mount.shoot = true;` /
  bulletRotation (Weapon.java:455-457):
  `return rotate ? unit.rotation + mount.rotation` /
  `: Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY)` /
  `+ (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation;`.
  (Lưu ý: scope doc ghi mount position :309-312 nhưng dòng Java thật là
  :313-315 — đã verify trực tiếp bằng grep upstream; code/test/register
  dùng :313-315.)
  Mount fields theo WeaponMount.java: rotation, targetRotation, aimX/aimY,
  shoot (default false), rotate (default false); weapon defaults:
  rotateSpeed 20f (Weapon.java:73), rotationLimit 361f (:107),
  baseRotation 0f (:49), shootX 0f / shootY 3f (:91), x 5f / y 0f (:93),
  alwaysShooting false (:63), rotate false (:45). `mount.shoot` /
  `mount.rotate` / `mount.aimX` / `mount.aimY` là FRAME INPUT từ
  autoTarget block (:315-347, BLOCKED — live entity scan), không port
  lại (tiền lệ N2540: `can` là frame bool cho `unit.canShoot()`).
  Bẫy giữ đúng: axisX/axisY trùng hệt mountX/mountY; rotate block đọc
  `mount.rotate` / `mount.shoot` TRƯỚC khi alwaysShooting gán
  `mount.shoot = true`; weaponRotation / bulletRotation dùng rotation ĐÃ
  cập nhật; nhánh `!rotate` targetRotation = angleTo KHÔNG trừ
  unit.rotation; rotationLimit 361f mặc định skip clamp trừ khi < 360.
- DORMANT live hôm nay: update() chưa có driver trong port, không caller
  nào đọc (driver update() tick là slice sau) → live behavior KHÔNG đổi.
- Proof 9 keys: mount_position (unit (100,100) rot 90, weapon (5,0) →
  mount (105,100)) / rotate_toward (rotation 0→−20, targetRotation −90) /
  rotation_limit_clamp (limit 40, rotation 50→30→20) /
  no_rotate_branch (rotation 77→baseRotation 10, targetRotation 0) /
  weapon_rotation (10) / bullet_position ((104.479055, 102.954423)) /
  shoot_angle_rotate (70 = 90 + (−20)) / shoot_angle_aim (100 = 0 +
  (90 − 0) + 10, đủ 3 số hạng bulletRotation) / always_shooting
  (mount_shoot true, rotation giữ 5).

## Files của slice (đã commit fcd53003)

- `godot-mindustry/src/game/SourceWeaponsCoreState.gd` (M — hàm canonical mới)
- `godot-mindustry/src/game/SourceWeaponsState.gd` (M — delegate)
- `tools/mindustry_godot_transpiler/tests/test_c07_weapon_update_aim.py` (mới)
- `tools/mindustry_godot_transpiler/register_c07_weapon_update_aim.py` (mới)
- `godot-mindustry/tools/runtime_proofs/C07WeaponUpdateAimProof.gd` + `.tscn` (mới)
- SSOT (M — register main() đã ghi): `source_slice_ledger.json`,
  `source_symbol_registry.json`, `source_api_contracts.json`,
  `source_state_schema.json`, `source_modules/type_slices.json`,
  `source_modules/type_api_contracts.json` (audit report KHÔNG đổi;
  `source_ssot_modules.json` KHÔNG đổi — type shard đã đăng ký từ
  trước, không shard mới).
- KHÔNG stage: `*.gd.uid` / `project.godot` / `arc-upstream/` /
  `mindustry-upstream/` / proof `.json` (ignored) /
  `full-suite-*.log` / `hidden_files/` (untracked, đã có từ trước).

## Đã xong lượt này (lượt cron ~05:33 +07 scope + implement; lượt cron 07:15 +07 đóng slice)

1. Scope: KHẢ THI (update() leg 2, ứng viên theo handoff N2540);
   đọc trực tiếp Weapon.java + WeaponMount.java, scoping ghi trong
   hidden_files/n2541-scope.md — mọi citation dòng khớp trừ mount
   position :309-312 trong scope (thật là :313-315, đã sửa trong
   code/test/register/handoff này).
2. RED: targeted 4 tests → 4 failures (1.14s, KeyError `N2541` / chưa có
   function / chưa có proof) — đúng trạng thái RED (theo báo cáo worker
   implement; log lượt RED không còn trên đĩa để chạy lại vì code đã
   implement).
3. GREEN: targeted 4/4 (16.26s lượt implement, 54 subtests; lượt đóng
   slice chạy lại 17.00s, godot-bin trên PATH, port 7777 free lúc chạy
   — `ss` grep 7777 = 0 trước khi chạy).
4. Proof matches:true (9/9 semantic keys + registry_valid +
   one_headquarter_per_ssot + matches = 12/12 true, đọc trực tiếp
   C07WeaponUpdateAimProof.json — tái sinh 00:17:53Z bởi targeted re-run
   lượt đóng slice, nội dung không đổi; chạy headless Godot 4.6.2
   Linux trên VM, port 7777 free trước khi chạy, không chạy song song
   với agent kia).
5. Register `--verify` 47/47 (18 exact exprs + 20 inputs + 9 outputs,
   chạy lại lượt đóng slice, exit 0).
6. `git diff --check` SẠCH (lượt đóng slice, trước commit 1; worker
   implement cũng đã chạy sạch).
7. SSOT đo từ đĩa sau GREEN: 11766/1770/1703/3197 (symbols +9, Done
   +1, contracts +1, schemas +2 so với lúc đóng N2540:
   11757/1769/1702/3195). Type shard 63/63 (+1/+1, N2541 vào type
   shard — java_source Weapon.java, tiền lệ N2533-N2540); comp giữ
   572/475. Deferred pool 521 (518 + 3: 1 ghi Weapon.update() leg 2
   DONE + 1 nợ Windows + 1 remaining legs DEFERRED; prefix của N2540
   giữ nguyên, verify bằng diff list). SSOT đo lại từ đĩa lượt đóng
   slice: symbols 11766, ledger 1770 entries (tất cả done, N2541
   status done), contracts 1703, schemas 3197, type 63/63 — khớp.
8. Chain neighbours + wiring + gate (main thread):
   NEIGHBOURS-EXIT 0 23:37:59Z (347 passed / 0 failed, 1165.29s, gồm
   test_c07_weapon_update_aim.py 4/4), WIRING-EXIT 0 23:40:03Z (32 OK,
   123.374s), GATE-START 23:47:44Z, GATE-EXIT 1 00:09:16Z (Ran 6373,
   failures=270 toàn Godot-absent).
9. Chain lượt 1 (NEIGHBOURS-START 22:46:36Z) chết do VM restart #33
   ~23:04Z (uptime 1:15 lúc 00:19Z → boot ~23:04Z; partial log dừng giữa
   test_c07_weapon_update_aim.py). Restart này KHÔNG xóa javalang +
   pytest (khác restart #31) — đã verify trước khi relaunch, không cần
   cài lại. Chain lượt 2 relaunch main thread 23:18:33Z; survival-check
   qua cửa 60s (lesson N2523). Gate chạy đủ tới EXIT.
10. Gate phân rã theo FAIL block (lượt đóng slice, đọc trực tiếp
    full-suite-n2541-gate.log): 270 FAIL block, TẤT CẢ
    `AssertionError: unexpectedly None`; 0 KeyError, 0
    `return_schema_linkage`, 0 ERROR; +4 tests / +1 failure vs gate
    N2540, đúng mẫu — failure mới là duy nhất trong diff FAIL list:
    test_reference_graph_and_actual_c07_weapon_update_aim
    (Godot-absent vì gate chạy không có godot trên PATH, đúng thiết kế);
    baseline hydration test_liquid_consumer_hydration là 1 FAIL block
    hằng số trong 270.

## Còn lại để đóng slice (lượt đóng slice, cron 07:15 +07)

- Spec + GOAL §5 (dòng nợ Windows) + status commit, rồi 5 commit
  theo mẫu N2537/N2538/N2539/N2540 (slice fcd53003 + docs + GOAL +
  status + hashes) và push origin main — gate đã xanh (toàn Godot-absent).

## Deferred / BLOCKED (không đổi sau N2541-scope)

- Weapon.update() remaining legs — DEFERRED (slice sau N2541):
  auto-target block (Weapon.java:315-347, BLOCKED — findTarget :447 live
  Units.closestTarget scan, checkTarget :451 live Units.invalidateTarget,
  Predict.intercept chưa port); continuous-laser leg (:376-411, bullet
  entity live — BLOCKED làm driver leg; shootLength :391 dùng range()
  N2539 + approachDelta, pure); heat decay (:407-415 else-branch, pure —
  ứng viên N2542, cooldownTime = 20f Weapon.java:89); side-flip leg
  (:418-423, pure với `lastReload` :294 làm frame input riêng — leg 1
  chỉ trả reload SAU decay); activeSound (:425-427, audio — skip); shoot
  gate + shoot() (:429-444, BLOCKED/live — shoot() spawn bullet thật,
  :459+; velLen cần unit.isRemote/deltaLen live). flip() :544 cần
  ShootPattern.copy()/flip() (port status chưa kiểm) — defer. init() :562
  trivial (alwaysContinuous → continuous) — micro-slice sau. addStats()
  :175-187 UI stats, C11-ish — defer. Driver update() tick (chưa có
  driver).
- Weapon.update findTarget — BLOCKED (live entity scan).
- UnitType.init range / maxRange consumer — DEFERRED (slice sau
  N2539): UnitType.java:971-989, `range = Math.min(range,
  weapon.range() - margin);` / `maxRange = Math.max(maxRange,
  weapon.range() - margin);` với margin 4f, gated trên
  `weapon.useAttackRange`; `maxRange = Math.max(0f, range)` khi
  maxRange < 0.
- Per-part DrawPart drawing (Weapon.java:232-244 và 271-281) —
  DEFERRED (slice sau N2538): DrawPart subsystem, chưa port.
- Unit draw call-site gọi `source_weapon_draw_state` — DEFERRED
  (slice sau N2538): Unit draw / WeaponMount draw integration, chưa
  wire hàm mới vào đường draw live.
- Unit draw call-site gọi `source_weapon_draw_outline_state` —
  DEFERRED (slice sau N2537): Unit draw gọi drawOutline(), chưa wire.
- Consumer gọi `source_unit_type_weapons_dps_sum_state` rồi truyền
  vào `source_unit_type_estimate_dps_state` — DEFERRED (slice sau
  N2536): N2533 vẫn nhận `weapons_dps_sum` làm float param.
- C11 HUD / stats display đọc `weapons_dps_sum` — DEFERRED (slice
  sau): `addStats()` / UnitType stats hiển thị estimateDps, chưa
  wire vào hàm mới.
- Turret live hasAmmo() computation — DEFERRED (hasAmmo MUTATES ammo stack,
  Turret.java:703; cần caller slice đọc tick ammo stacks + canConsume live +
  ammoPerShot per-def; C11 status display đọc `status` cũng là slice sau).
- Turret range() consumers — findTarget (Turret.java:652-656, BLOCKED — live
  entity scan) + aim within-check rewire (slice consumer riêng).
- Turret sense frame per-graph split — DEFERRED (chờ PowerGraph.addGraph merge
  port; `addGraph` hiện chỉ là source-text constant `java_method_addGraph_20`,
  chưa port).
- Compose SenseI leg (N2510) với dispatch ở caller — chờ logic-executor driver
  (chưa có LExecutor instruction loop trong port).
- Live player-unit source cho `unit_is_player` — chờ player control.
- Turret liquid-module wiring (frame liquid state + coolant pick live) —
  BLOCKED cho driver tick của hàm N2525.
- LaserTurret shouldConsume() (LaserTurret.java:55) — needs a per-build
  bullets list + LaserTurret driver.
- calculateHeat — BLOCKED (live entity scan); findTarget — BLOCKED (live
  entity scan).
- N2540 guard nit (KHÔNG sửa lượt này): `while out_recoils.size() <
  recoils: append 0.0` trong SourceWeaponsCoreState.gd là guard phòng thủ
  phía GDScript ngoài scope chữ (Java sẽ lỗi index nếu array ngắn hơn
  recoils) — đã ghi chú trong code, để nguyên.

## Next sau N2541 (ứng viên theo thứ tự Weapon.java, chưa scope)

- N2541 đóng xong lượt cron 07:15 +07 ngày 2026-11-23 (slice fcd53003,
  neighbours 347/347, wiring 32 OK, gate Ran 6373 / failures 270 toàn
  Godot-absent, push origin main sau 5 commit theo mẫu N2537/N2538/N2539/N2540).
- Sau đó tiếp tục Weapon.update() leg 3 — ứng viên N2542, cần scope riêng
  (heat decay Weapon.java:407-415 else-branch, PURE, cooldownTime = 20f;
  hoặc side-flip leg :418-423, cần `lastReload` làm frame input riêng).
  calculateHeat vẫn BLOCKED, findTarget BLOCKED.
