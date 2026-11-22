# Handoff — N2540 Weapon.update() leg 1 (C07) [DONE + PUSHED (slice 27a829fe, docs TBD, GOAL TBD, status TBD)]

## Status: DONE + PUSHED (lượt cron 05:15 +07 ngày 2026-11-23; slice 27a829fe, docs TBD, GOAL TBD, status TBD; push xong mới ghi origin/main ở đây sau khi push)

- N2539 DONE + PUSHED ~03:15 +07 ngày 2026-11-23, origin/main == c485a98e
  (5 commit: slice 19b5a529 + docs 52c1fb98 + GOAL b9692e87 + status c454b220 + hashes c485a98e).
- N2540 DONE (slice 27a829fe): targeted 4/4 (43 subtests, 16.72s lượt đóng
  slice, xác minh lại bởi main thread; lượt implement 17.97s);
  register `--verify` 35/35 (9 exact exprs + 20 input + 6 output, chạy lại
  lượt đóng slice); proof matches:true (11/11 semantic keys +
  registry_valid + one_headquarter_per_ssot + matches = 14/14 true, đọc
  trực tiếp C07WeaponUpdateDecayProof.json, tái sinh 22:16Z bởi targeted
  re-run lượt đóng slice, nội dung không đổi; chạy headless Godot 4.6.2
  Linux trên VM, port 7777 free trước khi chạy, không chạy song song với
  agent kia). Neighbours 343/343 SẠCH (NEIGHBOURS-EXIT 0 21:35:40Z, 343
  passed trong 1148.51s, gồm test_c07_weapon_update_decay.py 4/4); wiring
  32 OK (WIRING-EXIT 0 21:37:46Z, Ran 32 tests trong 126.274s). Gate
  (log full-suite-n2540-gate.log): GATE-START 21:47:54Z lượt 2 main thread,
  GATE-EXIT 1 22:09:06Z — Ran 6369 trong 1270.210s, failures=269,
  skipped=5, errors=0, toàn Godot-absent (269 FAIL block, TẤT CẢ
  `AssertionError: unexpectedly None`, 269 lần xuất hiện đúng 1
  lần/block; 0 KeyError, 0 `return_schema_linkage`, 0 ERROR; +4 tests /
  +1 failure vs gate N2539, đúng mẫu). `git diff --check` SẠCH (lượt
  đóng slice, trước commit 1).
- Chain lượt 1 (NEIGHBOURS-START 20:55:11Z) chết do VM restart #32 ~21:11Z
  (uptime 1:07 lúc 22:18Z → boot ~21:11Z; chain.log có NEIGHBOURS-START
  lượt 2 21:16:31Z nhưng KHÔNG có NEIGHBOURS-EXIT lượt 1). Restart #32
  KHÔNG wipe javalang/pytest (khác restart #31 — javalang import OK,
  pytest 9.2.0 vẫn chạy, không cần cài lại). Chain lượt 2 relaunch main
  thread 21:16:31Z, sống qua cửa 60s (lesson N2523). Gate lượt 1
  (GATE-START 21:45:52Z) chết sớm ~2 phút, nguyên nhân chưa rõ từ log
  (không restart ở thời điểm đó); gate lượt 2 chạy đủ tới EXIT.

## Slice N2540 — scope đã chốt (Weapon.java:293-306, update() leg 1)

- 1 pure function `source_weapon_update_decay_state` (20 params, 6 return
  keys `reload, recoil, recoils, smooth_reload, charge, warmup`) trong
  `godot-mindustry/src/game/SourceWeaponsCoreState.gd:287` (sau
  `source_weapon_range_state`, trước `set_rotation_state`),
  + 1 delegate cùng tên trong `SourceWeaponsState.gd:191-192`,
  KHÔNG driver tick.
- Java (Weapon.java:293-306):
  `boolean can = unit.canShoot();` / `float lastReload = mount.reload;` /
  `mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);` /
  `mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime);` /
  `if(recoils > 0){ if(mount.recoils == null) mount.recoils = new float[recoils]; for(int i = 0; i < recoils; i++){ mount.recoils[i] = Mathf.approachDelta(mount.recoils[i], 0, unit.reloadMultiplier / recoilTime); } }` /
  `mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed);` /
  `mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0;` /
  `float warmupTarget = (can && mount.shoot) || (continuous && mount.bullet != null) || mount.charging ? 1f : 0f;` /
  `if(linearWarmup){ mount.warmup = Mathf.approachDelta(mount.warmup, warmupTarget, shootWarmupSpeed); }else{ mount.warmup = Mathf.lerpDelta(mount.warmup, warmupTarget, shootWarmupSpeed); }`.
  Mount fields theo WeaponMount.java:12/16/18/30/28/26/34/24/47; array
  rỗng = Java `mount.recoils == null`; `recoils` = barrel count
  (`public int recoils = -1;`, Weapon.java:83); `recoilTime` =
  `public float recoilTime = -1f;` (Weapon.java:85, truyền nguyên KHÔNG
  clamp); `weapon_reload` = `public float reload = 1;` (Weapon.java:75);
  `smoothReloadSpeed = 0.15f, shootWarmupSpeed = 0.1f`
  (Weapon.java:111); `firstShotDelay` (ShootPattern.java:11);
  `linearWarmup` (Weapon.java:113); `continuous` (Weapon.java:53);
  `can` là frame bool `unit.canShoot()` lấy làm input (canShoot() không
  port lại); `source_delta` = Time.delta, `reload_multiplier` =
  unit.reloadMultiplier. Bẫy: smoothReload lerp về reload' / reload
  (đã decay), lastReload KHÔNG trả (side-flip leg :427-432 là slice sau),
  charge else = đúng 0.
- DORMANT live hôm nay: update() chưa có driver trong port, không caller
  nào đọc (driver update() tick là slice sau) → live behavior KHÔNG đổi.
- Proof 11 keys: reload_decay (30→29) / reload_clamp (0.5→0) /
  recoil_approach (1.0→0.95) / recoils_alloc ([]→[0,0]) /
  recoils_decay ([0.5,0.25]→[0.4,0.15]) / recoils_ignored (recoils −1,
  [0.7] nguyên vẹn) / smooth_reload (0.0725 — reload' 29/60) /
  charge_charging (1/30) / charge_else_zero (0.8→0) /
  warmup_approach (0.5→0.6) / warmup_lerp (0.8→0.72).

## Files của slice (đã commit 27a829fe)

- `godot-mindustry/src/game/SourceWeaponsCoreState.gd` (M — hàm canonical mới)
- `godot-mindustry/src/game/SourceWeaponsState.gd` (M — delegate)
- `tools/mindustry_godot_transpiler/tests/test_c07_weapon_update_decay.py` (mới)
- `tools/mindustry_godot_transpiler/register_c07_weapon_update_decay.py` (mới)
- `godot-mindustry/tools/runtime_proofs/C07WeaponUpdateDecayProof.gd` + `.tscn` (mới)
- SSOT (M — register main() đã ghi): `source_slice_ledger.json`,
  `source_symbol_registry.json`, `source_api_contracts.json`,
  `source_state_schema.json`, `source_modules/type_slices.json`,
  `source_modules/type_api_contracts.json` (audit report KHÔNG đổi;
  `source_ssot_modules.json` KHÔNG đổi — type shard đã đăng ký từ
  trước, không shard mới).
- KHÔNG stage: `*.gd.uid` / `project.godot` / `arc-upstream/` /
  `mindustry-upstream/` / proof `.json` (ignored) /
  `full-suite-*.log` / `hidden_files/` (untracked, đã có từ trước).

## Đã xong lượt này (lượt cron 03:45 +07 scope + implement; lượt cron 05:15 +07 đóng slice)

1. Scope: KHẢ THI (update() leg 1, ứng viên theo handoff N2539);
   đọc trực tiếp Weapon.java:292-306 + WeaponMount.java, scoping ghi
   trong hidden_files/n2540-scoping.md — mọi citation dòng khớp.
2. RED: targeted 4 tests → 4 failures (KeyError `N2540` / chưa có
   function / chưa có proof) — đúng trạng thái RED.
3. GREEN: targeted 4/4 (17.97s lượt implement, 43 subtests; lượt đóng
   slice chạy lại 16.72s, godot-bin trên PATH, port 7777 free lúc chạy
   — `ss` grep 7777 = 0 trước khi chạy).
4. Proof matches:true (11/11 semantic keys + registry_valid +
   one_headquarter_per_ssot + matches = 14/14 true, đọc trực tiếp
   C07WeaponUpdateDecayProof.json — tái sinh 22:16Z bởi targeted re-run
   lượt đóng slice, nội dung không đổi; chạy headless Godot 4.6.2
   Linux trên VM, port 7777 free trước khi chạy, không chạy song song
   với agent kia).
5. Register `--verify` 35/35 (9 exact exprs + 20 inputs + 6 outputs,
   chạy lại lượt đóng slice). Lượt register đầu fail (`ValueError:
   source-backed requires java_method`) do thiếu `java_method=method`
   trong symbols dict; đã sửa và chạy lại sạch — SSOT cuối đo từ đĩa
   khớp dự kiến, lần chạy 2 ghi đè idempotent, không trùng lặp (ledger
   N2540 đúng 6 symbols).
6. `git diff --check` SẠCH (lượt đóng slice, trước commit 1).
7. SSOT đo từ đĩa sau GREEN: 11757/1769/1702/3195 (symbols +6, Done
   +1, contracts +1, schemas +2 so với lúc đóng N2539:
   11751/1768/1701/3193). Type shard 62/62 (+1/+1, N2540 vào type
   shard — java_source Weapon.java, tiền lệ N2533-N2539); comp giữ
   572/475. Deferred pool 518 (515 + 3: 1 ghi Weapon.update() leg 1
   DONE + 1 nợ Windows + 1 consumers DEFERRED). SSOT đo lại từ đĩa lượt
   đóng slice: symbols 11757, ledger 1769 entries (tất cả done, N2540
   status done), contracts 1702, schemas 3195, type 62/62 — khớp.
8. Chain neighbours + wiring + gate (main thread):
   NEIGHBOURS-EXIT 0 21:35:40Z (343 passed / 0 failed, 1148.51s, gồm
   test_c07_weapon_update_decay.py 4/4), WIRING-EXIT 0 21:37:46Z (32 OK,
   126.274s), GATE-START 21:47:54Z lượt 2, GATE-EXIT 1 22:09:06Z (Ran
   6369, failures=269 toàn Godot-absent).
9. Chain lượt 1 (NEIGHBOURS-START 20:55:11Z) chết do VM restart #32
   ~21:11Z (uptime 1:07 lúc 22:18Z → boot ~21:11Z). Restart này KHÔNG
   xóa javalang + pytest (khác restart #31) — đã verify trước khi
   relaunch, không cần cài lại. Chain lượt 2 relaunch main thread
   21:16:31Z; survival-check qua cửa 60s (lesson N2523). Gate lượt 1
   (GATE-START 21:45:52Z) chết sớm ~2 phút, nguyên nhân chưa rõ từ log
   (không restart ở thời điểm đó); gate lượt 2 chạy đủ tới EXIT.
10. Gate phân rã theo FAIL block (lượt đóng slice, đọc trực tiếp
    full-suite-n2540-gate.log): 269 FAIL block, TẤT CẢ
    `AssertionError: unexpectedly None` (269 lần xuất hiện, đúng 1
    lần/block); 0 KeyError, 0 `return_schema_linkage`, 0 ERROR; +4
    tests / +1 failure vs gate N2539, đúng mẫu — failure mới là
    test_reference_graph_and_actual_c07_weapon_update_decay
    (Godot-absent vì gate chạy không có godot trên PATH); baseline
    hydration test_liquid_consumer_hydration là 1 FAIL block hằng số
    trong 269 (assertion `unexpectedly None : Godot required for
    hydration proof`).

## Còn lại để đóng slice (lượt đóng slice, cron 05:15 +07)

- Spec + GOAL §5 (dòng nợ Windows) + status commit, rồi 5 commit
  theo mẫu N2537/N2538/N2539 (slice 27a829fe + docs + GOAL + status +
  hashes) và push origin main — gate đã xanh (toàn Godot-absent).

## Deferred / BLOCKED (không đổi sau N2540-scope)

- Weapon.update() leg 2+ — DEFERRED (slice sau N2540, chưa scope):
  shoot/fire leg, checkTarget, predict, retarget sau Weapon.java:306;
  shootLength laser clamp (Weapon.java:391, `float shootLength =
  Math.min(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY),
  range());` — dùng range() N2539); side-flip leg lastReload
  (Weapon.java:427-432); driver update() tick (chưa có driver).
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

## Next sau N2540 (ứng viên theo thứ tự Weapon.java, chưa scope)

- N2540 đóng xong lượt cron 05:15 +07 ngày 2026-11-23 (slice 27a829fe,
  neighbours 343/343, wiring 32 OK, gate Ran 6369 / failures 269 toàn
  Godot-absent, push origin main sau 5 commit theo mẫu N2537/N2538/N2539).
- Sau đó tiếp tục Weapon.update() leg 2 (sau :306) — ứng viên N2541,
  cần scope riêng (shoot/fire leg, checkTarget, predict, retarget;
  findTarget BLOCKED; shootLength dùng range() N2539; side-flip leg
  lastReload :427-432). calculateHeat vẫn BLOCKED, findTarget BLOCKED.
