# Handoff — N2523 Turret `controlled` frame stamp: live `unit.isPlayer()` key into the frame (C07, duo) [DONE]

## Status: DONE + PUSHED (slice 80bb3601, docs fc96b411, GOAL 1850c9f9; cập nhật lượt cron 22:15 +07 — chain + gate xong GATE-EXIT 1 15:11:14Z, Ran 6301 trong 1250.516s, failures=252, skipped=5; xác minh độc lập: 252 FAIL = 251 × unexpectedly None thuần + 1 × unexpectedly None : Godot required for hydration proof (1 failure block pre-existing, chuỗi xuất hiện 2 lần trong cùng block), 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours 275/275 (0 fail), WIRING-EXIT 0 14:49:06Z; wiring XONG 32 tests OK. N2522 đã DONE + PUSHED (98e341aa). Slice commit 80bb3601, docs fc96b411, GOAL 1850c9f9, status 6687ffbf. Targeted 4/4 OK (main thread xác minh lượt này, 16.674s, godot-bin trên PATH); register --verify 10/10; proof matches:true 8/8 (5 semantic keys, đọc trực tiếp proof .json, mtime 14:46Z + chạy lại 15:18:57Z); SSOT đo từ đĩa 11711/1752/1685/3161; `git diff --check` SẠCH.

- N2522 DONE + PUSHED ~20:37 +07, origin/main == HEAD == 98e341aa.
- **N2523 GREEN xong ~21:46 +07, lượt cron 22:15 +07**: turret
  driver tick stamp live `controlled` key vào frame cho 3 reader
  đã đọc nó từ trước — 1 pure function mới
  `source_turret_controlled_stamp_state`
  (SourceTurretBuildState.gd:401) + 1 call site trong
  `source_turret_tick_buildings_state` (:2655, ngay trước
  validate). Ba reader ngừng đọc default absent: validateTarget
  (:2604, N2251), isShooting (:2623, N2277), warmup (:2649,
  N2253).
- **Xác minh độc lập lượt cron 22:15 +07 (lượt này, đọc trực tiếp
  từ đĩa + log)**: targeted **4/4 OK (main thread xác minh,
  16.674s, godot-bin trên PATH, port 7777 free)**; register
  `--verify` **10/10** (main thread xác minh); proof
  **matches:true, 8/8 keys, 5 semantic all true** (đọc trực tiếp
  `C07TurretControlledStampProof.json`, mtime 14:46Z — stamp
  false / stamp true / composed validate / isShooting player
  branch / warmup hold skipped; chạy lại targeted lượt này
  15:18:57Z vẫn matches:true); SSOT đo từ đĩa **11711/1752/1685/
  3161** — đúng kỳ vọng (+1 symbols / +1 Done / +1 contracts /
  +2 schemas — 1 hàm mới); defense **211/210** (+1/+1, N2523 vào
  defense shard — java_source Turret.java; **scope file ghi comp
  573/476 là SAI routing, đính chính lượt này**); comp **572/475
  KHÔNG đổi**; deferred pool **466** (463 + 3, đúng 3 entry mới,
  0 entry bị xóa); ledger N2523 status done, java_source
  Turret.java, godot_owner
  `SourceTurretBuildState.source_turret_controlled_stamp_state`.
  `git diff --check` SẠCH.
- **Neighbours 275/275** (chain log
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2523-neighbours.log`:
  275 passed trong 911.77s, 0 fail, NEIGHBOURS-EXIT 0
  14:47:01Z) + **wiring XONG 32 tests OK** (WIRING-EXIT 0
  14:49:06Z, Ran 32 tests trong 125.493s, OK).
- **Gate XONG (chain log trên, GATE-START 14:50:22Z, GATE-EXIT 1
  15:11:14Z)** — xác minh độc lập lượt cron 22:15 +07 (đọc trực
  tiếp log `tools/mindustry_godot_transpiler/full-suite-n2523-gate.log`,
  169319 byte): Ran 6301 trong 1250.516s, failures=252,
  skipped=5 — 252 FAIL blocks, 0 ERROR, 0 KeyError, 0
  `return_schema_linkage`; phân rã theo FAIL block: 251 ×
  `AssertionError: unexpectedly None` thuần + 1 × `AssertionError:
  unexpectedly None : Godot required for hydration proof`
  (test_liquid_consumer_hydration.py:66 — pre-existing baseline,
  chuỗi hydration xuất hiện 2 lần cho cùng 1 block: dòng assert
  trong traceback + dòng AssertionError; hydration là hằng số:
  N2518 = 246 thuần + 1, N2519 = 247 + 1, N2520 = 248 + 1, N2521
  = 249 + 1, N2522 = 250 + 1, N2523 = 251 + 1), toàn Godot-absent
  (+4 tests / +1 failure đúng mẫu vs N2522 — đúng 4 test mới của
  N2523, +1 failure là reference-graph test của N2523, Godot-absent
  vì gate script reset PATH không có godot-bin).
- **HỒI QUY THẬT + FIX (không phải flake)**: neighbours run 1
  xong 274/275, 1 fail là N2251 validate_target reference-graph
  (`validate_controlled_saves_invalid_target: False`) — bản stamp
  đầu ghi đè `controlled=true` của proof bằng literal `false`;
  re-run isolated fail y hệt (port free) chứng minh stamp là
  nguyên nhân. Fix: rescue chạy từ `unit_is_player` (tick :2655
  + proof segment 4 `frames[4]["unit_is_player"] = true`, tiền lệ
  N2278 logic_control_time) — verified 8 passed / 56 subtests
  (targeted + N2251 cùng nhau), proof N2251 matches:true 11/11
  (8 semantic, .json mtime 14:35Z, đọc trực tiếp).
- **Commit 1 gồm 12 file** (8 sửa + 4 mới — main thread đã xác
  minh từ đĩa; đối chiếu mẫu N2522: slice commit a9cae2a9 = 13
  file = 9 sửa + 4 mới).
- **Gate xanh — commit + push theo mẫu 5 commit (slice 80bb3601).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2523-chain-main.sh`
  (neighbours + wiring, NO gate) và
  `hidden_files/n2523-gate-only-main.sh` (gate-only; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Chain + gate chạy từ main thread lượt cron 22:15 +07
  (worker scope cấm chạy neighbours/wiring/gate; worker báo
  GREEN-only — chain log `hidden_files/n2523-chain.log`):
  NEIGHBOURS-START 14:31:48Z (run 3 — run 2 chết ~60s sau launch
  do exec timeout dù setsid, log
  `n2523-neighbours-relaunch-dead-1428.log`),
  NEIGHBOURS-EXIT 0 14:47:01Z (275 passed, 0 fail),
  WIRING-EXIT 0 14:49:06Z,
  GATE-START 14:50:22Z (gate-only-main.sh, main thread),
  GATE-EXIT 1 15:11:14Z.
  Ran 6301, failures=252 toàn Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2522,
  nhớ bump Done total 1751→1752 + row N2523 trong spec; defense
  211/210, comp 572/475 KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt scope, không đổi — trừ routing shard)

- N2523 = stamp live `controlled` key mà turret driver tick CÓ
  THỂ cung cấp hôm nay vào frame, để 3 reader (validate /
  isShooting / warmup) ngừng đọc default absent.
- Số slice N2523, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2522, xác minh lượt scope).
- MỘT pure function + MỘT tick call site (không phải hai slice:
  một mechanism, một tick, một frame key — validate / isShooting /
  warmup calls KHÔNG đổi, chỉ ngừng đọc key absent). Hàm stamp ghi
  đúng 1 key (`frame["controlled"] = unit_is_player`), trả về
  frame (tiền lệ N2108). Tick truyền `bool(frame.get(
  "unit_is_player", false))` — KHÔNG có player unit trong port
  hôm nay nên false với mọi live turret (tiền lệ N2520); khi
  player control về, tick truyền live value, hàm stamp không đổi.
- Tick KHÔNG bịa player, KHÔNG chạm `source_turret_unit_sync_state`
  (N2260), KHÔNG đổi argument của 3 call — giá trị của chúng giống
  hệt trên mọi frame hiện tại (absent default false == stamped
  false), nên test N2251/N2277/N2253 không cần đổi (trừ proof
  segment 4 của N2251 — xem fix hồi quy trên).
- **Routing shard ĐÍNH CHÍNH lượt này**: scope file ghi comp
  573/476 là sai — N2523 vào defense shard (java_source
  Turret.java, defense 211/210), comp giữ 572/475.
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_turret_controlled_stamp.py`
  (4 test methods, 5 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_turret_controlled_stamp.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 10/10).
- Proof `C07TurretControlledStampProof.gd` + `.tscn` (5 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 8).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `TurretBuild.controlled()` (`public boolean controlled(){ return
  unit.isPlayer(); }`, Turret.java:441-443) — one-line predicate
  trên unit của chính turret.
- Unit là BlockUnitc tạo per turret: `public BlockUnitc unit =
  (BlockUnitc)UnitTypes.block.create(team);` (Turret.java:291),
  sync mỗi tick bởi updateTile :529-531 (N2260 đã port).
- Callers trong updateTile: validateTarget :491 (`return
  !Units.invalidateTarget(...) || controlled() ||
  logicControlled();`, Turret.java:631-633); isShooting :492
  (`unit.controller() instanceof Player ? unit.isShooting() :
  logicControlled() ? logicShooting : target != null`,
  Turret.java:492); warmup gate :503 (`if(warmupTarget > 0 &&
  !controlled()){ warmupHold = 1f; }`, Turret.java:503); player
  behavior branches :576/:588 (`if(controlled()){ //player
  behavior`, Turret.java:576).
- `logicControlled()` là sibling predicate (`return
  logicControlTime > 0;`, Turret.java:445-447) — đã live qua
  N2278 stamp (`source_turret_logic_controlled_state`, tick stamp
  `frame["logic_controlled"]` ngay TRƯỚC validate call). N2523
  mirror nó cho `controlled()`.
- Tick là TurretBuild.updateTile() (`public void updateTile(){`,
  Turret.java:490), chạy cho mọi Turret-family build tick đã visit.
- Leg `controlled` trong dispatch đã port (N2519, `case controlled
  -> ... ? GlobalVars.ctrlPlayer : 0;`, BuildingComp.java:77) —
  slice này KHÔNG chạm dispatch hay leg function nào.

## Tiếp theo (sau N2523)

- Slice tiếp theo (N2524) cần scope mới từ backlog — kiểm tra `git
  log --all` trước khi chọn số (N2285–N2505 đã có trên branch
  khác). Ứng viên: per-graph split (building→graph lookup theo
  connectivity — chờ PowerGraph.addGraph merge port); compose
  SenseI leg (N2510) với dispatch ở caller (chờ logic-executor
  driver); live player-unit source cho `unit_is_player` (khi
  player control về, tick truyền live value thay false).
  calculateHeat vẫn BLOCKED (live entity scan); findTarget vẫn
  BLOCKED.

## Deferred (không đổi + mới)

- Turret sense frame stamp per-graph split — DEFERRED (vẫn, sau
  N2523): Java đọc graph RIÊNG của từng building
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
  `unit_sense_value`, N2520) — DEFERRED (still, after N2523): when
  player control lands, the tick passes the live value instead of
  `false` / `0.0`. Turret control() shootp live wiring — logic
  executor not yet in driver. LaserTurret shouldConsume() consumer
  wiring (needs bullets live list). validateTarget effective-team
  live wiring (waits for findTarget).
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity scan.
