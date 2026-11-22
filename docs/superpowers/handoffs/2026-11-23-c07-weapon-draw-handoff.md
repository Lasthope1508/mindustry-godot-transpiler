# Handoff — N2538 Weapon.draw() (C07) [DONE + PUSHED (slice 20e10b76, docs 4cca5414, GOAL f4a494dd)]

## Status: DONE + PUSHED (lượt cron 01:30 +07 ngày 2026-11-23; slice 20e10b76, docs 4cca5414, GOAL f4a494dd; push xong mới ghi origin/main ở đây sau khi push)

- N2537 DONE + PUSHED ~23:26 +07 ngày 2026-11-22, origin/main == 09a3a961
  (5 commit: slice 2e49bd95 + docs 36afca58 + GOAL 1fab1442 + status e4360200 + hashes 09a3a961).
- N2538 DONE (slice 20e10b76): targeted 4/4 (60 subtests, 34.73s lượt đóng
  slice, xác minh lại bởi main thread; lượt implement 17.75s, lượt 00:15
  re-run main thread 17.34s); register `--verify` 52/52 (18 exact exprs
  + 21 inputs + 13 outputs, chạy lại lượt đóng slice); proof
  matches:true (8/8 semantic keys + registry_valid +
  one_headquarter_per_ssot = 11/11 true, đọc trực tiếp
  C07WeaponDrawProof.json, tái sinh 18:32Z bởi targeted re-run lượt
  đóng slice, nội dung không đổi; chạy headless Godot 4.6.2 Linux trên
  VM, port 7777 free trước khi chạy, không chạy song song với agent
  kia). Neighbours 335/335 SẠCH (NEIGHBOURS-EXIT 0 17:06:05Z, 335
  passed trong 1131.09s, gồm test_c07_weapon_draw.py 4/4); wiring 32
  OK (WIRING-EXIT 0 17:08:11Z, Ran 32 tests trong 126.443s). Gate
  (log full-suite-n2538-gate.log): lượt 1 GATE-START 17:18:09Z chết do
  VM restart ~17:33Z (log dở đã backup
  hidden_files/n2538-gate-partial-killed-by-restart.log; javalang +
  pytest bị xóa, đã cài lại 0.13.0 / 9.2.0); lượt 2 GATE-START
  17:46:30Z main thread, unittest PID 2903, GATE-EXIT 1 18:24:26Z —
  Ran 6361 trong 2274.109s, failures=267, skipped=5, errors=0, toàn
  Godot-absent (267 FAIL block, TẤT CẢ `AssertionError: unexpectedly
  None`, 267 lần xuất hiện đúng 1 lần/block; 0 KeyError, 0
  return_schema_linkage, 0 ERROR; +4 tests / +1 failure vs gate
  N2537, đúng mẫu). `git diff --check` SẠCH (lượt đóng slice, trước
  commit 1).
- Neighbours + wiring: chain lượt duy nhất (main thread) —
  NEIGHBOURS-START 16:47:13Z → NEIGHBOURS-EXIT 0 17:06:05Z, 335 passed
  / 0 failed (331 module tích lũy + test_c07_weapon_draw.py = 335
  items); WIRING-START 17:06:05Z → WIRING-EXIT 0 17:08:11Z, Ran 32
  tests, OK. Gate lượt 2 chạy tiếp: launch 17:46:30Z → log mtime
  18:24:26Z (main-thread launch, sống tới EXIT; chậm hơn mức ~21
  phút của các gate N2534–N2537 — 2274.109s ≈ 38 phút — nhưng log
  tăng đều, CPU ~99%, không restart mới trong lượt).
- SSOT đo từ đĩa sau GREEN: 11750/1767/1700/3191 (symbols +13, Done
  +1, contracts +1, schemas +2 so với lúc đóng N2537:
  11737/1766/1699/3189). Type shard 60/60 (+1/+1, N2538 vào type
  shard — java_source Weapon.java, tiền lệ N2533-N2537); comp giữ
  572/475. Deferred pool 512 (508 + 4: 1 ghi Weapon.draw() DONE + 1
  nợ Windows + 2 DEFERRED: per-part DrawPart drawing, Unit draw
  call-site gọi draw()).

## Slice N2538 — scope đã chốt (Weapon.java:212-286, draw())

- 1 pure function `source_weapon_draw_state(z: float, unit_rotation:
  float, unit_x: float, unit_y: float, mount_recoil: float,
  mount_rotation: float, rotate: bool, base_rotation: float, recoil:
  float, recoil_pow: float, weapon_x: float, weapon_y: float,
  flip_sprite: bool, shadow: float, top: bool, region_found: bool,
  cell_region_found: bool, heat_region_found: bool, mount_heat:
  float, layer_offset: float, parts_count: int) -> Dictionary` trong
  `godot-mindustry/src/game/SourceWeaponsCoreState.gd:177` (sau
  `source_weapon_draw_outline_state`, trước `set_rotation_state`),
  + 1 delegate cùng tên trong `SourceWeaponsState.gd:185-186`,
  KHÔNG driver tick.
- Java (Weapon.java:212-286):
  `public void draw(Unit unit, WeaponMount mount){` /
  `float z = Draw.z();` / `Draw.z(z + layerOffset);` /
  `rotation = unit.rotation - 90,` /
  `realRecoil = Mathf.pow(mount.recoil, recoilPow) * recoil,` /
  `weaponRotation  = rotation + (rotate ? mount.rotation : baseRotation),` /
  `wx = unit.x + Angles.trnsx(rotation, x, y) + Angles.trnsx(weaponRotation, 0, -realRecoil),` /
  `wy = unit.y + Angles.trnsy(rotation, x, y) + Angles.trnsy(weaponRotation, 0, -realRecoil);` /
  `if(shadow > 0){ Drawf.shadow(wx, wy, shadow); }` /
  `if(top){ drawOutline(unit, mount); }` /
  `if(parts.size > 0){ ... DrawPart ... }` /
  `Draw.xscl *= -Mathf.sign(flipSprite);` /
  `if(region.found()) Draw.rect(region, wx, wy, weaponRotation);` /
  `if(cellRegion.found()){ ... }` /
  `if(heatRegion.found() && mount.heat > 0){ ... }` /
  `Draw.z(z);`
- Dòng Java đã xác minh trực tiếp (lượt đóng slice đọc Weapon.java):
  z :214, z+layer :215, rotation :218, realRecoil :219,
  weaponRotation :220, wx :221, wy :222, shadow :224, top :228,
  drawOutline :229, parts :232/:271, xscl*= :248, region :253, cell
  :255, heat :261, Draw.z(z) :285. Fields (Weapon.java): shadow=-1f
  (:99), top=true (:51), flipSprite=false (:41), rotate=false (:45),
  baseRotation=0f (:49), recoil=1.5f (:81), recoilPow=1.8f (:87),
  x=5f, y=0f (:93), layerOffset=0f (:127), parts (:160-161). Mount
  fields (WeaponMount.java): rotation (:14), recoil (:16), heat (:22).
- draw() KHÔNG có early return (khác drawOutline): mọi nhánh trả đủ
  13 key (rotation, real_recoil, weapon_rotation, wx, wy, xscl,
  z_draw, shadow_drawn, outline_called, has_parts, region_drawn,
  cell_drawn, heat_drawn). `z_draw` = z + layerOffset (:215);
  `shadow_drawn` = shadow > 0 (:224); `outline_called` = top (:228 —
  body drawOutline đã là N2537, ở đây chỉ trả flag);
  `has_parts` = parts_count > 0 (:232 — per-part DrawPart drawing là
  slice sau, KHÔNG port ở đây); `xscl` = -Mathf.sign(flipSprite)
  (arc Mathf.java:203-205); `region_drawn` = region_found (:253);
  `cell_drawn` = cell_region_found (:255); `heat_drawn` =
  heat_region_found AND mount_heat > 0 (:261). `Draw.z(z);` cuối
  (:285) chỉ là restore render-state, không phải return value.
  cellColor / heatColor / applyColor là render-only, không return
  key.
- LƯU Ý brief: brief ghi "14 return keys" nhưng chỉ liệt kê 13 key
  (rotation, real_recoil, weapon_rotation, wx, wy, xscl, z_draw,
  shadow_drawn, outline_called, has_parts, region_drawn, cell_drawn,
  heat_drawn). Slice port đúng 13 key đã liệt kê, KHÔNG phát minh
  key thứ 14 — register docstring đã ghi rõ.
- `Angles.trnsx/trnsy(angle, x, y)` tái dùng `source_angles_trns_vec`
  có sẵn (SourceMathState.gd:140-147) gọi 2 lần (base offset + recoil
  offset), không phát minh port scalar mới.
- DORMANT live hôm nay: draw code, rendering nằm ngoài game, không
  caller nào đọc (call-site Unit draw gọi draw() là slice sau).
- Proof 8 keys: draw_java_defaults (defaults Java → rotation 0.0,
  real_recoil 0.0, weapon_rotation 0.0, (5.0, 0.0), xscl 1.0, z_draw
  0.0, shadow_drawn false, outline_called true, has_parts false,
  region_drawn true, cell_drawn false, heat_drawn false) /
  draw_shadow (shadow 10 → shadow_drawn true, (5.0, 0.0)) /
  draw_top_false (top false → outline_called false) /
  draw_region_not_found (region_found false → region_drawn false,
  geometry vẫn (5.0, 0.0)) / draw_cell (cell_region_found true →
  cell_drawn true) / draw_heat_zero (heat_region_found true,
  mount_heat 0 → heat_drawn false) / draw_heat_positive
  (heat_region_found true, mount_heat 0.5 → heat_drawn true) /
  draw_unit_rot_180 (unit_rotation 180 → rotation 90.0, (0.0, 5.0),
  weapon_rotation 90.0).

## Files của slice (đã commit 20e10b76)

- `godot-mindustry/src/game/SourceWeaponsCoreState.gd` (M — hàm canonical mới, +86)
- `godot-mindustry/src/game/SourceWeaponsState.gd` (M — delegate, +3)
- `tools/mindustry_godot_transpiler/tests/test_c07_weapon_draw.py` (mới)
- `tools/mindustry_godot_transpiler/register_c07_weapon_draw.py` (mới)
- `godot-mindustry/tools/runtime_proofs/C07WeaponDrawProof.gd` + `.tscn` (mới)
- SSOT (M — register main() đã ghi): `source_slice_ledger.json`,
  `source_symbol_registry.json`, `source_api_contracts.json`,
  `source_state_schema.json`, `source_modules/type_slices.json`,
  `source_modules/type_api_contracts.json` (audit report KHÔNG đổi;
  `source_ssot_modules.json` KHÔNG đổi — type shard đã đăng ký từ
  trước, không shard mới).
- KHÔNG stage: `*.gd.uid` / `project.godot` / `arc-upstream/` /
  `mindustry-upstream/` / proof `.json` (ignored) /
  `full-suite-*.log` / `hidden_files/` (untracked, đã có từ trước).

## Đã xong lượt này (lượt đóng slice, cron 01:30 +07)

1. Scope: KHẢ THI (draw(), ứng viên theo handoff N2537);
   worker lượt 23:45 scope + implement trên đĩa, main thread lượt
   23:45 xác minh Java trực tiếp (Weapon.java:212-286) — đúng scope,
   không BLOCKED; lượt đóng slice đọc lại Weapon.java:212-286, mọi
   citation dòng khớp.
2. GREEN: targeted 4/4 (60 subtests; lượt đóng slice chạy lại 34.73s,
   godot-bin trên PATH, port 7777 free lúc chạy — `ss` grep 7777 = 0
   trước khi chạy; lượt implement 17.75s, lượt 00:15 re-run main
   thread 17.34s).
3. Proof matches:true (8/8 semantic keys + registry_valid +
   one_headquarter_per_ssot = 11/11 true, đọc trực tiếp
   C07WeaponDrawProof.json — tái sinh 18:32Z bởi targeted re-run
   lượt đóng slice, nội dung không đổi).
4. Register `--verify` 52/52 (chạy lại lượt đóng slice: 18 exact
   exprs + 21 inputs + 13 outputs).
5. Chain neighbours + wiring + gate:
   NEIGHBOURS-EXIT 0 17:06:05Z (335 passed / 0 failed, 1131.09s),
   WIRING-EXIT 0 17:08:11Z (32 OK, 126.443s), gate lượt 2
   GATE-EXIT 1 18:24:26Z (Ran 6361, failures=267 toàn Godot-absent).
6. Gate lượt 1 chết do VM restart ~17:33Z (uptime 12 phút lúc
   17:45Z; chain.log có GATE-START 17:18:09Z nhưng KHÔNG có
   GATE-EXIT; log gate dừng ở 6034 bytes, chưa có summary
   Ran/FAIL block; log dở đã backup
   hidden_files/n2538-gate-partial-killed-by-restart.log).
   Restart này XÓA javalang + pytest (khác restart #18) — đã cài lại
   javalang 0.13.0 + pytest 9.2.0 theo RULE trước khi relaunch gate.
   Gate lượt 2 relaunch main thread GATE-START 17:46:30Z, unittest
   PID 2903; survival-check ~57s sau launch: PID còn sống, 95.7%
   CPU, log đang tăng — qua cửa 60s (lesson N2523).
7. Gate phân rã theo FAIL block (lượt đóng slice, đọc trực tiếp
   full-suite-n2538-gate.log): 267 FAIL block, TẤT CẢ
   `AssertionError: unexpectedly None` (267 lần xuất hiện); 0
   KeyError, 0 `return_schema_linkage`, 0 ERROR; +4 tests / +1
   failure vs gate N2537, đúng mẫu — failure mới là
   test_reference_graph_and_actual_c07_weapon_draw
   (Godot-absent vì gate chạy không có godot trên PATH); baseline
   hydration test_liquid_consumer_hydration là 1 FAIL block hằng số
   trong 267 (assertion `unexpectedly None : Godot required for
   hydration proof`).
8. `git diff --check` SẠCH (lượt đóng slice, trước commit 1).

## Deferred / BLOCKED (không đổi sau N2538-scope)

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
- N2537 citation nit (KHÔNG sửa lượt này): comment drawOutline trong
  SourceWeaponsCoreState.gd ghi "Weapon.java:227-229" cho `if(top){
  drawOutline(unit, mount); }`, dòng đúng là 228-229. Để nguyên
  (text của N2537).

## Next sau N2538 (ứng viên theo thứ tự Weapon.java / UnitType.java, chưa scope)

- Tiếp tục theo thứ tự Weapon.java / UnitType.java; ứng viên cụ thể chưa
  scope — Weapon.range() (Weapon.java:288) là method tiếp theo sau
  draw() trong Weapon.java; Weapon.update() (Weapon.java:292) là tick
  method lớn, cần scope riêng. calculateHeat vẫn BLOCKED, findTarget BLOCKED.
- Sau đó tiếp tục theo thứ tự UnitType.java / Weapon.java; calculateHeat vẫn BLOCKED, findTarget BLOCKED.
