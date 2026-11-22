# Handoff — N2537 Weapon.drawOutline() (C07) [DONE + PUSHED (slice 2e49bd95, docs 36afca58, GOAL 1fab1442, status e4360200)]

## Status: DONE + PUSHED (lượt cron 23:15 +07 ngày 2026-11-22; slice 2e49bd95, docs 36afca58, GOAL 1fab1442, status e4360200; push xong mới ghi origin/main ở đây sau khi push)

- N2536 DONE + PUSHED ~21:54 +07 ngày 2026-11-22, origin/main == 6ea3acea
  (5 commit: slice 3a6481d9 + docs 3ff9c015 + GOAL 04a2b2e7 + status 05cd344e + hashes 6ea3acea).
- N2537 DONE (slice 2e49bd95): targeted 4/4 (35 subtests, 16.78s, xác minh
  lại bởi lượt đóng slice, godot-bin trên PATH, port 7777
  free; lượt implement GREEN 4/4); register `--verify` 27/27;
  proof matches:true (8/8 semantic keys + registry_valid +
  one_headquarter_per_ssot = 11/11 true, đọc trực tiếp
  C07WeaponDrawOutlineProof.json, mtime gốc lượt implement
  ~15:05Z — tái sinh 16:18Z bởi targeted re-run lượt đóng slice,
  nội dung không đổi; chạy headless Godot 4.6.2 Linux trên VM,
  port 7777 free trước khi chạy, không chạy song song với agent
  kia). Neighbours 331/331 SẠCH sau flake re-run
  (NEIGHBOURS-EXIT 1 15:37:18Z, 330 passed / 1 failed flake
  port-7777, chạy lại isolated 4 passed, 19 subtests, 21.90s);
  wiring 32 OK (WIRING-EXIT 0 15:39:24Z, 126.507s). Gate (log
  full-suite-n2537-gate.log): launch 15:47:29Z, unittest PID
  30266, log mtime 16:08:59Z — Ran 6357 trong 1288.460s,
  failures=266, skipped=5, errors=0, toàn Godot-absent (266 FAIL
  block, TẤT CẢ `AssertionError: unexpectedly None`, 266 lần xuất
  hiện đúng 1 lần/block; 0 KeyError, 0 return_schema_linkage,
  0 ERROR; +4 tests / +1 failure vs gate N2536, đúng mẫu).
  `git diff --check` SẠCH (lượt đóng slice, trước commit 1).
- Neighbours + wiring: chain lượt duy nhất (main thread) —
  NEIGHBOURS-START 15:18:50Z → NEIGHBOURS-EXIT 1 15:37:18Z, 330
  passed / 1 failed (81 module tích lũy + test_c07_weapon_draw_outline.py
  = 331 items); WIRING-START 15:37:18Z → WIRING-EXIT 0 15:39:24Z,
  Ran 32 tests, OK. Gate chạy tiếp: launch 15:47:29Z → log mtime
  16:08:59Z (worker-launch, nohup setsid — sống tới EXIT, khác mẫu
  thường chết giữa chừng).
- SSOT đo từ đĩa sau GREEN: 11737/1766/1699/3189 (symbols +5, Done +1,
  contracts +1, schemas +2 so với lúc đóng N2536: 11732/1765/1698/3187).
  Type shard 59/59 (+1/+1, N2537 vào type shard — java_source
  Weapon.java, tiền lệ N2533-N2536); comp giữ 572/475.
  Deferred pool 508 (505 + 3: 1 ghi Weapon.drawOutline() DONE + 1 nợ
  Windows + 1 Unit draw call-site gọi drawOutline() DEFERRED).
  Lưu ý: mục drawOutline DEFERRED đếm ở handoff N2535 giờ chính là
  record DONE này — không đếm trùng; base 505 theo báo cáo N2536
  đã chốt (handoff N2535 ghi 503 đếm trùng — xem báo cáo N2536).

## Slice N2537 — scope đã chốt (Weapon.java:196-213, drawOutline())

- 1 pure function `source_weapon_draw_outline_state(outline_found: bool,
  unit_rotation: float, unit_x: float, unit_y: float, mount_recoil: float,
  mount_rotation: float, rotate: bool, base_rotation: float, recoil: float,
  recoil_pow: float, weapon_x: float, weapon_y: float, flip_sprite: bool)
  -> Dictionary` trong
  `godot-mindustry/src/game/SourceWeaponsCoreState.gd:108` (sau
  `source_weapon_shots_per_sec_state`, trước `set_rotation_state`),
  + 1 delegate cùng tên trong `SourceWeaponsState.gd:182-183`,
  KHÔNG driver tick.
- Java (Weapon.java:196-213):
  `public void drawOutline(Unit unit, WeaponMount mount){` /
  `if(!outlineRegion.found()) return;` /
  `rotation = unit.rotation - 90,` /
  `realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,` /
  `weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),` /
  `wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),` /
  `wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);` /
  `Draw.xscl = -Mathf.sign(flipSprite);` /
  `Draw.rect(outlineRegion, wx, wy, weaponRotation);` /
  `Draw.xscl = 1f;`
- Fields (Weapon.java): flipSprite=false (:41), rotate=false (:45),
  baseRotation=0f (:49), recoil=1.5f (:81), recoilPow=1.8f (:87),
  x=5f, y=0f (:93), outlineRegion (:147). Mount fields
  (WeaponMount.java): `public float rotation;` (:14),
  `public float recoil;` (:16).
- `Mathf.sign(boolean)` — arc `arc-upstream/arc-core/src/arc/math/Mathf.java:203-205`:
  `return b ? 1 : -1;` — nên `Draw.xscl = -Mathf.sign(flipSprite)` là
  -1.0 khi flipSprite true, +1.0 khi false.
- `Angles.trnsx/trnsy(angle, x, y)` tái dùng `source_angles_trns_vec`
  có sẵn (SourceMathState.gd:140-147) gọi 2 lần (base offset + recoil
  offset), không phát minh port scalar mới.
- `outline_found` handling — tiền lệ `draw_team_top_state`
  (SourceBuildingDrawState.gd:159-163): bool `*_region_found` param
  đầu tiên, early return `{"visible": false}` khi không found.
- Trả đúng 5 key (đều là symbol): visible, outline_x, outline_y,
  weapon_rotation, xscl. Intermediates `rotation` / `real_recoil`
  KHÔNG phải return key. `Draw.xscl` reset 1f sau Draw.rect chỉ là
  restore render-state, không phải return value.
- DORMANT live hôm nay: draw code, rendering nằm ngoài game, không
  caller nào đọc (call-site Unit draw gọi drawOutline() là slice sau).
- Proof 8 keys: outline_java_defaults (defaults Java → visible,
  (5.0, 0.0), rotation 0.0, xscl 1.0) / outline_not_found
  (outline_found false → visible false) / outline_flip_sprite
  (flip true → xscl -1.0, (5.0, 0.0)) / outline_rotate_mount
  (rotate true, mount_rotation 30 → weapon_rotation 30.0, (5.0, 0.0))
  / outline_recoil (mount_recoil 1.0 → (5.0, -1.5), rotation 0.0) /
  outline_unit_rot_180 (unit_rotation 180 → (0.0, 5.0),
  weapon_rotation 90.0) / outline_base_rotation (rotate false,
  base_rotation 45 → weapon_rotation 45.0, (5.0, 0.0)) /
  outline_fractional (unit_rotation 45 → (3.5355339, -3.5355339),
  weapon_rotation -45.0).

## Files của slice (đã commit 2e49bd95)

- `godot-mindustry/src/game/SourceWeaponsCoreState.gd` (M — hàm canonical mới)
- `godot-mindustry/src/game/SourceWeaponsState.gd` (M — delegate)
- `tools/mindustry_godot_transpiler/tests/test_c07_weapon_draw_outline.py` (mới)
- `tools/mindustry_godot_transpiler/register_c07_weapon_draw_outline.py` (mới)
- `godot-mindustry/tools/runtime_proofs/C07WeaponDrawOutlineProof.gd` + `.tscn` (mới)
- SSOT (M — register main() đã ghi): `source_slice_ledger.json`,
  `source_symbol_registry.json`, `source_api_contracts.json`,
  `source_state_schema.json`, `source_ssot_modules.json`,
  `source_modules/type_slices.json`,
  `source_modules/type_api_contracts.json` (+ audit report nếu đổi —
  lần này audit report KHÔNG đổi; `source_ssot_modules.json` đổi:
  thêm `optional_mirror_fields: ["return_type"]` cho type_slices).
- KHÔNG stage: `*.gd.uid` / `project.godot` / `arc-upstream/` /
  `mindustry-upstream/` / proof `.json` (ignored) /
  `full-suite-*.log` / `hidden_files/` (untracked, đã có từ trước).

## Đã xong lượt này (lượt đóng slice, cron 23:15 +07)

1. Scope: KHẢ THI (drawOutline, ứng viên theo handoff N2536);
   worker lượt 22:00 scope + implement trên đĩa, main thread lượt
   22:00 xác minh Java trực tiếp (Weapon.java:196-213) — đúng scope,
   không BLOCKED.
2. GREEN: targeted 4/4 (35 subtests; lượt đóng slice chạy lại 16.78s,
   godot-bin trên PATH, port 7777 free lúc chạy — `ss` grep 7777 = 0
   trước khi chạy).
3. Proof matches:true (8/8 semantic keys + registry_valid +
   one_headquarter_per_ssot = 11/11 true, đọc trực tiếp
   C07WeaponDrawOutlineProof.json, mtime gốc lượt implement ~15:05Z
   — tái sinh 16:18Z bởi targeted re-run lượt đóng slice, nội dung
   không đổi).
4. Register `--verify` 27/27 (chạy lại lượt đóng slice: 9 exact exprs
   + 13 inputs + 5 outputs).
5. Chain neighbours + wiring + gate:
   NEIGHBOURS-EXIT 1 15:37:18Z (330 passed / 1 failed flake
   port-7777 — xem mục 6), WIRING-EXIT 0 15:39:24Z (32 OK),
   gate log mtime 16:08:59Z (Ran 6357, failures=266 toàn Godot-absent).
6. Flake neighbours: `test_c07_turret_controlled_stamp` fail duy nhất
   vì MCP autoload bind port 7777 (`Failed to start server on port
   7777: 22`), proof trong output matches:true — flake môi trường
   đã biết, KHÔNG phải regression. Chạy lại isolated module đó
   (godot-bin trên PATH, port 7777 free): 4 passed, 19 subtests,
   21.90s (log hidden_files/n2537-flake-rerun-mainverify.log) →
   neighbours thực chất SẠCH 331/331.
7. Gate phân rã theo FAIL block (lượt đóng slice, đọc trực tiếp
   full-suite-n2537-gate.log): 266 FAIL block, TẤT CẢ
   `AssertionError: unexpectedly None` (266 lần xuất hiện); 0
   KeyError, 0 `return_schema_linkage`, 0 ERROR; +4 tests / +1
   failure vs gate N2536, đúng mẫu — failure mới là
   test_reference_graph_and_actual_c07_weapon_draw_outline
   (Godot-absent vì gate chạy không có godot trên PATH); baseline
   hydration test_liquid_consumer_hydration là 1 FAIL block hằng số
   trong 266 (assertion `unexpectedly None : Godot required for
   hydration proof`).
8. `git diff --check` SẠCH (chạy lượt đóng slice, trước commit 1).

## Deferred / BLOCKED (không đổi sau N2537-scope)

- Unit draw call-site gọi `source_weapon_draw_outline_state` —
  DEFERRED (slice sau N2537): Unit draw / WeaponMount draw integration,
  chưa wire hàm mới vào đường draw live.
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

## Next sau N2537 (ứng viên theo thứ tự Weapon.java / UnitType.java, chưa scope)

- Tiếp tục theo thứ tự Weapon.java / UnitType.java; ứng viên cụ thể chưa
  scope — calculateHeat vẫn BLOCKED, findTarget BLOCKED.
- Sau đó tiếp tục theo thứ tự UnitType.java / Weapon.java; calculateHeat vẫn BLOCKED, findTarget BLOCKED.
