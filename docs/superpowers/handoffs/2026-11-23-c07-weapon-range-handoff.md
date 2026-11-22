# Handoff — N2539 Weapon.range() (C07) [DONE + PUSHED (slice 19b5a529, docs 52c1fb98, GOAL b9692e87)]

## Status: DONE + PUSHED (lượt cron 03:15 +07 ngày 2026-11-23; slice 19b5a529, docs 52c1fb98, GOAL b9692e87; push xong mới ghi origin/main ở đây sau khi push)

- N2538 DONE + PUSHED ~01:30 +07 ngày 2026-11-23, origin/main == 0cc82b4c
  (5 commit: slice 20e10b76 + docs 4cca5414 + GOAL f4a494dd + status c85ac1ce + hashes 0cc82b4c).
- N2539 DONE (slice 19b5a529): targeted 4/4 (12 subtests, 17.16s lượt đóng
  slice, xác minh lại bởi main thread; lượt implement 28.868s);
  register `--verify` 4/4 (2 exact exprs + 1 input + 1 output, chạy lại
  lượt đóng slice); proof matches:true (4/4 semantic keys +
  registry_valid + one_headquarter_per_ssot = 7/7 true, đọc trực tiếp
  C07WeaponRangeProof.json, tái sinh 20:18Z bởi targeted re-run lượt
  đóng slice, nội dung không đổi; chạy headless Godot 4.6.2 Linux trên
  VM, port 7777 free trước khi chạy, không chạy song song với agent
  kia). Neighbours 339/339 SẠCH (NEIGHBOURS-EXIT 0 19:36:25Z, 339
  passed trong 1152.55s, gồm test_c07_weapon_range.py 4/4); wiring 32
  OK (WIRING-EXIT 0 19:38:28Z, Ran 32 tests trong 123.514s). Gate
  (log full-suite-n2539-gate.log): GATE-START 19:46:06Z main thread,
  GATE-EXIT 1 20:07:43Z — Ran 6365 trong 1295.771s, failures=268,
  skipped=5, errors=0, toàn Godot-absent (268 FAIL block, TẤT CẢ
  `AssertionError: unexpectedly None`, 268 lần xuất hiện đúng 1
  lần/block; 0 KeyError, 0 `return_schema_linkage`, 0 ERROR; +4 tests /
  +1 failure vs gate N2538, đúng mẫu). `git diff --check` SẠCH (lượt
  đóng slice, trước commit 1).
- Chain lượt 1 chết do VM restart #31 ~02:08 +07 (PID1 đổi 02:08:06,
  chết ~40% neighbours); chain lượt 2 relaunch main thread 19:17:12Z,
  survival-check ~100s sau launch còn sống — qua cửa 60s (lesson
  N2523). Restart #31 có wipe javalang/pytest — đã cài lại 0.13.0 /
  9.2.0 theo RULE trước khi relaunch chain (ghi theo MEMORY).

## Slice N2539 — scope đã chốt (Weapon.java:288-290, range())

- 1 pure function `source_weapon_range_state(bullet_range: float) -> Dictionary`
  trong `godot-mindustry/src/game/SourceWeaponsCoreState.gd` (sau
  `source_weapon_draw_state`, trước `set_rotation_state`),
  + 1 delegate cùng tên trong `SourceWeaponsState.gd`,
  KHÔNG driver tick.
- Java (Weapon.java:288-290):
  `public float range(){` / `return bullet.range;` / `}`.
  `bullet` là weapon bullet type (`public BulletType bullet =
  Bullets.placeholder;`, Weapon.java:33); `bullet.range` là
  BulletType range field (`public float range = 0f;`,
  BulletType.java:161), computed bởi calculateRange() ở init
  (BulletType.java:854) và afterPatch (BulletType.java:402).
  calculateRange() (BulletType.java:433-439) ĐÃ port từ trước
  (SourceBulletTypeInitRangeState.gd: `if(rangeOverride > 0)
  return rangeOverride;` / spawnUnit leg / despawnUnit leg /
  drag fallback `Math.max(Mathf.zero(drag) ? speed * lifetime :
  speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag,
  maxRange)`) — slice này KHÔNG port lại calculateRange, chỉ
  lấy catalog `bullet.range` làm 1 input param (tiền lệ N2533:
  dps() lấy `bullet_estimate_dps` làm float param) và trả
  nguyên vẹn 1 key `{"range": bullet_range}`.
- Placeholder post-init range = 150.0 (đã xác minh: Bullets.placeholder
  là BasicBulletType(2.5f, 9, "ohno") với lifetime 60f;
  BulletType defaults drag 0f (:49), maxRange -1f (:153), lifetime
  40f (:33), speed 1f (:37) — calculateRange: drag 0 →
  speed * lifetime = 2.5 * 60 = 150, max(150, -1) = 150).
- DORMANT live hôm nay: range() là catalog read, không caller nào
  đọc hôm nay (UnitType.init range/maxRange và Weapon.update
  shootLength là consumer slice sau).
- Proof 4 keys: range_zero (0.0 → 0.0, field default) /
  range_placeholder (150.0 → 150.0) / range_fractional (37.5 →
  37.5) / range_large (1000.0 → 1000.0).

## Files của slice (trên đĩa, CHƯA commit)

- `godot-mindustry/src/game/SourceWeaponsCoreState.gd` (M — hàm canonical mới)
- `godot-mindustry/src/game/SourceWeaponsState.gd` (M — delegate)
- `tools/mindustry_godot_transpiler/tests/test_c07_weapon_range.py` (mới)
- `tools/mindustry_godot_transpiler/register_c07_weapon_range.py` (mới)
- `godot-mindustry/tools/runtime_proofs/C07WeaponRangeProof.gd` + `.tscn` (mới)
- SSOT (M — register main() đã ghi): `source_slice_ledger.json`,
  `source_symbol_registry.json`, `source_api_contracts.json`,
  `source_state_schema.json`, `source_modules/type_slices.json`,
  `source_modules/type_api_contracts.json` (audit report KHÔNG đổi;
  `source_ssot_modules.json` KHÔNG đổi — type shard đã đăng ký từ
  trước, không shard mới).
- KHÔNG stage: `*.gd.uid` / `project.godot` / `arc-upstream/` /
  `mindustry-upstream/` / proof `.json` (ignored) /
  `full-suite-*.log` / `hidden_files/` (untracked, đã có từ trước).

## Đã xong lượt này (lượt cron 01:45 +07 scope + implement; lượt cron 03:15 +07 đóng slice)

1. Scope: KHẢ THI (range(), ứng viên theo handoff N2537/N2538);
   đọc trực tiếp Weapon.java:288-290, BulletType.java:33/49/153/161/
   402/433-439/854, Bullets.java:18-23, UnitType.java:971-989,
   Weapon.java:391 — mọi citation dòng khớp.
2. RED: targeted 4 tests → 2 failures + 2 errors (signature chưa có,
   ledger chưa có N2539, proof .gd/.tscn chưa có) — đúng trạng thái RED.
3. GREEN: targeted 4/4 (28.868s lượt implement, 12 subtests; lượt đóng
   slice chạy lại 17.16s, godot-bin trên PATH, port 7777 free lúc chạy
   — `ss` grep 7777 = 0 trước khi chạy).
4. Proof matches:true (4/4 semantic keys + registry_valid +
   one_headquarter_per_ssot = 7/7 true, đọc trực tiếp
   C07WeaponRangeProof.json — tái sinh 20:18Z bởi targeted re-run
   lượt đóng slice, nội dung không đổi; chạy headless Godot 4.6.2
   Linux trên VM, port 7777 free trước khi chạy, không chạy song song
   với agent kia).
5. Register `--verify` 4/4 (2 exact exprs + 1 input + 1 output, chạy
   lại lượt đóng slice).
6. `git diff --check` SẠCH (lượt đóng slice, trước commit 1).
7. SSOT đo từ đĩa sau GREEN: 11751/1768/1701/3193 (symbols +1, Done
   +1, contracts +1, schemas +2 so với lúc đóng N2538:
   11750/1767/1700/3191). Type shard 61/61 (+1/+1, N2539 vào type
   shard — java_source Weapon.java, tiền lệ N2533-N2538); comp giữ
   572/475. Deferred pool 515 (512 + 3: 1 ghi Weapon.range() DONE +
   1 nợ Windows + 1 consumers DEFERRED). SSOT đo lại từ đĩa lượt đóng
   slice: symbols 11751, ledger 1768 entries (tất cả done, N2539
   status done), contracts 1701, schemas 3193, type 61/61 — khớp.
8. Chain neighbours + wiring + gate (main thread):
   NEIGHBOURS-EXIT 0 19:36:25Z (339 passed / 0 failed, 1152.55s, gồm
   test_c07_weapon_range.py 4/4), WIRING-EXIT 0 19:38:28Z (32 OK,
   123.514s), GATE-START 19:46:06Z, GATE-EXIT 1 20:07:43Z (Ran 6365,
   failures=268 toàn Godot-absent).
9. Chain lượt 1 (NEIGHBOURS-START 18:52:45Z) chết do VM restart #31
   ~02:08 +07 (chain.log có RELAUNCH nhưng KHÔNG có NEIGHBOURS-EXIT
   lượt 1, chết ~40% neighbours). Restart này XÓA javalang + pytest
   (khác restart #18) — đã cài lại javalang 0.13.0 + pytest 9.2.0
   theo RULE trước khi relaunch. Chain lượt 2 relaunch main thread
   19:17:12Z; survival-check ~100s sau launch còn sống — qua cửa 60s
   (lesson N2523).
10. Gate phân rã theo FAIL block (lượt đóng slice, đọc trực tiếp
    full-suite-n2539-gate.log): 268 FAIL block, TẤT CẢ
    `AssertionError: unexpectedly None` (268 lần xuất hiện, đúng 1
    lần/block); 0 KeyError, 0 `return_schema_linkage`, 0 ERROR; +4
    tests / +1 failure vs gate N2538, đúng mẫu — failure mới là
    test_reference_graph_and_actual_c07_weapon_range
    (Godot-absent vì gate chạy không có godot trên PATH); baseline
    hydration test_liquid_consumer_hydration là 1 FAIL block hằng số
    trong 268 (assertion `unexpectedly None : Godot required for
    hydration proof`).

## Còn lại để đóng slice (lượt đóng slice, cron 03:15 +07)

- Spec + GOAL §5 (dòng nợ Windows) + status commit, rồi 5 commit
  theo mẫu N2537/N2538 (slice 19b5a529 + docs + GOAL + status +
  hashes) và push origin main — gate đã xanh (toàn Godot-absent).

## Deferred / BLOCKED (không đổi sau N2539-scope)

- UnitType.init range / maxRange consumer — DEFERRED (slice sau
  N2539): UnitType.java:971-989, `range = Math.min(range,
  weapon.range() - margin);` / `maxRange = Math.max(maxRange,
  weapon.range() - margin);` với margin 4f, gated trên
  `weapon.useAttackRange`; `maxRange = Math.max(0f, range)` khi
  maxRange < 0.
- Weapon.update shootLength laser clamp consumer — DEFERRED (slice
  sau N2539): Weapon.java:391, `float shootLength =
  Math.min(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY),
  range());` (nằm trong update() — tick method lớn, cần scope
  riêng).
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

## Next sau N2539 (ứng viên theo thứ tự Weapon.java / UnitType.java, chưa scope)

- N2539 đóng xong lượt cron 03:15 +07 ngày 2026-11-23 (slice 19b5a529,
  neighbours 339/339, wiring 32 OK, gate Ran 6365 / failures 268 toàn
  Godot-absent, push origin main sau 5 commit theo mẫu N2537/N2538).
- Sau đó tiếp tục theo thứ tự Weapon.java / UnitType.java; ứng viên
  cụ thể chưa scope — Weapon.update() (Weapon.java:292) là tick
  method lớn, cần scope riêng (gồm retarget/findTarget BLOCKED,
  shootLength dùng range() — N2539 vừa xong, checkTarget, predict).
  calculateHeat vẫn BLOCKED, findTarget BLOCKED.
