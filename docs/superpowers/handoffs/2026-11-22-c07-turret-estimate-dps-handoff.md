# Handoff — N2528 Turret `estimateDps()`: pure function cho Turret family (C07) [DONE]

## Status: DONE + PUSHED (gate xanh theo mẫu Godot-absent, xác minh độc lập lượt cron 08:45 +07 ngày 2026-11-22; slice 901a3e8a, docs b7ad33d4, GOAL 9c85e4e9, status TBD)

- N2527 DONE + PUSHED ~06:45 +07 ngày 2026-11-22, origin/main == HEAD == 92ad2be6
  (5 commit: slice bd0ea3c8 + docs ef5272e3 + GOAL d19606df + status 07cbccf9 + hashes 92ad2be6).
- N2528 implement xong (worker các lượt cron 07:05–08:15 + chain main-thread):
  1 pure function `source_turret_estimate_dps_state` + register + test + proof,
  chưa commit. Main thread lượt 08:45 xác minh độc lập: targeted 4/4 OK
  (25 subtests, 17.13s, godot-bin trên PATH), register --verify 15/15,
  proof matches:true (8 semantic keys, đọc trực tiếp
  C07TurretEstimateDpsProof.json, mtime 01:46:40Z — tái sinh bởi targeted
  re-run lượt này).
- Chain main-thread (log hidden_files/n2528-chain.log):
  NEIGHBOURS-START 00:49:30Z → EXIT 1 01:06:06Z, **293 passed + 2 failed
  (draw + live_bullets_wiring, cả 2 là flake port-7777: proof matches:true
  nhưng ERROR MCP bind 7777) trong 996.42s**; re-run 2 file isolated
  **8 passed / 62 subtests trong 28.83s** → 295/295 SẠCH (log
  hidden_files/n2528-flake-rerun-mainverify.log);
  WIRING-START 01:06:06Z → EXIT 0 01:08:11Z, **32 tests OK trong 124.397s**.
  (Worker chain 2x START 00:38:40Z + 00:41:19Z, không EXIT, chết theo cron
  timeout — partial giữ riêng hidden_files/n2528-chain-partial-worker-0038.log
  + hidden_files/n2528-neighbours-partial-run1-0040.log.)
- Gate full-suite (chain log hidden_files/n2528-chain.log, log
  tools/mindustry_godot_transpiler/full-suite-n2528-gate.log):
  GATE-START 01:19:38Z (main thread launch, PID 6107, kiểm tra sống sót sau
  50s) → GATE-EXIT 1 01:40:24Z, Ran 6321 trong 1244.580s, failures=257,
  skipped=5 — xác minh độc lập theo FAIL block: **256 × unexpectedly None
  thuần + 1 × hydration pre-existing**
  (test_liquid_consumer_hydration.py:66, baseline hằng số), 0 KeyError,
  0 return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure
  đúng mẫu vs N2527 — đúng 4 test mới, +1 failure là reference-graph test
  của N2528, Godot-absent trong gate env vì chain script reset PATH không có
  godot-bin).
  Lượt này đóng slice: docs + GOAL + status + 5 commit push, Done 1756→1757.
- VM restart #23 lúc 00:40:24Z (PID1 đổi 22:38:41Z → 00:40:24Z). javalang +
  pytest vẫn OK sau restart (xác minh lượt này).
- N2528 = port `estimateDps()` của `TurretBuild` thành 1 pure function cho
  Turret family (leg `!hasAmmo()` → 0.0 TRƯỚC; leg `peekAmmo() == null ? 0f`
  qua param; `shots / reload * 60 * peekDPS * potentialEfficiency * timeScale`).
  Scope khóa lượt 07:05, kiểm tra từ upstream Java + port + catalog trực tiếp
  trên đĩa (scope file hidden_files/n2528-scoping.md).

## Scope (khóa)

- MỘT pure function mới `source_turret_estimate_dps_state` trong
  `godot-mindustry/src/game/SourceTurretBuildState.gd:575` + 1 register file +
  1 test file + 1 proof — KHÔNG driver tick call site (estimateDps() là read
  function, không phải per-tick; không caller nào đọc nó hôm nay, HUD / stats
  display là C11).
- Công thức (Turret.java:329-333, giữ nguyên thứ tự Java):
  `if(!hasAmmo()) return 0f;` → `return shoot.shots / reload * 60f *
  (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency
  * timeScale;`
- Tham số: `frame, has_ammo, has_peek_ammo, peek_ammo_dps, shots, reload,
  time_scale`. Trả đúng 1 key `estimate_dps`.
- `has_ammo` là bool param, KHÔNG tính trong hàm: `hasAmmo()` MUTATES ammo
  stack (`ammo.swap(ammo.size - 1, i);`, Turret.java:703) nên không thể là
  pure read (tiền lệ N2527).
- `peek_ammo_dps` là float param, KHÔNG tính `BulletType.estimateDPS()`
  trong slice này: `estimateDPS()` (BulletType.java:414-435) là đệ quy trên
  bullet catalog (fragBullet/spawnBullets/spawnUnit, `cachedDps` cache) —
  slice riêng N2529. `has_peek_ammo` là bool param cho leg
  `peekAmmo() == null ? 0f` (Turret.java:693-696, tiền lệ `has_peek_ammo`
  của N2526 range).
- `shots` là int param per-def, KHÔNG hardcode 1: default 1
  (ShootPattern.java:9), per-def salvo 2 / ripple 4 / smite 2 / malign 4
  (Blocks.java:3402/:3823/:3902/:4064), đọc từ catalog shoot pattern state.
- `reload` là per-def reload time (default 10f, ReloadTurret.java:10), đọc từ
  catalog `block.properties` với default 10.0 (tiền lệ tick :2665) — KHÔNG
  hardcode duo.
- `60f` là tick rate (`const TICK_RATE := 60.0`, SourceTimeDefaults.gd:4) —
  KHÔNG literal 60.
- `potential_efficiency` đọc từ frame (`frame.get("potential_efficiency",
  1.0)`, fold của SourceBuildingEfficiencyState.gd:178; absent → 1.0, tiền lệ
  N2527). `time_scale` là float param tường minh, KHÔNG đọc từ frame (tiền lệ
  sense, `source_building_comp_sense_state`; `timeScale` là transient field
  BuildingComp.java:98, default 1f).
- Java KHÔNG có guard chia 0 cho `reload` (mọi per-def reload > 0) — giữ
  parity, KHÔNG thêm guard bịa.

## Java evidence (đọc trực tiếp lượt scope)

- `Turret.java:329-333` `estimateDps()`: `public float estimateDps(){` /
  `if(!hasAmmo()) return 0f;` / `return shoot.shots / reload * 60f *
  (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) *
  potentialEfficiency * timeScale;` / `}`
- `ShootPattern.java:9` `public int shots = 1;`
- `ReloadTurret.java:10` `public float reload = 10f;`
- `Turret.java:698-712` `hasAmmo()` MUTATES (`ammo.swap(ammo.size - 1, i);`
  :703); `Turret.java:693-696` `peekAmmo()` trả null khi không có ammo.
- `BuildingComp.java:98` `private transient float timeScale = 1f,
  timeScaleDuration;`
- `BulletType.java:414-435` `estimateDPS()` — CHƯA port (N2529): `sum =
  (damage + splashDamage*0.75f) * (pierce ? pierceCap == -1 ? 2 :
  clamp(pierceCap, 1, 2) : 1f)` + fragBullet đệ quy `* fragBullets / 2f` +
  spawnBullets đệ quy; branch spawnUnit/despawnUnit gọi
  `UnitType.estimateDps()`; `cachedDps` là runtime cache.
- `Turret.java:324-327` base `getAmmoFraction()` trả `1f` hằng — trivial,
  không phải slice; `getAmmoFraction()` + `senseObject currentAmmoType` ĐÃ CÓ
  trong port từ base df47a96 (SourceItemTurretBuildState.gd:133/:549/:89).

## LIVE CONSEQUENCE (ghi rõ trong comment hàm, mẫu N2524/N2527)

- DORMANT live hôm nay: estimateDps() là read function, không caller nào đọc
  nó hôm nay (HUD / stats display là C11), driver tick chưa gọi hàm này →
  live behavior KHÔNG đổi. Khi C11 HUD/stats về, hàm này là canonical owner
  duy nhất của Turret estimateDps().
- Không đổi gameplay: chỉ thêm pure function + register + test + proof.

## Files (mirror N2527)

- `godot-mindustry/src/game/SourceTurretBuildState.gd` — 1 hàm mới
  `source_turret_estimate_dps_state` (:575, defense shard, tiền lệ
  N2523/N2524/N2525/N2526/N2527: Turret.java route về defense).
- `tools/mindustry_godot_transpiler/tests/test_c07_turret_estimate_dps.py`
  (4 tests: registration, input-evidence, state, reference-graph).
- `tools/mindustry_godot_transpiler/register_c07_turret_estimate_dps.py`
  (`--verify`).
- `C07TurretEstimateDpsProof.gd` + `.tscn` (8 semantic keys + registry_valid +
  one_headquarter_per_ssot + matches; proof .json KHÔNG stage).
- SSOT: +1 symbol / +1 Done / +1 contracts / +2 schemas (đo từ đĩa lượt đóng
  slice: 11719/1756/1689/3169 → 11720/1757/1690/3171);
  defense 215/214 → 216/215; comp 572/475 KHÔNG đổi;
  deferred pool 478 → 481 (+3: 1 ghi estimateDps() WIRED/DONE + 1 ghi
  BulletType.estimateDPS() vẫn DEFERRED + 1 nợ Windows).
- Spec Done 1756 → 1757 + row N2528; GOAL §5 thêm dòng nợ Windows sau dòng N2527
  (§5 dòng 490).

## Quy trình lượt implement (theo AGENTS.md + mẫu N2524/N2525/N2526/N2527)

1. RED tests trước (no-ammo → 0.0; no-peek-ammo → 0.0 dù has_ammo true;
   shots/reload/60 scaling; potentialEfficiency 0.5 → một nửa; timeScale 2 →
   gấp đôi; biên reload lớn), chạy targeted xác nhận fail đúng.
2. GREEN minimal → targeted xanh → register `--verify`.
3. Neighbours + wiring + full gate — CHỈ main thread launch (worker KHÔNG
   launch; kiểm tra chain log không có START song song; kiểm tra sống sót sau
   45–60s; kiểm tra lại javalang/pytest sau mỗi VM restart).
4. Godot proof (port 7777 free trước khi chạy; KHÔNG chạy song song với agent kia).
5. Gate xanh (phân rã theo FAIL block: N thuần + 1 hydration pre-existing)
   → commit + push mẫu 5 commit, bump Done 1756→1757. `git diff --check`
   SẠCH. Không stage *.gd.uid / project.godot / arc-upstream/ /
   mindustry-upstream/ / proof .json / full-suite-*.log.

## Deferred / BLOCKED (không đổi sau N2528)

- BulletType.estimateDPS() live computation — DEFERRED, ứng viên N2529
  (BulletType.java:414-435, đệ quy frag/spawn, `cachedDps` cache; C11 HUD /
  stats display đọc `estimate_dps` cũng là slice sau).
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
