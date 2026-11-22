# Handoff — N2536 UnitType `weapons.sumf(Weapon::dps)`: wiring N2533→N2534 (C07) [DONE + PUSHED (slice 3a6481d9, docs TBA, GOAL TBA, status TBA)]

## Status: DONE + PUSHED (lượt cron 21:45 +07 ngày 2026-11-22; slice 3a6481d9, docs TBA, GOAL TBA, status TBA; push xong mới ghi origin/main ở đây sau khi push)

- N2535 DONE + PUSHED ~20:40 +07 ngày 2026-11-22, origin/main == a98557c4
  (5 commit: slice 7f61f2d8 + docs e05b904a + GOAL 57052a13 + status 52e4b6e5 + hashes a98557c4).
- N2536 DONE (slice 3a6481d9): targeted 4/4 (22 subtests, 17.28s, xác minh
  lại bởi lượt đóng slice, godot-bin trên PATH, port 7777
  free; lượt implement GREEN 4/4); register `--verify` 6/6;
  proof matches:true (8/8 semantic keys + registry_valid +
  one_headquarter_per_ssot = 11/11 true, đọc trực tiếp
  C07UnitTypeWeaponsDpsSumProof.json, mtime gốc 14:13Z — tái sinh
  14:48Z bởi targeted re-run lượt đóng slice, nội dung không đổi;
  chạy headless Godot 4.6.2 Linux trên VM, port 7777
  free trước khi chạy, không chạy song song với agent kia).
  Neighbours 327/327 SẠCH (NEIGHBOURS-EXIT 0 14:15:28Z, chain lượt 2
  launch main thread 13:57:10Z); wiring 32 OK (WIRING-EXIT 0
  14:17:32Z). Gate (log full-suite-n2536-gate.log): launch main
  thread 14:19:29Z, unittest PID 19978, log mtime 14:40:26Z —
  Ran 6353 trong 1254.682s, failures=265, skipped=5, errors=0,
  toàn Godot-absent (265 FAIL block, TẤT CẢ
  `AssertionError: unexpectedly None`, 265 lần xuất
  hiện đúng 1 lần/block; 0 KeyError, 0 return_schema_linkage,
  0 ERROR; +4 tests / +1 failure vs gate N2535, đúng mẫu).
  `git diff --check` SẠCH (lượt đóng slice).
- Neighbours + wiring: chain lượt 2 (main thread) —
  NEIGHBOURS-START 13:57:10Z → NEIGHBOURS-EXIT 0 14:15:28Z, 327
  passed (80 module tích lũy); WIRING-START 14:15:28Z →
  WIRING-EXIT 0 14:17:32Z, Ran 32 tests, OK. Chain lượt 1 chết
  ~60-90s sau launch (flake đã biết, log partial không còn trên
  đĩa lúc đóng slice). Gate chạy tiếp: launch 14:19:29Z → log mtime
  14:40:26Z.
- SSOT đo từ đĩa sau GREEN: 11732/1765/1698/3187 (symbols +1, Done +1,
  contracts +1, schemas +2 so với lúc đóng N2535: 11731/1764/1697/3185).
  Type shard 58/58 (+1/+1, N2536 vào type shard — java_source
  UnitType.java, tiền lệ N2533/N2534/N2535); comp giữ 572/475.
  Deferred pool 505 (502 + 3: 1 ghi weapons_dps_sum DONE + 1 nợ
  Windows + 1 C11 HUD/stats display đọc `weapons_dps_sum`
  DEFERRED). Lưu ý: handoff N2535 ghi pool 503 nhưng MEMORY.md
  ghi 502 (+3) — 503 đếm trùng Weapon.drawOutline() đã đếm ở
  N2534 (+4); 502 là số đúng, 505 = 502 + 3.

## Slice N2536 — scope đã chốt (UnitType.java:1136, wiring N2533→N2534)

- 1 pure function `source_unit_type_weapons_dps_sum_state(weapons_dps:
  Array)` trong
  `godot-mindustry/src/game/SourceUnitTypeState.gd:232` (sau
  `source_unit_type_estimate_dps_state`, TRƯỚC generated bridges),
  KHÔNG driver tick.
- Java (UnitType.java:1136):
  `dpsEstimate = weapons.sumf(Weapon::dps);`
  trong `public float estimateDps(){` (UnitType.java:1132-1144).
- `weapons` là `public Seq<Weapon> weapons = new Seq<>();`
  (UnitType.java:288). `weapons_dps` là Array float, một giá trị
  dps mỗi weapon, mỗi giá trị từ `source_weapon_dps_state`
  (N2534, Weapon.dps(), Weapon.java:188-190,
  `(bullet.estimateDPS() / reload) * shoot.shots * 60f`): hàm này
  KHÔNG gọi Weapon.dps() trực tiếp — gọi trực tiếp sẽ ép 13 bullet
  param vào signature UnitType (tiền lệ param-driven
  N2528/N2529/N2533).
- Tổng bắt đầu 0.0, nên weapons rỗng → 0.0 (arc Seq.sumf bắt đầu
  từ 0). Trả đúng 1 key `weapons_dps_sum` (tiền lệ N2526 — mọi
  return key đều là symbol).
- DORMANT live hôm nay: không caller nào đọc (N2533 vẫn nhận
  `weapons_dps_sum` làm float param; consumer gọi hàm tổng này rồi
  truyền vào `source_unit_type_estimate_dps_state` là slice sau;
  C11 HUD / stats display đọc `weapons_dps_sum` là slice sau).
- Proof 8 keys: weapons_dps_sum_empty (rỗng → 0.0) /
  weapons_dps_sum_single (60.0 → 60.0) /
  weapons_dps_sum_two (30.0 + 60.0 → 90.0) /
  weapons_dps_sum_fractional (12.5 + 25.0 → 37.5) /
  weapons_dps_sum_with_zero (0.0 + 45.0 → 45.0) /
  weapons_dps_sum_many (4 × 60.0 → 240.0) /
  weapons_dps_sum_large (500.0 + 500.0 → 1000.0) /
  weapons_dps_sum_small_fractions (0.5 + 0.25 + 0.25 → 1.0).

## Files của slice (đã commit 3a6481d9)

- `godot-mindustry/src/game/SourceUnitTypeState.gd` (M — hàm canonical mới)
- `tools/mindustry_godot_transpiler/tests/test_c07_unit_type_weapons_dps_sum.py` (mới)
- `tools/mindustry_godot_transpiler/register_c07_unit_type_weapons_dps_sum.py` (mới)
- `godot-mindustry/tools/runtime_proofs/C07UnitTypeWeaponsDpsSumProof.gd` + `.tscn` (mới)
- SSOT (M — register main() đã ghi): `source_slice_ledger.json`,
  `source_symbol_registry.json`, `source_api_contracts.json`,
  `source_state_schema.json`, `source_modules/type_slices.json`,
  `source_modules/type_api_contracts.json` (+ audit report nếu đổi —
  lần này audit report KHÔNG đổi).
- KHÔNG stage: `*.gd.uid` / `project.godot` / `arc-upstream/` /
  `mindustry-upstream/` / proof `.json` /
  `full-suite-*.log` / `hidden_files/` (untracked, đã có từ trước).

## Đã xong lượt này (worker đóng slice, lượt 21:45 +07)

1. Scope: KHẢ THI (wiring N2533→N2534, ứng viên theo handoff N2535);
   worker đóng slice xác minh lại trực tiếp trên đĩa: hàm ở
   SourceUnitTypeState.gd:232, Java UnitType.java:1136 + :288,
   `weapons_dps` là Array param (không gọi Weapon.dps() trực tiếp).
   Không BLOCKED.
2. GREEN: targeted 4/4 (22 subtests; lượt đóng slice chạy lại 17.28s,
   godot-bin trên PATH, port 7777 free lúc chạy — `ss` grep 7777 = 0
   trước khi chạy). Lưu ý: chạy lần đầu KHÔNG có godot trên PATH thì
   fail đúng 1 test reference-graph (`assertIsNotNone(godot)` →
   unexpectedly None) — đúng mẫu Godot-absent, không phải lỗi slice.
3. Proof matches:true (8/8 semantic keys + registry_valid +
   one_headquarter_per_ssot = 11/11 true, đọc trực tiếp
   C07UnitTypeWeaponsDpsSumProof.json, mtime gốc 14:13Z — tái sinh
   14:48Z bởi targeted re-run lượt đóng slice, nội dung không đổi).
4. Register `--verify` 6/6 (chạy lại lượt đóng slice).
5. Chain neighbours + wiring + gate (main thread launch):
   NEIGHBOURS-EXIT 0 14:15:28Z (327 passed, chain lượt 2 launch
   13:57:10Z), WIRING-EXIT 0 14:17:32Z (32 OK), gate log mtime
   14:40:26Z (Ran 6353, failures=265 toàn Godot-absent).
6. Gate phân rã theo FAIL block (lượt đóng slice, đọc trực tiếp
   full-suite-n2536-gate.log): 265 FAIL block, TẤT CẢ
   `AssertionError: unexpectedly None` (265 lần xuất hiện); 0
   KeyError, 0 `return_schema_linkage`, 0 ERROR; +4 tests / +1
   failure vs gate N2535, đúng mẫu — failure mới là
   test_reference_graph_and_actual_c07_unit_type_weapons_dps_sum
   (Godot-absent vì gate chạy không có godot trên PATH); baseline
   hydration test_liquid_consumer_hydration là 1 FAIL block hằng số.
7. `git diff --check` SẠCH (chạy lượt đóng slice, trước commit 1).

## Deferred / BLOCKED (không đổi sau N2536-scope)

- Consumer gọi `source_unit_type_weapons_dps_sum_state` rồi truyền
  vào `source_unit_type_estimate_dps_state` — DEFERRED (slice sau
  N2536): N2533 vẫn nhận `weapons_dps_sum` làm float param.
- C11 HUD / stats display đọc `weapons_dps_sum` — DEFERRED (slice
  sau): `addStats()` / UnitType stats hiển thị estimateDps, chưa
  wire vào hàm mới.
- Weapon.drawOutline() (Weapon.java:196+, `//TODO copy-pasted code`)
  — DEFERRED (slice sau, chưa scope): draw code, rendering nằm
  ngoài game — tiền lệ drawrot (N2532) và các draw slice trước.
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

## Next sau N2536 (ứng viên theo thứ tự Weapon.java, chưa scope)

- `Weapon.drawOutline()` (Weapon.java:196+, `//TODO copy-pasted code`): draw code, rendering nằm ngoài game — cần scope riêng (có thể DEFERRED như các draw slice trước).
- Sau đó tiếp tục theo thứ tự UnitType.java / Weapon.java; calculateHeat vẫn BLOCKED, findTarget BLOCKED.
