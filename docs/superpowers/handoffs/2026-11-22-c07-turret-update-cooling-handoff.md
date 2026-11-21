# Handoff — N2525 Turret `updateCooling()` coolant fold: pure function cho Turret family (C07) [DONE]

## Status: DONE (gate lượt 2 xanh theo mẫu Godot-absent, xác minh độc lập lượt cron 02:15 +07 ngày 2026-11-22; slice commit c4fb3409; chưa push — chờ docs + GOAL + status + hashes)

- N2524 DONE + PUSHED ~00:15 +07 ngày 2026-11-22, origin/main == HEAD == b61fcdd8
  (5 commit: slice 5b4d3ed4 + docs 85b66637 + GOAL ea731672 + status ed9bdf54 + hashes b61fcdd8).
- N2525 implement xong (worker lượt cron 01:00): 1 pure function
  `source_turret_cooling_state` + register + test + proof, chưa commit.
  Main thread lượt 01:15 xác minh độc lập: targeted 4/4 OK (14.0s, godot-bin trên
  PATH — lần chạy đầu 3/4 chỉ vì `godot` không có trên PATH của shell cron, không
  phải lỗi slice), register --verify 17/17, proof matches:true (5/5 semantic keys,
  đọc trực tiếp C07TurretCoolingProof.json).
- Chain main-thread lượt 01:00 (n2525-chain-main.sh, log hidden_files/n2525-chain.log):
  NEIGHBOURS-START 17:59:02Z → EXIT 0 18:14:53Z, **283 passed trong 950.91s, 0 fail**
  (+4 tests so với N2524 = đúng 4 test mới); WIRING-START 18:14:53Z → EXIT 0
  18:17:01Z, **32 tests OK trong 127.278s**.
- Gate full-suite đang chạy (n2525-gate-only-main.sh, main thread, GATE-START
  18:19:51Z, PID 13333; kiểm tra sống sót 18:20:44Z: unittest discover 13337 chạy,
  log full-suite-n2525-gate.log đang ghi). Dự kiến xong ~18:41Z. Lượt cron sau
  xác minh gate theo FAIL block (kỳ vọng 253+1: 252 None thuần + 1 hydration
  pre-existing, 0 KeyError/ERROR) rồi mới đóng slice (docs + GOAL + status +
  5 commit push, Done 1753→1754).
- **CẬP NHẬT lượt cron 01:45 +07: gate lượt 1 CHẾT do VM restart ~18:38Z**
  (systemd start 18:38, log đóng băng 18:38:37, không GATE-EXIT, không còn
  pytest; partial log giữ riêng hidden_files/full-suite-n2525-gate-partial-run1-1838.log).
  Restart wipe javalang + pytest → cài lại 0.13.0 / 9.2.0 OK. Gate lượt 2 relaunch
  main thread GATE-START 18:46:37Z (PID 2807), sống sót sau 50s, đang chạy;
  dự kiến xong ~19:07Z. Lượt cron sau xác minh rồi mới đóng slice. HEAD vẫn
  b61fcdd8 (N2524); N2525 chưa commit/push — đúng quy trình.
- **CẬP NHẬT lượt cron 02:15 +07: gate lượt 2 XONG, slice ĐÓNG được.**
  GATE-EXIT 1 19:07:15Z (log tools/mindustry_godot_transpiler/full-suite-n2525-gate.log):
  Ran 6309 trong 1236.512s, failures=254, skipped=5 — xác minh độc lập theo FAIL
  block: **253 × unexpectedly None thuần + 1 × hydration pre-existing**
  (test_liquid_consumer_hydration, baseline hằng số), 0 KeyError, 0
  return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng
  mẫu vs N2524). Main thread xác minh lại lượt này: targeted 4/4 OK (14.7s,
  godot-bin trên PATH, port 7777 free), register --verify 17/17, proof
  matches:true (5 semantic keys + registry_valid + one_headquarter_per_ssot +
  matches = 8/8, đọc trực tiếp C07TurretCoolingProof.json, mtime 19:19Z —
  tạo lại bởi targeted re-run lượt này, nội dung không đổi), neighbours
  283/283 (950.91s, log n2525-neighbours.log), wiring 32 OK (127.278s, log
  n2525-wiring.log), `git diff --check` SẠCH. SSOT đo từ đĩa:
  **11715/1754/1687/3165** — symbols +3 (không phải +1 như ước tính scope:
  register thêm 3 result symbol reload_counter/cooling_applied/coolant_consumed);
  defense 213/212 (+1/+1), comp 572/475 không đổi; deferred pool 472 (469 + 3).
  Slice commit c4fb3409 (11 file, 1497 insertions, 0 deletions). Lượt này đóng
  slice: docs + GOAL + status + 5 commit push, Done 1753→1754.
- N2525 = port `updateCooling()` của ReloadTurret (ReloadTurret.java:28-38) thành 1 pure
  function cho Turret family — Turret-family instance của pattern N2248
  (PointDefenseTurret coolant efficiency, no driver tick). Scope khóa lượt này, kiểm tra
  từ upstream Java + port + catalog trực tiếp trên đĩa.

## Scope (khóa)

- MỘT pure function mới `source_turret_cooling_state` trong
  `godot-mindustry/src/game/SourceTurretBuildState.gd` (mirror
  `source_point_defense_turret_cooling_state`, N2248) + 1 register file +
  1 test file + 1 proof — KHÔNG driver tick call site (frame chưa có liquid state;
  coolant efficiency / coolant amount / heat_capacity chưa có live source).
- Công thức (ReloadTurret.java:28-38, giữ nguyên thứ tự Java):
  gate `canReload() && coolant != null && coolant.efficiency(this) > 0 && efficiency > 0`
  (`canReload()` = `reloadCounter < reload`, ReloadTurret.java:46-48);
  `amount = coolant.amount * coolant.efficiency(this)` (:31);
  `coolant.update(this)` gỡ `amount * edelta() * multiplier` — pure function trả
  `coolant_consumed` để slice wiring sau áp dụng (mẫu N2248: frame chưa có liquid
  inventory, không ghi trực tiếp);
  `reloadCounter += amount * edelta() * capacity * coolantMultiplier * ammoReloadMultiplier();` (:33).
- Tham số (mẫu N2248, truyền vào thay vì đọc frame — frame chưa có các key này):
  `frame, has_coolant, coolant_amount, coolant_efficiency, heat_capacity,
  coolant_multiplier, ammo_reload_multiplier, reload, edelta`.
  Trả `{reload_counter, cooling_applied, coolant_consumed}`; gate fail → không đổi
  `reload_counter`, `cooling_applied=false`, `coolant_consumed=0.0`.
- `coolantMultiplier` = 5f cho Turret family (`coolantMultiplier = 5f;`,
  BaseTurret.java:32 — KHÔNG override ở ItemTurret/Turret/PowerTurret; chỉ
  PointDefenseTurret 2f, LaserTurret/ContinuousTurret/TractorBeamTurret 1f).
  Truyền qua tham số, test dùng 5f cho duo/scatter/salvo/foreshadow.
- `ammoReloadMultiplier()` = Turret.java:727 override
  (`return hasAmmo() ? peekAmmo().reloadMultiplier : 1f;`) — KHÁC default 1f của
  ReloadTurret.java:41-43. Truyền qua tham số `ammo_reload_multiplier`; live
  peekAmmo wiring là slice sau (frame chưa stamp peeked reloadMultiplier).
- `capacity` = heatCapacity của liquid bị tiêu thụ
  (`coolant instanceof ConsumeLiquidFilter filter ? filter.getConsumed(this).heatCapacity
  : (coolant.consumes(liquids.current()) ? liquids.current().heatCapacity : 0.4f);`,
  :30 — ConsumeCoolant extends ConsumeLiquidFilter nên nhánh filter áp dụng).
  Truyền qua tham số `heat_capacity`; fallback 0.4f thuộc slice coolant-pick, không
  hard-code trong hàm này.
- `edelta()` = `efficiency * delta()` (BuildingComp.java:1927-1929), truyền vào
  precomputed (tiền lệ N2240/N2248).
- CoolEffect chance (`if(Mathf.chance(0.06 * amount)){`, :35) là visual ngẫu nhiên,
  KHÔNG trong pure function (tiền lệ N2240 random-pitch).
- Call-site Java để slice driver-tick sau dùng (KHÔNG làm trong N2525):
  `Turret.java:550` — `if(reloadWhileCharging || !charging()){ updateReload();
  updateCooling(); }` ("turret always reloads regardless of whether it's targeting
  something"). Gate `reloadWhileCharging || !charging()` là việc của driver tick,
  không đưa vào pure function.

## Java evidence (đọc trực tiếp lượt scope)

- `ReloadTurretBuild.updateCooling()` (ReloadTurret.java:28-38) — implementation chung
  cho mọi ReloadTurret subclass; `Turret.java:550` là call site duy nhất của family.
- `LaserTurret.java:48-50` override updateCooling thành no-op
  ("do nothing, cooling is irrelevant here"); `ContinuousTurret.java:49-51` override
  thành no-op (TODO) — cả hai NGOÀI scope N2525; meltdown (LaserTurret,
  coolant 0.5f, Blocks.java:4346) không dùng hàm này.
- `BaseTurret.init` tìm coolant (`coolant = findConsumer(c -> c instanceof
  ConsumeCoolant);`, BaseTurret.java:50-52) + `coolant.update = false; coolant.booster
  = true; coolant.optional = true;` (:71-74).
- ConsumeCoolant filter (ConsumeCoolant.java:14, 20-22; ConsumeLiquidFilter.java:50-56,
  63-79): efficiency = `min(liquids.get(liq) / (amount * ed * multiplier), 1f)`,
  0 khi không có liquid — N2248 đã port phần này thành
  `source_point_defense_turret_coolant_state`; lượt implement N2525 kiểm tra tái dùng
  hàm đó as-is cho Turret family (logic class-level, không PointDefense-specific)
  thay vì viết twin mới — chưa khẳng định, để lượt implement quyết.
- Coolant defs (đối chiếu trực tiếp Blocks.java, 14 site `consumeCoolant`, mỗi site
  map về def `new XTurret("slug")` gần nhất phía trên): duo 0.1f (:3324),
  scatter 0.2f (:3411), scorch 0.1f (:3458), hail 0.1f (:3522), lancer 0.2f (:3578,
  PowerTurret), arc 0.1f (:3637, PowerTurret), swarmer 0.3f (:3726), salvo 0.2f
  (:3831), fuse 0.3f (:3931), ripple 0.3f (:4077), cyclone 0.3f (:4195),
  foreshadow 1f (:4242), spectre 1f (:4308), meltdown 0.5f (:4346, LaserTurret —
  no-op). PowerTurret (lancer/arc) cũng dùng chung ReloadTurret.updateCooling
  (PowerTurret extends Turret, không override updateCooling).
- Catalog `content_registry.json`: `coolant` KHÔNG có trong properties của bất kỳ block
  nào (kiểm tra trực tiếp: `any('coolant' in props)` = False) — driver tick KHÔNG
  thể đọc coolant amount từ catalog hôm nay; đó là lý do N2525 pure-function-only.
  `reload` thì có (duo 20.0, scatter 18.0, lancer 80.0, salvo 29.0, fuse 35.0,
  foreshadow 200.0, meltdown 90.0).

## LIVE CONSEQUENCE (ghi rõ trong comment hàm, mẫu N2241/N2524)

- DORMANT live hôm nay: frame turret chưa có liquid state, `coolant_efficiency`
  chưa có live source → driver tick chưa gọi hàm này; live behavior KHÔNG đổi.
  Khi liquid-module wiring về, gate mở cho các def có coolant + liquid (duo có
  coolant 0.1f nhưng hasLiquids false → efficiency 0 → vẫn no-op; các def có
  liquid thật mới boost reload).
- Không đổi gameplay: chỉ thêm pure function + register + test + proof.

## Files (dự kiến, mirror N2248)

- `godot-mindustry/src/game/SourceTurretBuildState.gd` — 1 hàm mới
  `source_turret_cooling_state` (defense shard, tiền lệ N2523/N2524: Turret.java
  route về defense).
- `tools/mindustry_godot_transpiler/tests/test_c07_turret_cooling.py` (mirror
  `test_c07_point_defense_turret_coolant.py`, N2248).
- `tools/mindustry_godot_transpiler/register_c07_turret_cooling.py` (mirror
  `register_c07_point_defense_turret_coolant.py`; `--verify`).
- `C07TurretCoolingProof.gd` + `.tscn` (5 semantic keys + registry_valid +
  one_headquarter_per_ssot + matches; proof .json KHÔNG stage).
- SSOT: +3 symbols / +1 Done / +1 contracts / +2 schemas (đo từ đĩa lượt đóng
  slice, sửa ước tính scope 11713 → 11715: 11712/1753/1686/3163 →
  11715/1754/1687/3165); defense 212/211 → 213/212;
  comp 572/475 KHÔNG đổi; deferred pool 469 → 472 (+3: 1 ghi updateCooling fold
  WIRED + 1 ghi driver-tick call site vẫn DEFERRED + 1 nợ Windows).
- Spec Done 1753 → 1754 + row N2525; GOAL §5 thêm dòng nợ Windows sau dòng N2524
  (§5 dòng 484).

## Quy trình lượt implement (theo AGENTS.md + mẫu N2524)

1. RED tests trước, chạy targeted xác nhận fail đúng.
2. GREEN minimal → targeted xanh → register `--verify`.
3. Neighbours + wiring + full gate — CHỈ main thread launch (worker KHÔNG launch;
   kiểm tra chain log không có START song song trước khi launch; kiểm tra sống sót
   sau 45–60s; javalang/pytest kiểm tra lại sau mỗi VM restart).
4. Godot proof (port 7777 free trước khi chạy; KHÔNG chạy song song với agent kia).
5. Gate xanh (phân rã theo FAIL block: N thuần + 1 hydration pre-existing) →
   commit + push mẫu 5 commit (slice + docs + GOAL + status + hashes), bump Done
   1753→1754. `git diff --check` SẠCH. Không stage *.gd.uid / project.godot /
   arc-upstream/ / mindustry-upstream/ / proof .json.

## Deferred / BLOCKED (không đổi sau N2525-scope)

- Turret sense frame per-graph split — DEFERRED (chờ PowerGraph.addGraph merge port;
  `addGraph` hiện chỉ là source-text constant `java_method_addGraph_20`, chưa port).
- Compose SenseI leg (N2510) với dispatch ở caller — chờ logic-executor driver
  (chưa có LExecutor instruction loop trong port).
- Live player-unit source cho `unit_is_player` — chờ player control.
- Turret liquid-module wiring (frame liquid state + coolant pick live) — BLOCKED
  cho driver tick của hàm N2525; coolant amount trong catalog chưa có.
- LaserTurret/ContinuousTurret updateCooling overrides (no-op) — ngoài scope, không
  cần slice riêng trừ khi Java đổi.
- calculateHeat — BLOCKED (live entity scan); findTarget — BLOCKED (live entity scan).
