# Handoff — N2533 UnitType `estimateDps()`: pure function cho UnitType family (C07) [DONE + PUSHED (slice 33a284de, docs 2af6eca0, GOAL c10e80c8, status e7822e30)]

## Status: DONE + PUSHED (lượt cron 17:15 +07 ngày 2026-11-22; slice 33a284de, docs 2af6eca0, GOAL c10e80c8, status e7822e30; push xong mới ghi origin/main ở đây sau khi push)

- N2532 DONE + PUSHED ~15:45 +07 ngày 2026-11-22, origin/main == e45de296
  (5 commit: slice 4aedbbf6 + docs 710afe02 + GOAL 6c36b912 + status dc09b68e + hashes e45de296).
- N2533 DONE (slice 33a284de, 11 file, 1298 insertions) — main thread xác minh
  độc lập lượt này: targeted 4/4 (29 subtests, 16.09s, godot-bin trên PATH,
  port 7777 free); register --verify 13/13; proof matches:true (8/8 semantic
  keys + registry_valid + one_headquarter_per_ssot, đọc trực tiếp
  C07UnitTypeEstimateDpsProof.json, mtime 10:18:46Z — tái sinh bởi targeted
  re-run lượt này); neighbours 315 passed trong 1050.09s (NEIGHBOURS-EXIT 0
  09:27:52Z); wiring 32 OK trong 124.993s (WIRING-EXIT 0 09:29:57Z); gate
  lượt 4 (GATE-START 09:51:39Z main-thread launch, GATE-EXIT 1 10:12:29Z)
  Ran 6341 trong 1248.732s, failures=262, skipped=5 — xác minh độc lập theo
  FAIL block: 261 × unexpectedly None thuần + 1 × hydration pre-existing
  (test_liquid_consumer_hydration.py:66), 0 KeyError, 0 return_schema_linkage,
  0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2532).
  SSOT đo từ đĩa 11729/1762/1695/3181; type shard 55/55; comp 572/475 không
  đổi; deferred pool 495.
- RED trước: 4/4 fail (KeyError 'N2533' + assert thiếu hàm/proof).
  GREEN sau: targeted 4/4 (29 subtests, 15.33s, godot-bin trên PATH),
  register `--verify` 13/13 exprs present, proof matches:true (8/8
  semantic keys + registry_valid + one_headquarter_per_ssot, đọc trực tiếp
  C07UnitTypeEstimateDpsProof.json, mtime 09:07:xxZ — chạy headless Godot
  4.6.2 Linux trên VM, port 7777 free trước khi chạy, không chạy song song
  với agent kia — `pgrep -f godot` chỉ match chính lệnh exec, không có
  process Godot thật). `git diff --check` SẠCH. Không stage gì (để file
  trên đĩa cho main thread).
- SSOT đo từ đĩa sau GREEN: 11729/1762/1695/3181 (symbols +3, Done +1,
  contracts +1, schemas +2 so với lúc đóng N2532: 11726/1761/1694/3179).
  Type shard 55/55 (+1/+1, N2533 vào type shard — java_source
  UnitType.java, tiền lệ N1871-N1882); comp giữ 572/475. Deferred pool
  495 (491 + 4: 1 ghi estimateDps() DONE + 1 nợ Windows + 1 wiring
  N2529->N2533 DEFERRED + 1 Weapon.dps() DEFERRED).

## Slice N2533 — scope đã chốt (UnitType.java:1132-1144)

- 1 pure function `source_unit_type_estimate_dps_state(cached_dps,
  weapons_dps_sum, has_kill_shooter_weapon)` trong
  `godot-mindustry/src/game/SourceUnitTypeState.gd` (sau `landed_state`,
  TRƯỚC các generated bridge), KHÔNG driver tick.
- Java (UnitType.java:1132-1144):
  `public float estimateDps(){` / `if(dpsEstimate < 0){` /
  `dpsEstimate = weapons.sumf(Weapon::dps);` /
  `if(weapons.contains(w -> w.bullet.killShooter)){` /
  `dpsEstimate /= 15f;` / `return dpsEstimate;`.
- Cache check là `dpsEstimate < 0` (KHÔNG phải `>= 0f`): cached 0.0 LÀ
  hit (0 không < 0), cache âm (-1, init `dpsEstimate = -1,`
  UnitType.java:104) thì recompute. Leg suicide chia ĐÚNG field vừa
  cộng (`dpsEstimate /= 15f;`) nên giá trị đã chia mới là giá trị được
  cache — hàm trả giá trị đã chia qua cả `estimate_dps` và `cached_dps`
  ở branch "computed_suicide".
- `weapons_dps_sum` là float param (caller cộng `weapons.sumf(Weapon::dps)`)
  vì Weapon.dps() (Weapon.java:188-190, `(bullet.estimateDPS() / reload)
  * shoot.shots * 60f`) CHƯA port — slice riêng sau.
  `has_kill_shooter_weapon` là bool param (caller scan weapons tìm
  bullet có `killShooter`, BulletType.java:105).
- Trả đúng 3 key `estimate_dps` / `cached_dps` / `branch` (tiền lệ
  N2526 — mọi return key đều là symbol). Branch: "cached" /
  "computed" / "computed_suicide".
- DORMANT live hôm nay: không caller nào đọc (N2529 vẫn nhận
  `spawn_unit_dps` / `despawn_unit_dps` làm param; C11 HUD / stats
  display đọc `estimate_dps` là slice sau). `estimateDps()` còn được
  gọi từ `UnitType.init()` (UnitType.java:1129) — đó là content-init
  call site, KHÔNG phải per-tick driver, slice này không wire init().
- Proof 8 keys: cached_hit (42.0, cache thắng cả khi có suicide) /
  cached_zero (0.0 LÀ hit) / negative_cached_recomputes (-5.0 → 30.0) /
  weapons_sum (120.0) / fractional_sum (37.5) / suicide (150.0 → 10.0) /
  suicide_fraction (100.0 → 100/15) / java_defaults (-1, no weapons →
  0.0).

## Files của slice (chưa commit — main thread stage đúng các file này)

- `godot-mindustry/src/game/SourceUnitTypeState.gd` (M — hàm mới)
- `tools/mindustry_godot_transpiler/tests/test_c07_unit_type_estimate_dps.py` (mới)
- `tools/mindustry_godot_transpiler/register_c07_unit_type_estimate_dps.py` (mới)
- `godot-mindustry/tools/runtime_proofs/C07UnitTypeEstimateDpsProof.gd` + `.tscn` (mới)
- SSOT (M — register main() đã ghi): `source_slice_ledger.json`,
  `source_symbol_registry.json`, `source_api_contracts.json`,
  `source_state_schema.json`, `source_modules/type_slices.json`,
  `source_modules/type_api_contracts.json` (+ audit report nếu đổi).
- KHÔNG stage: `*.gd.uid` / `project.godot` / `arc-upstream/` /
  `mindustry-upstream/` / proof `.json` /
  `full-suite-*.log` / `hidden_files/` (untracked, đã có từ trước).

## Đã xong lượt này (main thread, lượt cron 17:15 +07)

1. Xác minh độc lập: targeted 4/4 (29 subtests, 16.09s) + register --verify
   13/13 + proof .json đọc trực tiếp (matches:true, 8/8 keys, mtime
   10:18:46Z — tái sinh bởi targeted re-run lượt này).
2. Chain (launch main thread 16:10, START 09:10:22Z): neighbours 315 passed
   trong 1050.09s (NEIGHBOURS-EXIT 0 09:27:52Z), wiring 32 OK trong 124.993s
   (WIRING-EXIT 0 09:29:57Z).
3. Gate full-suite: 4 lượt — GATE-START 09:31:26Z chết ~60-90s sau launch
   (partial run1-0931); GATE-START 09:33:28Z chết theo VM restart #28 lúc
   09:45:13Z (partial restart28); GATE-START 09:49:19Z chết ~60-90s sau
   launch (partial run3-0949); GATE-START 09:51:39Z main-thread launch sống
   tới EXIT, GATE-EXIT 1 10:12:29Z. Ran 6341 trong 1248.732s, failures=262,
   skipped=5 — phân rã theo FAIL block: 261 × unexpectedly None thuần + 1 ×
   hydration pre-existing (test_liquid_consumer_hydration.py:66), 0 KeyError,
   0 return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure
   đúng mẫu vs N2532).
4. Slice commit 33a284de (11 file, 1298 insertions) → docs commit (report +
   handoff này + spec dòng N2533 + GOAL §5 nợ Windows) + status + hashes,
   push mẫu 5 commit, spec Done 1761→1762 (đo từ đĩa: ledger Done 1762).
5. `git diff --check` SẠCH trước mỗi commit.

## Deferred / BLOCKED (không đổi sau N2533-scope)

- Weapon.dps() (Weapon.java:188-190) — DEFERRED (slice sau N2533):
  tới lúc đó `weapons_dps_sum` vẫn là float param, và
  `has_kill_shooter_weapon` vẫn là bool param (caller scan).
- Wiring N2529 -> N2533 — DEFERRED (consumer slice sau N2533):
  `source_bullet_type_estimate_dps_state` vẫn nhận `spawn_unit_dps` /
  `despawn_unit_dps` làm float param; consumer phải gọi
  `source_unit_type_estimate_dps_state` rồi truyền `estimate_dps` trả về.
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

## Next sau N2533 (ứng viên theo thứ tự UnitType.java, chưa scope)

- `Weapon.dps()` (Weapon.java:188-190): `(bullet.estimateDPS() / reload)
  * shoot.shots * 60f` — cần scope riêng: `bullet.estimateDPS()` đã có
  (N2529) nhưng wiring qua param hay gọi trực tiếp, `shoot.shots`
  (ShootPattern) là field hay param, `reload` field default.
- `calculateHeat` vẫn BLOCKED, `findTarget` BLOCKED.
