# Handoff — N2524 Turret `shouldConsume()` gate: live `isShooting || reloadCounter < reload` into the consumption branch (C07, duo + power turrets) [DONE]

## Status: DONE (slice 5b4d3ed4, docs TBD, GOAL TBD; cập nhật lượt cron 00:15 +07 ngày 2026-11-22 — chain + gate xong GATE-EXIT 1 17:11:10Z, Ran 6305 trong 1244.787s, failures=253, skipped=5, errors=0; xác minh độc lập: 253 FAIL = 252 × unexpectedly None thuần + 1 × unexpectedly None : Godot required for hydration proof (1 failure block pre-existing, chuỗi xuất hiện 2 lần trong cùng block), 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours 279/279 (0 fail), WIRING-EXIT 0 16:25:51Z; wiring XONG 32 tests OK. N2523 đã DONE + PUSHED (eff1a4b3). Slice commit 5b4d3ed4, docs TBD, GOAL TBD, status TBD. Targeted 4/4 OK (main thread xác minh lượt này, 39 subtests, 19.18s, godot-bin trên PATH, port 7777 free); register --verify 30/30; proof matches:true 8/8 (5 semantic keys, đọc trực tiếp proof .json, mtime 17:17Z — .json được tạo lại bởi targeted re-run lượt này); SSOT đo từ đĩa 11712/1753/1686/3163; `git diff --check` SẠCH.

- N2523 DONE + PUSHED ~22:26 +07 ngày 2026-11-21, origin/main == HEAD == eff1a4b3.
- **N2524 GREEN xong ~23:34 +07 ngày 2026-11-21, lượt cron 00:15 +07 ngày 2026-11-22**: turret
  driver tick wire live `TurretBuild.shouldConsume()` gate vào
  consumption branch — 1 pure function mới
  `source_turret_should_consume_state`
  (SourceTurretBuildState.gd:338) + 1 call site trong
  `source_turret_tick_buildings_state` (:2537-2538, consumption
  branch). Gate thay dòng `should_consume=true when enabled`
  bằng predicate Java `isShooting || reloadCounter < reload`,
  để một turret có power consumer ngừng tiêu thụ điện khi vừa
  không bắn vừa đã nạp đầy.
- **Xác minh độc lập lượt cron 00:15 +07 (lượt này, đọc trực
  tiếp từ đĩa + log)**: targeted **4/4 OK (main thread xác minh,
  39 subtests, 19.18s, godot-bin trên PATH, port 7777 free)**;
  register `--verify` **30/30** (main thread xác minh); proof
  **matches:true, 8/8 keys, 5 semantic all true** (đọc trực tiếp
  `C07TurretShouldConsumeProof.json`, mtime 17:17Z — .json được
  tạo lại bởi targeted re-run của main thread lượt này, nội dung
  không đổi; 5 key: should_consume_shooting / reloading /
  idle_reloaded / efficiency_fold_zero / efficiency_kept);
  SSOT đo từ đĩa **11712/1753/1686/3163** — đúng kỳ vọng (+1
  symbols / +1 Done / +1 contracts / +2 schemas — 1 hàm mới);
  defense **212/211** (+1/+1, N2524 vào defense shard —
  java_source Turret.java, tiền lệ N2523); comp **572/475
  KHÔNG đổi**; deferred pool **469** (466 + 3, đúng 3 entry mới,
  0 entry bị xóa); ledger N2524 status done, java_source
  Turret.java, godot_owner
  `SourceTurretBuildState.source_turret_should_consume_state`.
  `git diff --check` SẠCH.
- **Neighbours 279/279** (chain log
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2524-neighbours.log`:
  279 passed trong 944.36s, 0 fail, NEIGHBOURS-EXIT 0
  16:23:42Z) + **wiring XONG 32 tests OK** (WIRING-EXIT 0
  16:25:51Z, Ran 32 tests trong 128.669s, OK).
- **Gate XONG (chain log trên, GATE-START 16:50:22Z, GATE-EXIT 1
  17:11:10Z)** — xác minh độc lập lượt cron 00:15 +07 (đọc trực
  tiếp log `tools/mindustry_godot_transpiler/full-suite-n2524-gate.log`):
  Ran 6305 trong 1244.787s, failures=253, skipped=5, errors=0 —
  253 FAIL blocks, 0 ERROR, 0 KeyError, 0
  `return_schema_linkage`; phân rã theo FAIL block: 252 ×
  `AssertionError: unexpectedly None` thuần + 1 × `AssertionError:
  unexpectedly None : Godot required for hydration proof`
  (test_liquid_consumer_hydration.py:66 — pre-existing baseline,
  chuỗi hydration xuất hiện 2 lần cho cùng 1 block: dòng assert
  trong traceback + dòng AssertionError; hydration là hằng số:
  N2518 = 246 thuần + 1, N2519 = 247 + 1, N2520 = 248 + 1, N2521
  = 249 + 1, N2522 = 250 + 1, N2523 = 251 + 1, N2524 = 252 + 1),
  toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2523 —
  đúng 4 test mới của N2524, +1 failure là reference-graph test
  của N2524, Godot-absent vì gate script reset PATH không có
  godot-bin).
- **Commit 1 gồm 11 file** (7 sửa + 4 mới — main thread đã xác
  minh từ đĩa; đối chiếu mẫu N2523: slice commit 80bb3601 = 12
  file).
- **Gate xanh — commit + push theo mẫu 5 commit (slice 5b4d3ed4).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2524-chain-main.sh`
  (neighbours + wiring, NO gate) và
  `hidden_files/n2524-gate-only-main.sh` (gate-only; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Chain + gate chạy từ main thread lượt cron 00:15 +07
  (worker scope cấm chạy neighbours/wiring/gate; worker báo
  GREEN-only — chain log `hidden_files/n2524-chain.log`):
  NEIGHBOURS-START 16:07:57Z,
  NEIGHBOURS-EXIT 0 16:23:42Z (279 passed, 0 fail),
  WIRING-START 16:23:42Z,
  WIRING-EXIT 0 16:25:51Z,
  GATE-START 16:50:24Z (run 3, gate-only-main.sh, main thread —
  run 2, GATE-START 16:47:17Z, chết ~16:49Z do worker-launch,
  partial log
  `tools/mindustry_godot_transpiler/full-suite-n2524-gate-partial-run2-1647.log`
  đã giữ),
  GATE-EXIT 1 17:11:10Z.
  Ran 6305, failures=253 toàn Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2523,
  nhớ bump Done total 1752→1753 + row N2524 trong spec; defense
  212/211, comp 572/475 KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt scope, không đổi — trừ thiết kế reload đã chỉnh)

- N2524 = wire `TurretBuild.shouldConsume()` vào consumption
  branch của turret driver tick, để một turret có power
  consumer ngừng tiêu thụ điện khi vừa không bắn vừa đã nạp đầy
  — thay cho approximation "machinery runs with
  should_consume=true when enabled" trong tick.
- Số slice N2524, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2523, xác minh lượt scope).
- MỘT pure function + MỘT tick call site (không phải hai slice:
  một mechanism, một tick, một frame key — các call khác KHÔNG
  đổi). Hàm gate trả đúng 1 key (`should_consume`, mẫu N2241).
  `reload` KHÔNG tra bằng match inline — tick đọc từ catalog
  `float(block.properties.get("reload", 10.0))` (tiền lệ N2270
  `heatRequirement`); catalog `content_registry.json`
  blocks[].properties mang reload đúng Blocks.java cho cả 7 def
  (lancer 80.0, arc 35.0, foreshadow 200.0, meltdown 90.0,
  afflict 50.0, malign 3.5, duo 20.0) và consumePower cũng khớp.
- Gate DORMANT live hôm nay: duo KHÔNG có consumePower →
  consumption branch không bao giờ chạy cho duo; 6 def có điện
  KHÔNG có aim/shoot branch nào stamp `is_shooting` /
  `reload_counter` → đọc default absent → gate = true = đúng
  `should_consume` hôm nay. Live behavior KHÔNG đổi trên mọi
  frame hiện tại. Comment LIVE CONSEQUENCE trong hàm PHẢI ghi rõ
  dormant này (mẫu N2241), không được viết như thể gate đã đổi
  behavior live.
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_turret_should_consume.py`
  (4 test methods, 5 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_turret_should_consume.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 30/30).
- Proof `C07TurretShouldConsumeProof.gd` + `.tscn` (5 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 8).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `TurretBuild.shouldConsume()` (`public boolean shouldConsume(){` /
  `return isShooting || reloadCounter < reload; }`,
  Turret.java:364-366) — one-line predicate trên 2 field của chính
  turret build.
- Cả 2 input đều đã live trên frame sau N2240/N2277:
  - `isShooting` — Turret.java:492, port N2277
    (`source_turret_is_shooting_state`, tick stamp
    `frame["is_shooting"]` trong duo branch);
  - `reloadCounter` — ReloadTurret.java:26, port N2240 (aim call
    stamp `frame["reload_counter"]` trong duo branch).
- Thứ tự Java: `updateConsumption()` chạy TRƯỚC `updateTile()`
  (BuildingComp.java:2274 vs :2277) — nên gate đọc giá trị frame của
  tick TRƯỚC (tiền lệ N2270 heat fold đọc `heat_req` tick trước,
  comment N2280 is_active). Call site nằm trong consumption branch
  (:2537-2538), chạy trước duo branch trong cùng một lần tick.
- Hiệu ứng quan sát được khi gate false:
  `update_consumption_setup_state` trả `update = should_consume and
  production_valid` (SourceBuildingEfficiencyState.gd:106-107), rồi
  `update_consumption_efficiency_state` gán `efficiency = 0.0`
  (:127-134) — turret ngừng tiêu thụ, đúng Java
  (BuildingComp.java:1947, `efficiency = ... shouldConsume() ?
  potentialEfficiency : 0f;`).
- `reload` mặc định của class là 10f (ReloadTurret.java:10);
  `canReload()` (:46-48, `return reloadCounter < reload;`) là đúng
  nửa sau của predicate — KHÔNG phải function riêng, không port thêm.
- Tiền lệ gia đình: N2241 đã làm đúng gate này cho PointDefenseTurret
  (`source_point_defense_turret_should_consume_state`, đọc
  `enabled && target != null` từ frame, kèm comment LIVE CONSEQUENCE
  trung thực); N2124 đã làm per-class `shouldConsume()` cho
  UnitFactory/Reconstructor/UnitAssembler. N2524 là Turret-family
  instance của cùng pattern — `TurretBuild` KHÔNG nằm trong chuỗi
  super của PointDefenseBuild (N2241 đã ghi rõ), nên đây là slice
  riêng, không trùng N2241.

## Tiếp theo (sau N2524)

- Slice tiếp theo (N2525) cần scope mới từ backlog — kiểm tra `git
  log --all` trước khi chọn số (N2285–N2505 đã có trên branch
  khác). Ứng viên: per-graph split (building→graph lookup theo
  connectivity — chờ PowerGraph.addGraph merge port); compose
  SenseI leg (N2510) với dispatch ở caller (chờ logic-executor
  driver); live player-unit source cho `unit_is_player` (khi
  player control về, tick truyền live value thay false);
  updateCooling coolant fold (ReloadTurret.java:28-39 — chờ turret
  liquid-module wiring, entry mới sau N2524).
  calculateHeat vẫn BLOCKED (live entity scan); findTarget vẫn
  BLOCKED.

## Deferred (không đổi + mới)

- Turret sense frame stamp per-graph split — DEFERRED (vẫn, sau
  N2524): Java đọc graph RIÊNG của từng building
  (`power.graph.getLastScaledPowerIn()`, BuildingComp.java:2113-2116);
  port gom MỌI building đã đặt vào MỘT graph (`_group_state`,
  SourcePlacedPowerGraphState.gd:254-284, không có connectivity
  split — `PowerGraph.addGraph` merge chưa port), nên lookup
  building→graph CHÍNH LÀ single global placed graph; per-graph
  split chờ connectivity grouping.
- Non-duo ItemTurret drivers (scatter / salvo / ...) — their
  frames are not stamped until their own tick drivers land.
- Composing the SenseI LAccess leg (N2510) with the dispatch at
  the caller — waits for a logic-executor driver (no LExecutor
  instruction loop exists in the port yet); the stamped frame is
  the input that caller will read.
- Live player-unit source for `unit_is_player` (and for
  `unit_sense_value`, N2520) — DEFERRED (still, after N2524): when
  player control lands, the tick passes the live value instead of
  `false` / `0.0`. Turret control() shootp live wiring — logic
  executor not yet in driver. LaserTurret shouldConsume() consumer
  wiring (needs bullets live list). validateTarget effective-team
  live wiring (waits for findTarget).
- updateCooling coolant fold (ReloadTurret.java:28-39) — DEFERRED
  (mới, sau N2524): needs turret liquid-module state; the frame
  carries no liquid state today.
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity scan.
