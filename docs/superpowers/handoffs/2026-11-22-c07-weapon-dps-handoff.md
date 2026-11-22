# Handoff — N2534 Weapon `dps()`: pure function cho Weapon family (C07) [DONE + PUSHED (slice fb8a6ab5, docs 0f9f5b9a, GOAL 531604d2, status e302ca76)]

## Status: DONE + PUSHED (lượt cron 19:15 +07 ngày 2026-11-22; slice fb8a6ab5, docs 0f9f5b9a, GOAL 531604d2, status e302ca76; push xong mới ghi origin/main ở đây sau khi push)

- N2533 DONE + PUSHED ~17:20 +07 ngày 2026-11-22, origin/main == 8e1e3a98
  (5 commit: slice 33a284de + docs 2af6eca0 + GOAL c10e80c8 + status e7822e30 + hashes 8e1e3a98).
- N2534 DONE (slice fb8a6ab5): targeted 4/4 (23 subtests, 18.56s, xác minh
  lại bởi main thread lượt đóng slice, godot-bin trên PATH, port 7777
  free; lượt implement 16.08s); register `--verify` 9/9; proof
  matches:true (8/8 semantic keys + registry_valid +
  one_headquarter_per_ssot = 11/11 true, đọc trực tiếp
  C07WeaponDpsProof.json, mtime 11:20:xxZ — tái sinh bởi neighbours run,
  chạy headless Godot 4.6.2 Linux trên VM, port 7777 free trước khi chạy,
  không chạy song song với agent kia). Neighbours 319/319 SẠCH (1073.19s,
  NEIGHBOURS-EXIT 0 11:22:00Z); wiring 32 OK (124.464s, WIRING-EXIT 0
  11:24:04Z). Gate (log full-suite-n2534-gate.log): GATE-START 11:30:30Z
  chết theo VM restart #29 lúc 11:46:08Z, GATE-START 11:47:07Z main-thread
  launch, GATE-EXIT 1 12:07:42Z — Ran 6345 trong 1233.953s, failures=263,
  skipped=5, errors=0, toàn Godot-absent (262 × unexpectedly None thuần +
  1 × hydration pre-existing; 0 KeyError, 0 return_schema_linkage,
  0 ERROR; +4 tests / +1 failure vs gate N2533, đúng mẫu).
  `git diff --check` SẠCH (main thread chạy lại lượt đóng slice).
- Neighbours + wiring: chain `hidden_files/n2534-chain-main.sh` —
  NEIGHBOURS-START 10:52:37Z (lượt worker-launch, chết không có EXIT
  line — claim "đang chạy" của worker là stale) + NEIGHBOURS-START
  11:04:06Z (main-thread launch, pytest PID 10663, survival-check sau
  50s: vẫn chạy) → NEIGHBOURS-EXIT 0 11:22:00Z, 319 passed trong
  1073.19s (78 module tích lũy); WIRING-START 11:22:00Z →
  WIRING-EXIT 0 11:24:04Z, Ran 32 tests trong 124.464s, OK.
- SSOT đo từ đĩa sau GREEN: 11730/1763/1696/3183 (symbols +1, Done +1,
  contracts +1, schemas +2 so với lúc đóng N2533: 11729/1762/1695/3181).
  Type shard 56/56 (+1/+1, N2534 vào type shard — java_source
  Weapon.java contains "/type/", tiền lệ N2533); comp giữ 572/475.
  Deferred pool 499 (495 + 4: 1 ghi Weapon.dps() DONE + 1 nợ Windows +
  1 wiring N2533→N2534 DEFERRED + 1 Weapon.shotsPerSec() DEFERRED).

## Slice N2534 — scope đã chốt (Weapon.java:188-190, scope khóa trong hidden_files/n2534-scoping.md)

- 1 pure function `source_weapon_dps_state(bullet_estimate_dps,
  reload, shoot_shots)` trong
  `godot-mindustry/src/game/SourceWeaponsCoreState.gd` (sau
  `setup_mounts_state`, TRƯỚC `set_rotation_state`), + 1 delegate
  cùng tên trong `godot-mindustry/src/game/SourceWeaponsState.gd`
  (tiền lệ facade `setup_mounts_state`), KHÔNG driver tick.
- Java (Weapon.java:188-190):
  `public float dps(){` /
  `return (bullet.estimateDPS() / reload) * shoot.shots * 60f;`.
- `bullet_estimate_dps` là float param (caller gọi N2529 trước rồi
  truyền `estimate_dps` trả về) — KHÔNG gọi trực tiếp N2529 trong hàm
  mới (làm vậy phải nhét cả 13 param của bullet vào signature Weapon,
  phá tiền lệ param-driven N2528/N2529/N2533).
- `reload` là float param (default 1, Weapon.java:75,
  `RELOAD_DEFAULT := 1.0` đã có trong SourceWeaponDefaults.gd).
- `shoot_shots` là int param (ShootPattern.shots default 1,
  ShootPattern.java:9, `SHOTS_DEFAULT := 1` đã có trong
  SourceShootPatternDefaults.gd; weapon giữ pattern là
  `public ShootPattern shoot = new ShootPattern();`,
  Weapon.java:97).
- dps() KHÔNG có cache (không có `cachedDps` / `dpsEstimate` trong
  Weapon.java — khác BulletType `cachedDps` và UnitType
  `dpsEstimate`): tính lại mỗi lần gọi, nên KHÔNG có key
  `cached_dps`, KHÔNG có `branch` — trả đúng 1 key `dps`.
- dps() KHÔNG có guard `reload == 0` (chỉ `addStats()`
  Weapon.java:180 mới guard `reload > 0` cho hiển thị): port trung
  thực, không thêm guard — Java float / 0 → Infinity, không throw;
  GDScript float / 0.0 cũng vậy. Edge này KHÔNG có proof key (chưa
  xác nhận harness Godot, theo scoping).
- Trả đúng 1 key `dps` (tiền lệ N2526 — mọi return key đều là symbol).
- DORMANT live hôm nay: không caller nào đọc (N2533 vẫn nhận
  `weapons_dps_sum` làm param; C11 HUD / stats display đọc `dps` là
  slice sau). Caller duy nhất trong Java hôm nay là
  `UnitType.estimateDps()` qua `weapons.sumf(Weapon::dps)`
  (UnitType.java:1136) và `addStats()` (Weapon.java:180-182, công
  thức inline hiển thị, không phải call dps()).
- Proof 8 keys: java_defaults (1.0 / 1 / 1 → 60.0) / reload_2
  (1.0 / 2 / 1 → 30.0) / reload_fractional (1.0 / 0.5 / 1 → 120.0)
  / shots_3 (1.0 / 1 / 3 → 180.0) / shots_zero (shots 0 → 0.0) /
  bullet_zero (0.0 → 0.0) / bullet_fractional (37.5 / 1 / 1 →
  2250.0 — hệ số * 60f có hiệu lực, KHÔNG phải 37.5; scoping ghi
  37.5 là sai, implement đã tính lại) / large (120.0 / 0.5 / 2 →
  28800.0).

## Files của slice (đã commit fb8a6ab5)

- `godot-mindustry/src/game/SourceWeaponsCoreState.gd` (M — hàm canonical mới)
- `godot-mindustry/src/game/SourceWeaponsState.gd` (M — delegate facade 1 dòng)
- `tools/mindustry_godot_transpiler/tests/test_c07_weapon_dps.py` (mới)
- `tools/mindustry_godot_transpiler/register_c07_weapon_dps.py` (mới)
- `godot-mindustry/tools/runtime_proofs/C07WeaponDpsProof.gd` + `.tscn` (mới)
- SSOT (M — register main() đã ghi): `source_slice_ledger.json`,
  `source_symbol_registry.json`, `source_api_contracts.json`,
  `source_state_schema.json`, `source_modules/type_slices.json`,
  `source_modules/type_api_contracts.json` (+ audit report nếu đổi —
  lần này audit report KHÔNG đổi).
- KHÔNG stage: `*.gd.uid` / `project.godot` / `arc-upstream/` /
  `mindustry-upstream/` / proof `.json` /
  `full-suite-*.log` / `hidden_files/` (untracked, đã có từ trước).

## Đã xong lượt này (worker, lượt 17:45 +07)

1. Scope: KHẢ THI (đã khóa trước trong
   `hidden_files/n2534-scoping.md` ~17:31 +07); worker xác minh lại
   trực tiếp trên đĩa: `reload` default 1 (Weapon.java:75),
   `shoot.shots` là field int default 1 (ShootPattern.java:9),
   `bullet.estimateDPS()` đã có (N2529) — wiring qua param theo tiền
   lệ N2528/N2529/N2533. Không BLOCKED.
2. RED trước: 4 test fail (KeyError 'N2534' — chạy `-x`, dừng ở test
   evidence đầu tiên). GREEN sau: targeted 4/4 (23 subtests, 16.08s,
   godot-bin trên PATH, port 7777 free lúc chạy — `ss` grep 7777 = 0
   trước khi chạy).
3. Proof matches:true (8/8 semantic keys + registry_valid +
   one_headquarter_per_ssot = 11/11 true, đọc trực tiếp
   C07WeaponDpsProof.json, mtime 10:52:xxZ).
4. Register `--verify` 9/9 (5 exact exprs + 3 inputs + 1 output).
5. Chain neighbours + wiring launch setsid detached (script
   `hidden_files/n2534-chain-main.sh`, mirror n2533 + module mới
   test_c07_weapon_dps.py, 78 module tích lũy); survival-check sau
   ~60s: bash PID 9226 + pytest PID 9228 đang chạy, log tăng.
6. `git diff --check` SẠCH (chạy ~17:55 +07; chạy lại sau khi chain
   xong, trước bàn giao).

## Deferred / BLOCKED (không đổi sau N2534-scope)

- Wiring N2533 -> N2534 — DEFERRED (consumer slice sau N2534):
  `source_unit_type_estimate_dps_state` vẫn nhận `weapons_dps_sum`
  làm float param; consumer phải gọi `source_weapon_dps_state` cho
  từng weapon rồi cộng (Java `weapons.sumf(Weapon::dps)`,
  UnitType.java:1136).
- Weapon.shotsPerSec() (Weapon.java:192-194, `return shoot.shots *
  60f / reload;`) — DEFERRED (slice sau N2534): cùng 2/3 input với
  dps() (reload + shoot_shots, trừ bullet dps), 1 dòng, pure, KHÔNG
  driver tick.
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

## Next sau N2534 (ứng viên theo thứ tự Weapon.java, chưa scope)

- `Weapon.shotsPerSec()` (Weapon.java:192-194): `return shoot.shots * 60f / reload;` — cùng
  2/3 input với dps() (reload + shoot_shots, trừ bullet dps), 1 dòng, pure, KHÔNG driver tick.
  Scope riêng sau N2534.
- Wiring N2533 -> N2534 (UnitType `sumf(Weapon::dps)` consumer) — slice consumer riêng.
- Sau đó tiếp tục theo thứ tự UnitType.java / Weapon.java; calculateHeat vẫn BLOCKED, findTarget BLOCKED.
