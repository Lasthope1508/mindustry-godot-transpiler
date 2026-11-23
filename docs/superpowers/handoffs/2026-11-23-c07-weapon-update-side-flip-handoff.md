# Handoff — N2543 Weapon.update() leg 4 (C07) [DONE + PUSHED (slice 364af040, docs b5a01fa3, GOAL abac5890)]

## Status: DONE + PUSHED (lượt cron 10:00 +07 ngày 2026-11-23; slice 364af040, docs b5a01fa3, GOAL abac5890; push xong mới ghi origin/main ở đây sau khi push)

- N2542 DONE + PUSHED ~08:45 +07 ngày 2026-11-23, origin/main == d7dadcf1
  (5 commit: slice 8cc2ccc5 + docs 19c050fb + GOAL f0e85631 + status 8d61dd9b + hashes d7dadcf1).
- N2543 DONE (slice 364af040): targeted 4/4 (31 subtests, 18.31s lượt đóng
  slice, xác minh lại bởi main thread); register `--verify` 23/23 (11 exact
  exprs + 9 input + 3 output, chạy lại lượt đóng slice); proof matches:true
  (7/7 semantic keys + registry_valid + one_headquarter_per_ssot + matches
  = 10/10 true, đọc trực tiếp C07WeaponUpdateSideFlipProof.json, tái sinh
  03:04:35Z bởi targeted re-run lượt đóng slice, nội dung không đổi; chạy
  headless Godot 4.6.2 Linux trên VM, port 7777 free trước khi chạy, không
  chạy song song với agent kia). Neighbours 355/355 SẠCH (NEIGHBOURS-EXIT 0
  02:31:48Z, 355 passed trong 1207.25s, gồm test_c07_weapon_update_side_flip.py
  4/4); wiring 32 OK (WIRING-EXIT 0 02:33:53Z, Ran 32 tests trong 125.116s).
  Gate (log full-suite-n2543-gate.log, chain log hidden_files/n2543-chain.log):
  GATE-START 02:34:22Z, GATE-EXIT 1 02:55:34Z — Ran 6381 trong 1270.366s,
  failures=272, skipped=5, errors=0, toàn Godot-absent (272 FAIL block, TẤT CẢ
  `AssertionError: unexpectedly None`; 0 KeyError, 0 `return_schema_linkage`,
  0 ERROR; +4 tests / +1 failure vs gate N2542, đúng mẫu). `git diff --check`
  SẠCH (lượt đóng slice, trước commit 1).
- Chain gate 1 lượt duy nhất, sống tới EXIT (không chết worker-launch,
  không VM restart lượt này; chain PID 7592, NEIGHBOURS-START 02:11:40Z).
  Implement + neighbours + gate đều đã có trên đĩa/log trước lượt này;
  main thread xác minh độc lập toàn bộ lượt này (targeted re-run + proof +
  register + neighbours/wiring/gate đều đọc trực tiếp từ đĩa/log, không
  copy số worker).

## Slice N2543 — scope đã chốt (Weapon.java:418-423, update() leg 4)

- 1 pure function `source_weapon_update_side_flip_state` (9 params, 3 return
  keys `mount_side, other_side_side, was_flipped`) trong
  `godot-mindustry/src/game/SourceWeaponsCoreState.gd:528` (sau
  `source_weapon_update_heat_state`, trước `set_rotation_state`),
  + 1 delegate cùng tên trong `SourceWeaponsState.gd:200-201`,
  KHÔNG driver tick.
- Java (Weapon.java:418-423):
  `//flip weapon shoot side for alternating weapons` /
  `boolean wasFlipped = mount.side;` /
  `if(otherSide >= 0 && alternate && mount.side == flipSprite && otherSide < unit.mounts.length && mount.reload <= reload / 2f && lastReload > reload / 2f){` /
  `unit.mounts[otherSide].side = !unit.mounts[otherSide].side;` /
  `mount.side = !mount.side;` /
  `}`.
  `other_side` là mirror mount index (`/** internal value used for
  alternation - do not change! */ public int otherSide = -1;`,
  Weapon.java:125). `alternate` là alternation flag (`/** whether to shoot
  the weapons in different arms one after another, rather than all at once;
  only valid when mirror = true */ public boolean alternate = true;`,
  Weapon.java:43). `mount_side` là side của mount này (`/** extra state for
  alternating weapons */ public boolean side;`, WeaponMount.java:40).
  `flip_sprite` là sprite-flip flag (`/** whether to flip the weapon's
  sprite when rendering. internal use only - do not set! */ public boolean
  flipSprite = false;`, Weapon.java:41). `other_mount_side` là side hiện tại
  của mount đối diện (`unit.mounts[otherSide].side`, :421) — param riêng vì
  hàm pure không đọc live mounts array (tiền lệ N2540: count / null-check là
  input). `mounts_count` là `unit.mounts.length` (:420). `mount_reload` là
  reload SAU decay của leg 1 N2540 (Weapon.java:295). `weapon_reload` là
  weapon reload (`/** weapon reload in frames */ public float reload = 1;`,
  Weapon.java:75). `last_reload` là reload TRƯỚC decay (`float lastReload =
  mount.reload;`, Weapon.java:294) — frame input riêng, vì leg 1 chỉ trả
  reload SAU decay (bẫy đã ghi từ N2541-scope).
- Bẫy giữ đúng: guard là AND 6 chân, đúng thứ tự Java — `otherSide >= 0`,
  `alternate`, `mount.side == flipSprite`, `otherSide < unit.mounts.length`,
  `mount.reload <= reload / 2f`, `lastReload > reload / 2f`. So sánh reload
  là `<=` (bằng đúng nửa thì flip) nhưng lastReload là `>` strict (bằng
  đúng nửa thì KHÔNG flip) — proof key `no_flip_last_reload_at_half` bắt
  đúng chân này. `was_flipped` = `mount.side` TRƯỚC flip (:419), trả nguyên
  vẹn cả khi guard fail (khi đó bằng đúng input mount_side); shoot gate
  :435 (`(!alternate || wasFlipped == flipSprite)`) sẽ đọc nó ở slice sau.
  Cả hai side đều flip cùng lúc khi guard pass; khi guard fail, cả hai giữ
  nguyên. Mirror invariant: `otherSide` trỏ tới mount đối diện, không bao
  giờ trỏ chính mount này.
- DORMANT live hôm nay: update() chưa có driver trong port, không caller
  nào đọc (driver update() tick là slice sau) → live behavior KHÔNG đổi.
- Proof 7 keys: flip / no_flip_reload_not_crossed /
  no_flip_last_reload_at_half / no_flip_side_mismatch /
  no_flip_other_side_negative / no_flip_other_side_out_of_range /
  no_flip_alternate_false. Mỗi key assert đủ bộ ba (mount_side,
  other_side_side, was_flipped). Defaults: otherSide=1, alternate=true,
  mount_side=false, flip_sprite=false, other_mount_side=false,
  mounts_count=2, mount_reload=10.0, weapon_reload=60.0 (half 30.0),
  last_reload=40.0.

## Files của slice (đã commit 364af040)

- `godot-mindustry/src/game/SourceWeaponsCoreState.gd` (M — hàm canonical mới)
- `godot-mindustry/src/game/SourceWeaponsState.gd` (M — delegate)
- `tools/mindustry_godot_transpiler/tests/test_c07_weapon_update_side_flip.py` (mới)
- `tools/mindustry_godot_transpiler/register_c07_weapon_update_side_flip.py` (mới)
- `godot-mindustry/tools/runtime_proofs/C07WeaponUpdateSideFlipProof.gd` + `.tscn` (mới)
- SSOT (M — register main() đã ghi): `source_slice_ledger.json`,
  `source_symbol_registry.json`, `source_api_contracts.json`,
  `source_state_schema.json`, `source_modules/type_slices.json`,
  `source_modules/type_api_contracts.json` (audit report KHÔNG đổi;
  `source_ssot_modules.json` KHÔNG đổi — type shard đã đăng ký từ
  trước, không shard mới).
- KHÔNG stage: `*.gd.uid` / `project.godot` / `arc-upstream/` /
  `mindustry-upstream/` / proof `.json` (ignored) /
  `full-suite-*.log` / `hidden_files/` (untracked, đã có từ trước).

## Đã xong lượt này (lượt cron 10:00 +07 đóng slice)

1. Scope: KHẢ THI (update() leg 4, ứng viên theo handoff N2542 + scope doc
   hidden_files/n2543-scope.md); side-flip Weapon.java:418-423, PURE,
   6-conjunct guard, `lastReload` :294 làm frame input riêng.
2. RED: targeted-red.log (02:07) còn trên đĩa từ lượt implement; lượt đóng
   slice chạy targeted KHÔNG có godot trên PATH sẽ fail đúng 1 test
   reference-graph `godot is None` — đúng trạng thái thiếu engine, không
   phải thiếu code (đã thấy mẫu này ở N2542).
3. GREEN: targeted 4/4 (18.31s lượt đóng slice, 31 subtests, godot-bin
   trên PATH, port 7777 free lúc chạy — `ss` grep 7777 = 0 trước khi
   chạy).
4. Proof matches:true (7/7 semantic keys + registry_valid +
   one_headquarter_per_ssot + matches = 10/10 true, đọc trực tiếp
   C07WeaponUpdateSideFlipProof.json — tái sinh 03:04:35Z bởi targeted
   re-run lượt đóng slice, nội dung không đổi; chạy headless Godot 4.6.2
   Linux trên VM, port 7777 free trước khi chạy, không chạy song song
   với agent kia).
5. Register `--verify` 23/23 (11 exact exprs + 9 inputs + 3 outputs,
   chạy lại lượt đóng slice, exit 0).
6. `git diff --check` SẠCH (lượt đóng slice, trước commit 1).
7. SSOT đo từ đĩa sau GREEN: 11770/1772/1705/3201 (symbols +3, Done
   +1, contracts +1, schemas +2 so với lúc đóng N2542:
   11767/1771/1704/3199). Type shard 65/65 (+1/+1, N2543 vào type
   shard — java_source Weapon.java, tiền lệ N2533-N2542). Deferred pool
   527 (524 + 3: 1 ghi Weapon.update() leg 4 DONE + 1 nợ Windows + 1
   remaining legs DEFERRED; verify bằng ledger: N2543 deferred_exprs
   527). SSOT đo lại từ đĩa lượt đóng slice: symbols 11770, ledger 1772
   entries (N2543 status done), contracts 1705, schemas 3201, type
   65/65 — khớp.
8. Chain neighbours + wiring + gate (main thread, 1 lượt duy nhất):
   NEIGHBOURS-EXIT 0 02:31:48Z (355 passed / 0 failed, 1207.25s, gồm
   test_c07_weapon_update_side_flip.py 4/4), WIRING-EXIT 0 02:33:53Z (32 OK,
   125.116s), GATE-START 02:34:22Z, GATE-EXIT 1 02:55:34Z (Ran 6381,
   failures=272 toàn Godot-absent).
9. Không VM restart lượt này; javalang 0.13.0 + pytest 9.2.0 verify còn
   nguyên lượt này (import OK), không cần cài lại.
10. Gate phân rã theo FAIL block (lượt đóng slice, đọc trực tiếp
    full-suite-n2543-gate.log): 272 FAIL block, TẤT CẢ
    `AssertionError: unexpectedly None`; 0 KeyError, 0
    `return_schema_linkage`, 0 ERROR; +4 tests / +1 failure vs gate
    N2542, đúng mẫu — failure mới là duy nhất trong diff FAIL list:
    test_reference_graph_and_actual_c07_weapon_update_side_flip
    (Godot-absent vì gate chạy không có godot trên PATH, đúng thiết kế;
    chính test này PASS trong neighbours run và PASS 4/4 ở targeted
    re-run lượt đóng slice khi godot có trên PATH); baseline hydration
    test_liquid_consumer_hydration là 1 FAIL block hằng số trong 272.

## Còn lại để đóng slice (lượt đóng slice, cron 10:00 +07)

- Spec + GOAL §5 (dòng nợ Windows) + status commit, rồi 5 commit
  theo mẫu N2537/N2538/N2539/N2540/N2541/N2542 (slice 364af040 + docs +
  GOAL + status + hashes) và push origin main — gate đã xanh (toàn Godot-absent).

## Deferred / BLOCKED (không đổi sau N2543-scope, trừ side-flip DONE)

- Weapon.update() remaining legs — DEFERRED (slice sau N2543):
  auto-target block (Weapon.java:315-347, BLOCKED — findTarget :447 live
  Units.closestTarget scan, checkTarget :451 live Units.invalidateTarget,
  Predict.intercept chưa port); continuous-laser leg (:376-408, bullet
  entity live — BLOCKED làm driver leg; shootLength :391 dùng range()
  N2539 + approachDelta, pure); activeSound (:425-427, audio — skip);
  shoot gate + shoot() (:429-444, BLOCKED/live — shoot() spawn bullet thật,
  :459+; velLen cần unit.isRemote/deltaLen live; shoot gate :435 đọc
  `was_flipped` của slice này). flip() :544 cần ShootPattern.copy()/flip()
  (port status chưa kiểm) — defer. init() :562 trivial (alwaysContinuous →
  continuous) — micro-slice N2544 sau, khi update() legs đã xong.
  addStats() :175-187 UI stats, C11-ish — defer. Driver update() tick
  (chưa có driver).
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

## Next sau N2543 (ứng viên theo thứ tự Weapon.java, chưa scope)

- N2543 đóng xong lượt cron 10:00 +07 ngày 2026-11-23 (slice 364af040,
  neighbours 355/355, wiring 32 OK, gate Ran 6381 / failures 272 toàn
  Godot-absent, push origin main sau 5 commit theo mẫu N2537/N2538/N2539/N2540/N2541/N2542).
- Sau đó tiếp tục Weapon.update() — ứng viên N2544, cần scope riêng
  (Weapon.init() :562 trivial, `if(alwaysContinuous){ continuous = true; }`,
  micro-slice; hoặc shoot gate :429-444, BLOCKED/live — chưa làm được).
  calculateHeat vẫn BLOCKED, findTarget BLOCKED.
