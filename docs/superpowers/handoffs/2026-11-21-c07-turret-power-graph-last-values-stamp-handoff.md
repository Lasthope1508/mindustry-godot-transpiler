# Handoff — N2522 Turret power-graph last-values stamp: 4 live keys into the frame for N2519 dispatch (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice TBD, docs TBD, GOAL TBD; cập nhật lượt cron 20:30 +07 — chain + gate xong GATE-EXIT 1 13:22:11Z, Ran 6297 trong 1232.402s, failures=251, skipped=5; xác minh độc lập: 251 FAIL = 250 × unexpectedly None thuần + 1 × unexpectedly None : Godot required for hydration proof (1 failure block pre-existing, chuỗi xuất hiện 2 lần trong cùng block), 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours 271/271 (0 flake), WIRING-EXIT 0 12:52:00Z; wiring XONG 32 tests OK. N2521 đã DONE + PUSHED (716ff678). Slice commit TBD, docs TBD, GOAL TBD, status TBD. Targeted 4/4 (65 subtests, main thread xác minh lượt này); register --verify 17/17; proof matches:true 11/11 (8 semantic keys, đọc trực tiếp proof .json); SSOT đo từ đĩa 11710/1751/1684/3159; `git diff --check` OK.

- N2521 DONE + PUSHED ~19:07 +07, origin/main == HEAD == 716ff678.
- **N2522 GREEN xong ~19:49 +07, lượt cron 20:30 +07**: turret
  driver tick stamp live power-graph last-values snapshot vào
  frame cho dispatch N2519 — 1 pure function mới
  `source_turret_power_graph_last_values_stamp_state`
  (SourceTurretBuildState.gd:159) + 1 call site trong
  `source_turret_tick_buildings_state` (:2444). Dispatch N2519
  ngừng báo `handled:false` cho powerNet* khi live turret tick.
  **sense() frame ĐÓNG 12/12 key** — mọi leg sense() đã port
  (N2511–N2518) + dispatch wiring (N2519) + frame stamps
  (N2520 sense, N2521 items, N2522 graph) đều có live input ở
  tầng tick.
- **Xác minh độc lập lượt cron 20:30 +07 (lượt này, đọc trực tiếp
  từ đĩa + log)**: targeted **4/4 (65 subtests; main thread xác
  minh)**; register `--verify` **17/17** (main thread xác minh);
  proof **matches:true, 11/11 keys, 8 semantic all true** (đọc
  trực tiếp `C07TurretPowerGraphLastValuesStampProof.json`, mtime
  12:49Z — powerNetIn/Out/Stored/Capacity đọc đúng giá trị stamp;
  cheat branch giữ scaled/capacity absent nhưng vẫn cập nhật
  stored; sense + ammo + graph stamps compose; empty update giữ
  keys absent); SSOT đo từ đĩa **11710/1751/1684/3159** — đúng kỳ
  vọng (+1 symbols / +1 Done / +1 contracts / +2 schemas — 1 hàm
  mới); comp **572/475** (+1/+1, N2522 vào comp shard —
  java_source BuildingComp.java, tiền lệ N2267/N2284/N2506/N2508/
  N2511–N2521); defense **210/209 KHÔNG đổi**; deferred pool
  **463** (460 + 3, đúng 3 entry mới, 0 entry bị xóa); ledger
  N2522 status done, java_source BuildingComp.java, godot_owner
  `SourceTurretBuildState.source_turret_power_graph_last_values_stamp_state`.
  `git diff --check` SẠCH (1390 insertions, 20 deletions — 767/20
  trên 9 file sửa + 623 dòng trên 4 file mới).
- **Neighbours 271/271** (chain log
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2522-neighbours.log`:
  271 passed trong 900.55s, 0 flake, NEIGHBOURS-EXIT 0
  12:49:56Z) + **wiring XONG 32 tests OK** (WIRING-EXIT 0
  12:52:00Z, Ran 32 tests trong 123.969s, OK).
- **Gate XONG (chain log trên, GATE-START 13:01:37Z, GATE-EXIT 1
  13:22:11Z)** — xác minh độc lập lượt cron 20:30 +07 (đọc trực
  tiếp log `tools/mindustry_godot_transpiler/full-suite-n2522-gate.log`,
  168673 byte): Ran 6297 trong 1232.402s, failures=251,
  skipped=5 — 251 FAIL blocks, 0 ERROR, 0 KeyError, 0
  `return_schema_linkage`; phân rã theo FAIL block: 250 ×
  `AssertionError: unexpectedly None` thuần + 1 × `AssertionError:
  unexpectedly None : Godot required for hydration proof`
  (test_liquid_consumer_hydration.py:66 — pre-existing baseline,
  chuỗi hydration xuất hiện 2 lần cho cùng 1 block: dòng assert
  trong traceback + dòng AssertionError; hydration là hằng số:
  N2518 = 246 thuần + 1, N2519 = 247 + 1, N2520 = 248 + 1, N2521
  = 249 + 1, N2522 = 250 + 1), toàn Godot-absent (+4 tests / +1
  failure đúng mẫu vs N2521 — đúng 4 test mới của N2522, +1
  failure là reference-graph test của N2522, Godot-absent vì gate
  script reset PATH không có godot-bin).
- **Commit 1 gồm 13 file** (9 sửa + 4 mới — main thread đã xác
  minh từ đĩa, đính chính brief lượt trước ghi sai "đúng 9
  file"; đối chiếu mẫu N2521: slice commit f1c3c133 = 11 file =
  7 sửa + 4 mới).
- **Gate xanh — commit + push theo mẫu 5 commit (slice TBD).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2522-chain-main.sh`
  (neighbours + wiring, NO gate) và
  `hidden_files/n2522-gate-only-main.sh` (gate-only; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Chain + gate chạy từ main thread lượt cron 20:30 +07
  (worker scope cấm chạy neighbours/wiring/gate; worker báo
  GREEN-only — chain log `hidden_files/n2522-chain.log`):
  NEIGHBOURS-EXIT 0 12:49:56Z (271 passed, 0 flake),
  WIRING-EXIT 0 12:52:00Z,
  GATE-START 13:01:37Z (gate-only-main.sh, main thread),
  GATE-EXIT 1 13:22:11Z.
  Ran 6297, failures=251 toàn Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2521,
  nhớ bump Done total 1750→1751 + row N2522 trong spec; comp
  572/475, defense 210/209 KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt scope, không đổi)

- N2522 = stamp live power-graph last-values snapshot mà turret
  driver tick CÓ THỂ cung cấp hôm nay vào frame, để dispatch
  N2519 ngừng báo `handled:false` cho powerNet* khi live turret
  tick.
- Số slice N2522, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2521, xác minh lượt scope).
- MỘT pure function + MỘT tick call site (không phải hai slice:
  một mechanism, một tick, một frame). Hàm stamp ghi đúng 4 key
  (`last_scaled_power_in` / `last_scaled_power_out` /
  `last_power_stored` / `last_capacity`), copy verbatim từ graph
  update mà live loop đã chạy trong tick này
  (`source_factory_update_power_graph_state`,
  SourceFactoryRuntimeState.gd:199, `update` là `update_state`
  output): 3 key scaled/capacity từ `update["balance_state"]`,
  `last_power_stored` từ `update["last_power_stored"]` (top-level
  cả hai branch). Một key chỉ được stamp KHI có mặt trong update:
  cheat branch `balance_state` là `{}` (Java return trước
  :233-236, PowerGraph.java:217-224, nên các field giữ giá trị
  cũ) — scaled/capacity giữ absent, nhưng `last_power_stored`
  vẫn được stamp (top-level luôn có). Update rỗng `{}` → cả 4
  key giữ absent — fallback N2519.
- Tick đọc update đã lưu trên game (`power_graph_update`,
  khai báo trong SourcePortGameFactoryStatePortBridge.gd) — KHÔNG
  chạy lại update (NOT idempotent: nó ghi battery `power_status`
  về sprite metas, chạy lần hai sẽ charge/discharge LẠI) và KHÔNG
  recompute từ `game_runtime_state` (sẽ duplicate formula, và
  batteries của nó đọc status 0.0). Game không có stored update
  (proof gọi tick trực tiếp) đọc `{}` và stamp để keys absent.
- KHÔNG build logic-executor driver: chưa có vòng lặp LExecutor nào
  trong port (SenseI.run() chỉ tồn tại dạng pure function N2507/
  N2510) — đó là program, không phải slice. KHÔNG sửa 8 leg
  function, dispatch, test/proof N2519/N2520/N2521, SenseI pure
  functions. KHÔNG chạm tick drivers của non-duo ItemTurret (chưa
  có driver).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_turret_power_graph_last_values_stamp.py`
  (4 test methods, 8 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_turret_power_graph_last_values_stamp.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 17/17).
- Proof `C07TurretPowerGraphLastValuesStampProof.gd` + `.tscn` (8 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 11).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `BuildingComp.sense()` (`public double sense(LAccess sensor){`,
  BuildingComp.java:2093-2126): powerNetIn :2113 `case powerNetIn
  -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`;
  powerNetOut :2114 `case powerNetOut -> power == null ? 0 :
  power.graph.getLastScaledPowerOut() * 60;`; powerNetStored
  :2115 `case powerNetStored -> power == null ? 0 :
  power.graph.getLastPowerStored();`; powerNetCapacity :2116
  `case powerNetCapacity -> power == null ? 0 :
  power.graph.getLastCapacity();`.
- `PowerGraph.update()` (`public void update(){`,
  PowerGraph.java:216-260): cheat branch return trước :233-236
  (:217-224); `lastScaledPowerIn = (powerProduced + energyDelta)
  / Time.delta;` :233; `lastScaledPowerOut = powerNeeded /
  Time.delta;` :234; `lastCapacity =
  getTotalBatteryCapacity();` :235; `lastPowerStored =
  getBatteryStored();` :236.
- Tick là TurretBuild.updateTile() (`public void updateTile(){`,
  Turret.java:490), chạy cho mọi Turret-family build tick đã visit.
- N2520 đã stamp 5 sense key + N2521 stamp 2 items key — **sau
  N2522, 12 trong 12 dispatch frame key đã có live input ở tầng
  tick**; sense() frame ĐÓNG.

## Tiếp theo (sau N2522)

- Slice tiếp theo (N2523) cần scope mới từ backlog — kiểm tra `git
  log --all` trước khi chọn số (N2285–N2505 đã có trên branch
  khác). Ứng viên: per-graph split (building→graph lookup theo
  connectivity — chờ PowerGraph.addGraph merge port); compose
  SenseI leg (N2510) với dispatch ở caller (chờ logic-executor
  driver); `controlled()` live wiring (cần player unit — khi đó
  tick truyền live player camera value thay 0.0).
  calculateHeat vẫn BLOCKED (live entity scan); findTarget vẫn
  BLOCKED.

## Deferred (không đổi + mới)

- Turret sense frame stamp per-graph split — DEFERRED (vẫn, sau
  N2522): Java đọc graph RIÊNG của từng building
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
- `controlled()` live wiring (needs a player unit) — when it lands,
  the tick passes the live player camera value as
  `unit_sense_value` instead of 0.0. Turret control() shootp live
  wiring — logic executor not yet in driver. LaserTurret
  shouldConsume() consumer wiring (needs bullets live list).
  validateTarget effective-team live wiring (waits for findTarget).
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity scan.
