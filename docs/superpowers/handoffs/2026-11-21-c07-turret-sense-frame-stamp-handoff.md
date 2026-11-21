# Handoff — N2520 Turret driver tick stamps live sense inputs into the frame (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice 653a5c2f, docs b76c6f9b, GOAL 0c543a46; cập nhật lượt cron 17:45 +07 — chain + gate xong GATE-EXIT 1 10:35:44Z, Ran 6289 trong 1186.382s, failures=249, skipped=5; xác minh độc lập: 249 FAIL = 248 × unexpectedly None thuần + 1 × unexpectedly None : Godot required for hydration proof (1 failure block pre-existing, chuỗi xuất hiện 2 lần), 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours 263/263 (0 flake), WIRING-EXIT 0 10:10:44Z; wiring XONG 32 tests OK. N2519 đã DONE + PUSHED (b9112453). Slice commit 653a5c2f, docs b76c6f9b, GOAL 0c543a46, status TBD. Targeted 4/4 (60 subtests, xác minh độc lập lượt này — tự chạy lại, Godot trên PATH); register --verify 17/17; proof matches:true 13/13 (10 semantic keys, đọc trực tiếp proof .json); SSOT đo từ đĩa 11708/1749/1682/3155; `git diff --check` OK.

- N2519 DONE + PUSHED ~16:25 +07, origin/main == HEAD == b9112453.
- **N2520 GREEN xong ~16:51 +07, lượt cron 17:45 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2520-scope.md`): turret
  driver tick stamp live sense inputs vào frame cho dispatch N2519 —
  1 pure function mới `source_turret_sense_frame_stamp_state`
  (SourceTurretBuildState.gd:66) + 1 call site trong
  `source_turret_tick_buildings_state` (:2287) + 1 preload
  (`source_block_metadata_state`). Dispatch N2519 ngừng báo
  `handled:false` cho dead/health/camera* khi live turret tick.
- **Xác minh độc lập lượt cron 17:45 +07 (lượt này, đọc trực tiếp
  từ đĩa + log, tự chạy lại targeted + register)**: targeted **4/4
  (60 subtests, 16.30s, Godot trên PATH, port 7777 free)**; register
  `--verify` **17/17 exprs present**; proof **matches:true, 13/13
  keys, 10 semantic all true** (đọc trực tiếp
  `C07TurretSenseFrameStampProof.json` — duo full 250.0 → dead 0.0 /
  health 250.0; damaged 120.0 → dead 0.0 / health 120.0; killed 0.0
  → dead 1.0 / health 0.0; cameraX no-controller 0.0 handled:true;
  totalItems + powerNetIn vẫn handled:false (key absent);
  has_power=false fold 0.0 handled:true, N2519 giữ nguyên); SSOT đo
  từ đĩa **11708/1749/1682/3155** — đúng kỳ vọng scope (+1 symbols /
  +1 Done / +1 contracts / +2 schemas — 1 hàm mới); comp **570/473**
  (+1/+1, N2520 vào comp shard — java_source BuildingComp.java,
  tiền lệ N2267/N2284/N2506/N2508/N2511–N2519); defense **210/209
  KHÔNG đổi**; deferred pool **454** (448 + 6, đúng 6 entry mới, 0
  entry bị xóa); ledger N2520 status done, java_source
  BuildingComp.java, godot_owner
  `SourceTurretBuildState.source_turret_sense_frame_stamp_state`.
  `git diff --check` SẠCH (726 insertions, 0 deletions). N2519 tests
  chạy lại **4/4 (88 subtests, 15.54s)** — còn xanh, không bị chạm.
- **Neighbours 263/263** (chain log
  `hidden_files/n2520-chain.log`: NEIGHBOURS-START 09:54:13Z,
  NEIGHBOURS-EXIT 0 10:08:40Z, 263 passed trong 866.53s, 0 flake —
  sạch nhất từ N2518) + **wiring XONG 32 tests OK** (WIRING-START
  10:08:40Z, WIRING-EXIT 0 10:10:44Z, Ran 32 tests trong 123.989s,
  OK).
- **Gate XONG (chain log `hidden_files/n2520-chain.log`,
  GATE-START 10:15:55Z, GATE-EXIT 1 10:35:44Z)** — xác minh độc lập
  lượt cron 17:45 +07 (đọc trực tiếp log
  `tools/mindustry_godot_transpiler/full-suite-n2520-gate.log`,
  167307 byte): Ran 6289 trong 1186.382s, failures=249,
  skipped=5 — 249 FAIL blocks, 0 ERROR, 0 KeyError, 0
  `return_schema_linkage`; phân rã theo FAIL block: 248 ×
  `AssertionError: unexpectedly None` thuần + 1 × `AssertionError:
  unexpectedly None : Godot required for hydration proof`
  (test_live_block_shared_consumers_and_optional_efficiency_runtime,
  test_liquid_consumer_hydration.py:66 — pre-existing baseline, chuỗi
  hydration xuất hiện 2 lần cho cùng 1 block: phần FAILURES + phần
  tóm tắt cuối; hydration là hằng số: N2518 = 246 thuần + 1, N2519 =
  247 + 1, N2520 = 248 + 1), toàn Godot-absent (+4 tests / +1 failure
  đúng mẫu vs N2519 — đúng 4 test mới của N2520, +1 failure là
  reference-graph test của N2520, Godot-absent vì gate script reset
  PATH không có godot-bin).
- **Môi trường sau gate**: VM restart #17 lúc 05:41:54Z (PID1) —
  TRƯỚC chain (09:54Z), KHÔNG có restart trong lúc chain/gate; gate
  chạy sau restart và sống tới EXIT; javalang importable OK (xác
  minh lượt này); port 7777 free. Lượt sau vẫn kiểm tra lại javalang
  trước mọi gate theo quy tắc repo.
- **Gate xanh — commit + push theo mẫu 5 commit (slice 653a5c2f).**
- Lưu ý nhỏ (không blocker): comment trong hàm stamp ghi "Exactly
  six keys are written" nhưng hàm chỉ ghi 5 key (health, is_dead,
  tile_build_is_self, is_control_block, unit_sense_value) — key thứ
  6 là has_power đã được tick stamp sẵn từ trước (ghi nhận từ lượt
  scope 16:30). Tests/proof pin đúng hành vi thực tế.

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2520-chain-main.sh`
  (neighbours + wiring, NO gate) và
  `hidden_files/n2520-gate-only-main.sh` (gate-only; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Chain + gate chạy từ main thread lượt cron 16:45/17:15 +07
  (worker scope cấm chạy neighbours/wiring/gate; worker báo
  GREEN-only — chain log `hidden_files/n2520-chain.log`):
  NEIGHBOURS-START 09:54:13Z,
  NEIGHBOURS-EXIT 0 10:08:40Z (263 passed, 0 flake),
  WIRING-START 10:08:40Z, WIRING-EXIT 0 10:10:44Z,
  GATE-START 10:15:55Z (worker-launch nhưng SỐNG tới EXIT, tiền lệ
  N2510/N2513 — không kill/relaunch vội),
  GATE-EXIT 1 10:35:44Z.
  Ran 6289, failures=249 toàn Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519, nhớ bump Done total
  1748→1749 + row N2520 trong spec; comp 570/473, defense 210/209
  KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt scope 16:30, không đổi)

- N2520 = stamp live sense inputs mà turret driver tick CÓ THỂ cung
  cấp hôm nay vào frame, để dispatch N2519 ngừng báo `handled:false`
  cho chúng khi live turret tick (xem scope file
  `docs/superpowers/handoffs/hidden_files/n2520-scope.md`).
- Số slice N2520, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2519, xác minh lượt scope 16:30).
- MỘT pure function + MỘT tick call site (không phải sáu slice: một
  mechanism, một tick, một frame). Hàm stamp ghi đúng 5 key
  (`health`, `is_dead`, `tile_build_is_self`, `is_control_block`,
  `unit_sense_value`); `has_power` đã được tick stamp sẵn (key thứ
  6 trong scope); 6 key còn lại KHÔNG stamp (`items_is_null` /
  `items_total` + 4 graph key) — absent key giữ `handled:false`.
- KHÔNG build logic-executor driver: chưa có vòng lặp LExecutor nào
  trong port (SenseI.run() chỉ tồn tại dạng pure function N2507/
  N2510) — đó là program, không phải slice. KHÔNG sửa 8 leg
  function, dispatch, test/proof N2519, SenseI pure functions.
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_turret_sense_frame_stamp.py`
  (4 test methods, 10 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_turret_sense_frame_stamp.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 17/17).
- Proof `C07TurretSenseFrameStampProof.gd` + `.tscn` (10 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 13).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `BuildingComp.sense()` (`public double sense(LAccess sensor){`,
  BuildingComp.java:2093-2126): health :2101 `case health -> health;`;
  camera* :2122 `case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`
  delegating to UnitComp.sense :283-286 `case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;`.
- `isValid()` (`return tile.build == self() && !dead();`,
  BuildingComp.java:2031) — tick chỉ iterate live placed buildings
  nên conjunct đầu giữ true.
- Kill trigger `if(health <= 0f && !dead()){`,
  BuildingComp.java:2170, sets `dead = true;` trong killed()
  (:2243) — port-consistent reading
  SourceBuildingDamageState.gd:40 `"was_dead": current_health <= 0.0`.
- `public class TurretBuild extends ReloadTurretBuild implements
  ControlBlock{`, Turret.java:277 — mọi turret build là control
  block. Tick là TurretBuild.updateTile() (`public void
  updateTile(){`, Turret.java:490), chạy cho mọi Turret-family build
  tick đã visit.
- N2519 đã wire TÁM leg vào dispatch — **sense() hoàn tất cả pure
  function lẫn dispatch wiring**; N2520 đưa live input đầu tiên vào
  frame qua tick hiện có.

## Tiếp theo (sau N2520)

- Slice tiếp theo (N2521) cần scope mới từ backlog — kiểm tra `git
  log --all` trước khi chọn số (N2285–N2505 đã có trên branch
  khác). Ứng viên: turret-ammo-inventory slice (stamp
  `items_is_null`/`items_total`); PowerGraph last-values
  prerequisite slice (per-graph lastScaled/lastStored/lastCapacity
  snapshot + building→graph lookup trong tick — stamp 4 graph key
  còn lại); compose SenseI leg (N2510) với dispatch ở caller (chờ
  logic-executor driver); `controlled()` live wiring (cần player
  unit — khi đó tick truyền live player camera value thay 0.0).
  calculateHeat vẫn BLOCKED (live entity scan); findTarget vẫn
  BLOCKED.

## Deferred (không đổi + mới)

- Stamping `items_is_null` / `items_total` — waits for the
  turret-ammo-inventory slice (tick comment: item ammo waits for its
  own slice); the dispatch keeps handled:false for totalItems until
  then.
- Stamping `last_scaled_power_in` / `last_scaled_power_out` /
  `last_power_stored` / `last_capacity` — waits for the PowerGraph
  last-values prerequisite slice (per-graph lastScaled/lastStored/
  lastCapacity snapshot + building→graph lookup in the tick;
  PowerGraph.java:233-234, :236).
- Composing the SenseI LAccess leg (N2510) with the dispatch at the
  caller — waits for a logic-executor driver (no LExecutor
  instruction loop exists in the port yet); the stamped frame is the
  input that caller will read.
- `controlled()` live wiring (needs a player unit) — when it lands,
  the tick passes the live player camera value as
  `unit_sense_value` instead of 0.0. Turret control() shootp live
  wiring — logic executor not yet in driver. LaserTurret
  shouldConsume() consumer wiring (needs bullets live list).
  validateTarget effective-team live wiring (waits for findTarget).
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity scan.
