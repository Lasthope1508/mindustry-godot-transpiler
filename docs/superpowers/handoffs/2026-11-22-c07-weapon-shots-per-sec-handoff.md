# Handoff — N2535 Weapon `shotsPerSec()`: pure function cho Weapon family (C07) [DONE + PUSHED (slice 7f61f2d8, docs e05b904a, GOAL 57052a13, status 52e4b6e5)]

## Status: DONE + PUSHED (lượt cron 20:30 +07 ngày 2026-11-22; slice 7f61f2d8, docs e05b904a, GOAL 57052a13, status 52e4b6e5; push xong mới ghi origin/main ở đây sau khi push)

- N2534 DONE + PUSHED ~19:15 +07 ngày 2026-11-22, origin/main == 308b9f00
  (5 commit: slice fb8a6ab5 + docs 0f9f5b9a + GOAL 531604d2 + status e302ca76 + hashes 308b9f00).
- N2535 DONE (slice 7f61f2d8): targeted 4/4 (23 subtests, 17.70s, xác minh
  lại bởi lượt đóng slice, godot-bin trên PATH, port 7777
  free; lượt implement GREEN 4/4 theo
  hidden_files/n2535-red-green-1930.md); register `--verify` 8/8;
  proof matches:true (8/8 semantic keys + registry_valid +
  one_headquarter_per_ssot = 11/11 true, đọc trực tiếp
  C07WeaponShotsPerSecProof.json, mtime 12:51Z — tái sinh bởi
  neighbours run, chạy headless Godot 4.6.2 Linux trên VM, port 7777
  free trước khi chạy, không chạy song song với agent kia).
  Neighbours 323/323 SẠCH (1089.36s, NEIGHBOURS-EXIT 0 12:52:49Z);
  wiring 32 OK (122.951s, WIRING-EXIT 0 12:54:52Z). Gate (log
  full-suite-n2535-gate.log): GATE-START 13:01:54Z main-thread
  launch, GATE-EXIT 1 13:22:44Z — Ran 6349 trong 1248.688s,
  failures=264, skipped=5, errors=0, toàn Godot-absent (264 FAIL
  block, TẤT CẢ `AssertionError: unexpectedly None`, 264 lần xuất
  hiện đúng 1 lần/block; 0 KeyError, 0 return_schema_linkage,
  0 ERROR; +4 tests / +1 failure vs gate N2534, đúng mẫu).
  `git diff --check` SẠCH (lượt đóng slice).
- Neighbours + wiring: chain `hidden_files/n2535-chain-main.sh` —
  NEIGHBOURS-START 12:34:39Z → NEIGHBOURS-EXIT 0 12:52:49Z, 323
  passed trong 1089.36s (79 module tích lũy); WIRING-START
  12:52:49Z → WIRING-EXIT 0 12:54:52Z, Ran 32 tests trong 122.951s,
  OK. Gate chạy tiếp trong cùng chain: GATE-START 13:01:54Z →
  GATE-EXIT 1 13:22:44Z.
- SSOT đo từ đĩa sau GREEN: 11731/1764/1697/3185 (symbols +1, Done +1,
  contracts +1, schemas +2 so với lúc đóng N2534: 11730/1763/1696/3183).
  Type shard 57/57 (+1/+1, N2535 vào type shard — java_source
  Weapon.java, tiền lệ N2533/N2534); comp giữ 572/475.
  Deferred pool 503 (499 + 4: 1 ghi Weapon.shotsPerSec() DONE + 1 nợ
  Windows + 1 C11 HUD/stats display đọc `shots_per_sec` DEFERRED +
  1 Weapon.drawOutline() DEFERRED).

## Slice N2535 — scope đã chốt (Weapon.java:192-194, scope khóa trong hidden_files/n2535-red-green-1930.md)

- 1 pure function `source_weapon_shots_per_sec_state(reload,
  shoot_shots)` trong
  `godot-mindustry/src/game/SourceWeaponsCoreState.gd` (sau
  `source_weapon_dps_state`, TRƯỚC `set_rotation_state`), + 1 delegate
  cùng tên trong `godot-mindustry/src/game/SourceWeaponsState.gd`
  (tiền lệ facade `setup_mounts_state`), KHÔNG driver tick.
- Java (Weapon.java:192-194):
  `public float shotsPerSec(){` /
  `return shoot.shots * 60f / reload;`.
- `reload` là float param (default 1, Weapon.java:75,
  `RELOAD_DEFAULT := 1.0` đã có trong SourceWeaponDefaults.gd).
- `shoot_shots` là int param (ShootPattern.shots default 1,
  ShootPattern.java:8-9, `SHOTS_DEFAULT := 1` đã có trong
  SourceShootPatternDefaults.gd; weapon giữ pattern là
  `public ShootPattern shoot = new ShootPattern();`,
  Weapon.java:97).
- shotsPerSec() KHÔNG có cache (không có `cachedDps` / `dpsEstimate`
  trong Weapon.java — khác BulletType `cachedDps` và UnitType
  `dpsEstimate`): tính lại mỗi lần gọi, nên KHÔNG có key
  `cached_shots_per_sec`, KHÔNG có `branch` — trả đúng 1 key
  `shots_per_sec`.
- shotsPerSec() KHÔNG có guard `reload == 0` (chỉ `addStats()`
  Weapon.java:180 mới guard `reload > 0` cho hiển thị): port trung
  thực, không thêm guard — Java float / 0 → Infinity, không throw;
  GDScript float / 0.0 cũng vậy. Edge này KHÔNG có proof key (chưa
  xác nhận harness Godot, theo scoping N2534).
- Trả đúng 1 key `shots_per_sec` (tiền lệ N2526 — mọi return key đều
  là symbol).
- DORMANT live hôm nay: không caller nào đọc (không caller Java
  ngoài Weapon; C11 HUD / stats display đọc `shots_per_sec` là
  slice sau). Caller duy nhất trong Java hôm nay là `addStats()`
  (Weapon.java:180-182, công thức inline hiển thị, không phải call
  shotsPerSec()).
- Proof 8 keys: sps_java_defaults (1.0 / 1 → 60.0) / sps_reload_2
  (2.0 / 1 → 30.0) / sps_reload_fractional (0.5 / 1 → 120.0) /
  sps_shots_3 (1 / 3 → 180.0) / sps_shots_zero (shots 0 → 0.0) /
  sps_reload_60 (60.0 / 1 → 1.0) / sps_fractional (1.5 / 2 → 80.0)
  / sps_large (0.5 / 2 → 240.0).

## Files của slice (đã commit 7f61f2d8)

- `godot-mindustry/src/game/SourceWeaponsCoreState.gd` (M — hàm canonical mới)
- `godot-mindustry/src/game/SourceWeaponsState.gd` (M — delegate facade 1 dòng)
- `tools/mindustry_godot_transpiler/tests/test_c07_weapon_shots_per_sec.py` (mới)
- `tools/mindustry_godot_transpiler/register_c07_weapon_shots_per_sec.py` (mới)
- `godot-mindustry/tools/runtime_proofs/C07WeaponShotsPerSecProof.gd` + `.tscn` (mới)
- SSOT (M — register main() đã ghi): `source_slice_ledger.json`,
  `source_symbol_registry.json`, `source_api_contracts.json`,
  `source_state_schema.json`, `source_modules/type_slices.json`,
  `source_modules/type_api_contracts.json` (+ audit report nếu đổi —
  lần này audit report KHÔNG đổi).
- KHÔNG stage: `*.gd.uid` / `project.godot` / `arc-upstream/` /
  `mindustry-upstream/` / proof `.json` /
  `full-suite-*.log` / `hidden_files/` (untracked, đã có từ trước).

## Đã xong lượt này (worker đóng slice, lượt 20:30 +07)

1. Scope: KHẢ THI (đã khóa trước trong
   `hidden_files/n2535-red-green-1930.md` ~19:30 +07, ứng viên theo
   handoff N2534); worker đóng slice xác minh lại trực tiếp trên
   đĩa: `reload` default 1 (Weapon.java:75), `shoot.shots` là field
   int default 1 (ShootPattern.java:8-9), `addStats()` guard
   `reload > 0` chỉ cho hiển thị (Weapon.java:180). Không BLOCKED.
2. RED trước: 4 test fail (KeyError 'N2535' — theo
   hidden_files/n2535-red-green-1930.md). GREEN sau: targeted 4/4
   (23 subtests; lượt implement theo red-green note, lượt đóng slice
   chạy lại 17.70s, godot-bin trên PATH, port 7777 free lúc chạy —
   `ss` grep 7777 = 0 trước khi chạy).
3. Proof matches:true (8/8 semantic keys + registry_valid +
   one_headquarter_per_ssot = 11/11 true, đọc trực tiếp
   C07WeaponShotsPerSecProof.json, mtime 12:51Z — tái sinh bởi
   neighbours run).
4. Register `--verify` 8/8 (chạy lại lượt đóng slice).
5. Chain neighbours + wiring + gate (script
   `hidden_files/n2535-chain-main.sh`, mirror N2534 + module mới
   test_c07_weapon_shots_per_sec.py, 79 module tích lũy):
   NEIGHBOURS-EXIT 0 12:52:49Z (323 passed, 1089.36s),
   WIRING-EXIT 0 12:54:52Z (32 OK, 122.951s), GATE-EXIT 1
   13:22:44Z (Ran 6349, failures=264 toàn Godot-absent).
6. Gate phân rã theo FAIL block (lượt đóng slice, đọc trực tiếp
   full-suite-n2535-gate.log): 264 FAIL block, TẤT CẢ
   `AssertionError: unexpectedly None` (264 lần xuất hiện); 0
   KeyError, 0 `return_schema_linkage`, 0 ERROR; baseline N2534
   263 = 261 thuần + 2 FAIL block hydration-module không đổi +
   1 reference-graph của N2534; +1 là
   test_reference_graph_and_actual_c07_weapon_shots_per_sec.
7. `git diff --check` SẠCH (chạy lượt đóng slice, trước commit 1).

## Deferred / BLOCKED (không đổi sau N2535-scope)

- Wiring N2533 -> N2534 — DEFERRED (consumer slice sau N2534):
  `source_unit_type_estimate_dps_state` vẫn nhận `weapons_dps_sum`
  làm float param; consumer phải gọi `source_weapon_dps_state` cho
  từng weapon rồi cộng (Java `weapons.sumf(Weapon::dps)`,
  UnitType.java:1136).
- C11 HUD / stats display đọc `shots_per_sec` — DEFERRED (slice
  sau): `addStats()` (Weapon.java:180-182) hiển thị shotsPerSec
  qua công thức inline, chưa wire vào hàm mới.
- Weapon.drawOutline() (Weapon.java:196+, `//TODO copy-pasted code`)
  — DEFERRED (slice sau N2535, chưa scope): draw code, rendering
  nằm ngoài game — tiền lệ drawrot (N2532) và các draw slice trước.
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

## Next sau N2535 (ứng viên theo thứ tự Weapon.java, chưa scope)

- Wiring N2533 -> N2534 (UnitType `sumf(Weapon::dps)` consumer) — slice consumer riêng.
- `Weapon.drawOutline()` (Weapon.java:196+, `//TODO copy-pasted code`): draw code, rendering nằm ngoài game — cần scope riêng (có thể DEFERRED như các draw slice trước).
- Sau đó tiếp tục theo thứ tự UnitType.java / Weapon.java; calculateHeat vẫn BLOCKED, findTarget BLOCKED.
