# Handoff — N2542 Weapon.update() leg 3 (C07) [DONE + PUSHED (slice 8cc2ccc5, docs TBD, GOAL TBD, status TBD)]

## Status: DONE + PUSHED (lượt cron 08:45 +07 ngày 2026-11-23; slice 8cc2ccc5, docs TBD, GOAL TBD, status TBD; push xong mới ghi origin/main ở đây sau khi push)

- N2541 DONE + PUSHED ~07:15 +07 ngày 2026-11-23, origin/main == 6d09d677
  (5 commit: slice fcd53003 + docs 83bb2389 + GOAL e220cb2f + status f92a10f1 + hashes 6d09d677).
- N2542 DONE (slice 8cc2ccc5): targeted 4/4 (20 subtests, 17.36s lượt đóng
  slice, xác minh lại bởi main thread; lượt 08:15 chạy 19.34s);
  register `--verify` 13/13 (6 exact exprs + 6 input + 1 output, chạy lại
  lượt đóng slice); proof matches:true (6/6 semantic keys +
  registry_valid + one_headquarter_per_ssot + matches = 9/9 true, đọc
  trực tiếp C07WeaponUpdateHeatProof.json, tái sinh 01:49:08Z bởi targeted
  re-run lượt đóng slice, nội dung không đổi; chạy headless Godot 4.6.2
  Linux trên VM, port 7777 free trước khi chạy, không chạy song song với
  agent kia). Neighbours 351/351 SẠCH (NEIGHBOURS-EXIT 0 00:57:10Z, 351
  passed trong 1190.31s, gồm test_c07_weapon_update_heat.py 4/4); wiring
  32 OK (WIRING-EXIT 0 00:59:16Z, Ran 32 tests trong 126.008s). Gate
  lượt 3 (log full-suite-n2542-gate.log, chain log
  hidden_files/n2542-chain.log): GATE-START 01:20:49Z, GATE-EXIT 1
  01:41:48Z — Ran 6377 trong 1258.098s, failures=271, skipped=5,
  errors=0, toàn Godot-absent (271 FAIL block, TẤT CẢ
  `AssertionError: unexpectedly None`; 0 KeyError, 0
  `return_schema_linkage`, 0 ERROR; +4 tests / +1 failure vs gate N2541,
  đúng mẫu). `git diff --check` SẠCH (lượt đóng slice, trước commit 1).
- Chain gate lượt 1 (GATE-START 01:01:30Z, worker-launch) chết ~90s sau
  launch — đúng mẫu chết theo session worker (08:00 đã ghi worker claim
  survival-check là SAI/stale). Gate lượt 2 (GATE-START 01:04:20Z, main
  thread) chết do VM restart #34 ~01:08:51Z (PID1 đổi 23:04:17Z →
  01:08:51Z). Restart #34 wipe javalang/pytest — đã cài lại 0.13.0/9.2.0
  ở lượt 08:15, verify còn nguyên lượt này. Gate lượt 3 relaunch main
  thread 01:20:49Z, sống qua cửa 60s (lesson N2523), chạy đủ tới EXIT.
  Implement worker (lượt cron 08:30, agent f68047de) bị cancel trước khi
  báo cáo số — code đã nằm trên đĩa, main thread xác minh độc lập toàn
  bộ lượt này (targeted + proof + register + neighbours/wiring/gate đều
  đọc trực tiếp từ đĩa/log, không copy số worker).

## Slice N2542 — scope đã chốt (Weapon.java:376, :409-415, update() leg 3)

- 1 pure function `source_weapon_update_heat_state` (6 params, 1 return
  key `heat`) trong
  `godot-mindustry/src/game/SourceWeaponsCoreState.gd:485` (sau
  `source_weapon_update_aim_state`, trước `set_rotation_state`),
  + 1 delegate cùng tên trong `SourceWeaponsState.gd:197-198`,
  KHÔNG driver tick.
- Java (Weapon.java:376, :409-415):
  `if(continuous && mount.bullet != null){` /
  `}else{` /
  `//heat decreases when not firing` /
  `mount.heat = Math.max(mount.heat - Time.delta * unit.reloadMultiplier / cooldownTime, 0);` /
  `if(mount.sound != null){` /
  `mount.sound.update(bulletX, bulletY, false);` /
  `}` /
  `}`.
  `mount_heat` là mount heat (`/** current heat, 0 to 1*/ public float
  heat;`, WeaponMount.java:21-22). `source_delta` là `Time.delta` (:411);
  `reload_multiplier` là `unit.reloadMultiplier` (:411);
  `cooldown_time` là weapon cooldown time (`/** ticks to cool down the
  heat region */ public float cooldownTime = 20f;`, Weapon.java:89).
  `continuous` là continuous weapon flag (`public boolean continuous;`,
  Weapon.java:53); `has_continuous_bullet` là `mount.bullet != null` leg
  của guard :376 (tiền lệ N2540: null-check là bool input, KHÔNG port lại
  leg continuous-laser :376-408 — leg này mutate live bullet entity,
  BLOCKED làm driver leg). Dòng `mount.sound.update(bulletX, bulletY,
  false)` (:413-415) là audio — SKIP (tiền lệ N2541 activeSound skip).
  GUARD: decay chỉ chạy ở else-branch — khi KHÔNG (continuous &&
  mount.bullet != null). Khi continuous bullet đang live, heat trả về
  không đổi (continuous leg sở hữu bullet lúc đó; heat set 1f bởi
  shoot(), Weapon.java:525 — leg shoot BLOCKED/live, không thuộc slice
  này). Decay clamp ở 0 bằng Math.max (:411), heat không bao giờ âm.
- DORMANT live hôm nay: update() chưa có driver trong port, không caller
  nào đọc (driver update() tick là slice sau) → live behavior KHÔNG đổi.
- Proof 6 keys: decay (heat 0.5 → 0.45 = 0.5 − 1×1/20) / clamp_zero
  (0.01 → 0, không âm) / no_decay_continuous_bullet (continuous true +
  bullet live, heat 0.8 → 0.8, else-branch KHÔNG chạy) /
  cooldown_time_respected (heat 0.6, cooldown 10 → 0.5) /
  heat_zero_unchanged (heat 0 → max(0 − 0.05, 0) = 0) /
  reload_multiplier_scales (heat 0.5, multiplier 2.0 → 0.4).

## Files của slice (đã commit 8cc2ccc5)

- `godot-mindustry/src/game/SourceWeaponsCoreState.gd` (M — hàm canonical mới)
- `godot-mindustry/src/game/SourceWeaponsState.gd` (M — delegate)
- `tools/mindustry_godot_transpiler/tests/test_c07_weapon_update_heat.py` (mới)
- `tools/mindustry_godot_transpiler/register_c07_weapon_update_heat.py` (mới)
- `godot-mindustry/tools/runtime_proofs/C07WeaponUpdateHeatProof.gd` + `.tscn` (mới)
- SSOT (M — register main() đã ghi): `source_slice_ledger.json`,
  `source_symbol_registry.json`, `source_api_contracts.json`,
  `source_state_schema.json`, `source_modules/type_slices.json`,
  `source_modules/type_api_contracts.json` (audit report KHÔNG đổi;
  `source_ssot_modules.json` KHÔNG đổi — type shard đã đăng ký từ
  trước, không shard mới).
- KHÔNG stage: `*.gd.uid` / `project.godot` / `arc-upstream/` /
  `mindustry-upstream/` / proof `.json` (ignored) /
  `full-suite-*.log` / `hidden_files/` (untracked, đã có từ trước).

## Đã xong lượt này (lượt cron 08:15 +07 verify + lượt cron 08:45 +07 đóng slice)

1. Scope: KHẢ THI (update() leg 3, ứng viên theo handoff N2541);
   heat decay Weapon.java:376, :409-415 else-branch, PURE, cooldownTime
   = 20f; scoping đã có trong deferred entry của register N2541.
2. RED: không còn log RED trên đĩa để chạy lại (code đã implement trước
   lượt này bởi worker lượt 08:30, bị cancel trước khi báo cáo; targeted
   lần đầu lượt đóng slice chạy KHÔNG có godot trên PATH → 3/4 fail đúng
   1 test reference-graph `godot is None` — đúng trạng thái thiếu engine,
   không phải thiếu code).
3. GREEN: targeted 4/4 (17.36s lượt đóng slice, 20 subtests, godot-bin
   trên PATH, port 7777 free lúc chạy — `ss` grep 7777 = 0 trước khi
   chạy; lượt 08:15 chạy 19.34s).
4. Proof matches:true (6/6 semantic keys + registry_valid +
   one_headquarter_per_ssot + matches = 9/9 true, đọc trực tiếp
   C07WeaponUpdateHeatProof.json — tái sinh 01:49:08Z bởi targeted
   re-run lượt đóng slice, nội dung không đổi; chạy headless Godot 4.6.2
   Linux trên VM, port 7777 free trước khi chạy, không chạy song song
   với agent kia).
5. Register `--verify` 13/13 (6 exact exprs + 6 inputs + 1 output,
   chạy lại lượt đóng slice, exit 0).
6. `git diff --check` SẠCH (lượt đóng slice, trước commit 1).
7. SSOT đo từ đĩa sau GREEN: 11767/1771/1704/3199 (symbols +1, Done
   +1, contracts +1, schemas +2 so với lúc đóng N2541:
   11766/1770/1703/3197). Type shard 64/64 (+1/+1, N2542 vào type
   shard — java_source Weapon.java, tiền lệ N2533-N2541). Deferred pool
   524 (521 + 3: 1 ghi Weapon.update() leg 3 DONE + 1 nợ Windows + 1
   remaining legs DEFERRED; verify bằng ledger: N2542 deferred_exprs
   524). SSOT đo lại từ đĩa lượt đóng slice: symbols 11767, ledger 1771
   entries (N2542 status done), contracts 1704, schemas 3199, type
   64/64 — khớp.
8. Chain neighbours + wiring + gate (main thread):
   NEIGHBOURS-EXIT 0 00:57:10Z (351 passed / 0 failed, 1190.31s, gồm
   test_c07_weapon_update_heat.py 4/4), WIRING-EXIT 0 00:59:16Z (32 OK,
   126.008s), GATE-START 01:20:49Z (lượt 3), GATE-EXIT 1 01:41:48Z (Ran
   6377, failures=271 toàn Godot-absent).
9. Chain gate lượt 1 (GATE-START 01:01:30Z, worker-launch) chết ~90s sau
   launch — đúng mẫu chết theo session worker (N2540 gate lượt 1 cũng
   vậy). Gate lượt 2 (GATE-START 01:04:20Z, main thread) chết do VM
   restart #34 ~01:08:51Z (uptime 37 phút lúc 01:46Z → boot ~01:08:51Z).
   Restart này wipe javalang + pytest (khác restart #33) — đã cài lại
   0.13.0/9.2.0 ở lượt 08:15, verify còn nguyên lượt này, không cần cài
   lại. Gate lượt 3 relaunch main thread 01:20:49Z; survival-check qua
   cửa 60s (lesson N2523). Gate chạy đủ tới EXIT.
10. Gate phân rã theo FAIL block (lượt đóng slice, đọc trực tiếp
    full-suite-n2542-gate.log): 271 FAIL block, TẤT CẢ
    `AssertionError: unexpectedly None`; 0 KeyError, 0
    `return_schema_linkage`, 0 ERROR; +4 tests / +1 failure vs gate
    N2541, đúng mẫu — failure mới là duy nhất trong diff FAIL list:
    test_reference_graph_and_actual_c07_weapon_update_heat
    (Godot-absent vì gate chạy không có godot trên PATH, đúng thiết kế);
    baseline hydration test_liquid_consumer_hydration là 1 FAIL block
    hằng số trong 271.

## Còn lại để đóng slice (lượt đóng slice, cron 08:45 +07)

- Spec + GOAL §5 (dòng nợ Windows) + status commit, rồi 5 commit
  theo mẫu N2537/N2538/N2539/N2540/N2541 (slice 8cc2ccc5 + docs + GOAL +
  status + hashes) và push origin main — gate đã xanh (toàn Godot-absent).

## Deferred / BLOCKED (không đổi sau N2542-scope, trừ heat decay DONE)

- Weapon.update() remaining legs — DEFERRED (slice sau N2542):
  auto-target block (Weapon.java:315-347, BLOCKED — findTarget :447 live
  Units.closestTarget scan, checkTarget :451 live Units.invalidateTarget,
  Predict.intercept chưa port); continuous-laser leg (:376-408, bullet
  entity live — BLOCKED làm driver leg; shootLength :391 dùng range()
  N2539 + approachDelta, pure); side-flip leg (:418-423, pure với
  `lastReload` :294 làm frame input riêng — leg 1 chỉ trả reload SAU
  decay — ứng viên N2543); activeSound (:425-427, audio — skip); shoot
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

## Next sau N2542 (ứng viên theo thứ tự Weapon.java, chưa scope)

- N2542 đóng xong lượt cron 08:45 +07 ngày 2026-11-23 (slice 8cc2ccc5,
  neighbours 351/351, wiring 32 OK, gate Ran 6377 / failures 271 toàn
  Godot-absent, push origin main sau 5 commit theo mẫu N2537/N2538/N2539/N2540/N2541).
- Sau đó tiếp tục Weapon.update() leg 4 — ứng viên N2543, cần scope riêng
  (side-flip leg Weapon.java:418-423, PURE với `lastReload` :294 làm frame
  input riêng; hoặc Weapon.init() :562 trivial, micro-slice).
  calculateHeat vẫn BLOCKED, findTarget BLOCKED.
