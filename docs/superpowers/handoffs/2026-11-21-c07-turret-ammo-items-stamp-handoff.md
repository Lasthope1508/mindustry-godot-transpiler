# Handoff — N2521 Turret ammo-items stamp: 2 live keys into the frame for N2519 dispatch (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice f1c3c133, docs TBD, GOAL TBD; cập nhật lượt cron 19:00 +07 — chain + gate xong GATE-EXIT 1 11:57:08Z, Ran 6293 trong 1197.785s, failures=250, skipped=5; xác minh độc lập: 250 FAIL = 249 × unexpectedly None thuần + 1 × unexpectedly None : Godot required for hydration proof (1 failure block pre-existing, chuỗi xuất hiện 2 lần trong cùng block), 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours 267/267 (0 flake), WIRING-EXIT 0 11:36:13Z; wiring XONG 32 tests OK. N2520 đã DONE + PUSHED (16eecc2c). Slice commit f1c3c133, docs TBD, GOAL TBD, status TBD. Targeted 4/4 (49 subtests, main thread xác minh lượt này); register --verify 14/14; proof matches:true 11/11 (8 semantic keys, đọc trực tiếp proof .json); SSOT đo từ đĩa 11709/1750/1683/3157; `git diff --check` OK.

- N2520 DONE + PUSHED ~17:50 +07, origin/main == HEAD == 16eecc2c.
- **N2521 GREEN xong ~18:33 +07, lượt cron 19:00 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2521-scope.md`): turret
  driver tick stamp live item inventory vào frame cho dispatch
  N2519 — 1 pure function mới
  `source_turret_ammo_items_stamp_state`
  (SourceTurretBuildState.gd:119) + 1 call site trong
  `source_turret_tick_buildings_state` (:2349). Dispatch N2519
  ngừng báo `handled:false` cho totalItems khi live turret tick.
- **CORRECTION (scope khóa, Java chứng minh)**: `items_total` là
  0, KHÔNG phải tổng các ammo stack. `ItemTurretBuild.handleItem`
  (ItemTurret.java:155-185) override `BuildingComp.handleItem`
  (:860-862) mà KHÔNG gọi super — chỉ cập nhật `totalAmmo` và các
  entry `ammo` theo trọng số; `handleStack` (:141-147) lặp
  `handleItem`, `read()` khôi phục `ammo` + `totalAmmo`, không
  đường nào ghi `items`. Module `items` của ItemTurret TỒN TẠI
  (non-null, `hasItems = true;`, ItemTurret.java:28) nhưng LUÔN
  RỖNG — `items.total() == 0` luôn, `sense(totalItems)` của
  turret luôn 0.0 handled:true. Các `turret_ammo_stacks` của port
  là Java `ammo` Seq, KHÔNG phải module `items` — cộng dồn chúng
  sẽ bịa hành vi (duo copper 5 + graphite 3 sẽ đọc 8.0 trong khi
  Java đọc 0.0). Tick KHÔNG đọc stacks dict cho stamp này.
- **Xác minh độc lập lượt cron 19:00 +07 (lượt này, đọc trực tiếp
  từ đĩa + log)**: targeted **4/4 (49 subtests — đếm tĩnh từ test
  file: 1 + 12 + 28 + 8; main thread xác minh)**; register
  `--verify` **14/14 exprs present** (11 EXACT_EXPRS + 2 inputs +
  1 output; main thread xác minh); proof **matches:true, 11/11
  keys, 8 semantic all true** (đọc trực tiếp
  `C07TurretAmmoItemsStampProof.json`, mtime 11:33Z — ItemTurret
  → totalItems 0.0 handled:true; non-ItemTurret → 0.0
  handled:true; stale `items_total` 99 bị ghi đè → 0.0; sense +
  ammo stamps compose (health 250.0, dead 0.0, cameraX 0.0);
  killed duo 0.0 → totalItems 0.0 handled:true; powerNetIn vẫn
  handled:false (graph keys absent)); SSOT đo từ đĩa
  **11709/1750/1683/3157** — đúng kỳ vọng scope (+1 symbols /
  +1 Done / +1 contracts / +2 schemas — 1 hàm mới); comp
  **571/474** (+1/+1, N2521 vào comp shard — java_source
  BuildingComp.java, tiền lệ N2267/N2284/N2506/N2508/N2511–N2520);
  defense **210/209 KHÔNG đổi**; deferred pool **460** (454 + 6,
  đúng 6 entry mới, 0 entry bị xóa); ledger N2521 status done,
  java_source BuildingComp.java, godot_owner
  `SourceTurretBuildState.source_turret_ammo_items_stamp_state`.
  `git diff --check` SẠCH (1262 insertions, 11 deletions — 707/11
  trên 7 file sửa + 555 dòng trên 4 file mới).
- **Neighbours 267/267** (chain log
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2521-chain.log`:
  NEIGHBOURS-START 11:19:27Z (relaunch — lần 1 START 11:08:57Z
  chết không EXIT), NEIGHBOURS-EXIT 0 11:34:09Z, 267 passed trong
  881.94s, 0 flake) + **wiring XONG 32 tests OK** (WIRING-START
  11:34:09Z, WIRING-EXIT 0 11:36:13Z, Ran 32 tests trong 123.198s,
  OK).
- **Gate XONG (chain log trên, GATE-START 11:37:09Z, GATE-EXIT 1
  11:57:08Z)** — xác minh độc lập lượt cron 19:00 +07 (đọc trực
  tiếp log `tools/mindustry_godot_transpiler/full-suite-n2521-gate.log`,
  167952 byte): Ran 6293 trong 1197.785s, failures=250,
  skipped=5 — 250 FAIL blocks, 0 ERROR, 0 KeyError, 0
  `return_schema_linkage`; phân rã theo FAIL block: 249 ×
  `AssertionError: unexpectedly None` thuần + 1 × `AssertionError:
  unexpectedly None : Godot required for hydration proof`
  (test_live_block_shared_consumers_and_optional_efficiency_runtime,
  test_liquid_consumer_hydration.py:66 — pre-existing baseline, chuỗi
  hydration xuất hiện 2 lần cho cùng 1 block: dòng assert trong
  traceback + dòng AssertionError; hydration là hằng số: N2518 =
  246 thuần + 1, N2519 = 247 + 1, N2520 = 248 + 1, N2521 = 249 +
  1), toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2520
  — đúng 4 test mới của N2521, +1 failure là reference-graph test
  của N2521, Godot-absent vì gate script reset PATH không có
  godot-bin).
- **Môi trường sau gate**: VM restart #18 lúc 11:02:51Z (18:02
  +07, PID1) — TRƯỚC chain (11:08Z), KHÔNG có restart trong lúc
  chain/gate; javalang 0.13.0 còn nguyên sau restart (xác minh lượt
  này). Lượt sau vẫn kiểm tra lại javalang trước mọi gate theo quy
  tắc repo.
- **Gate xanh — commit + push theo mẫu 5 commit (slice f1c3c133).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2521-chain-main.sh`
  (neighbours + wiring, NO gate) và
  `hidden_files/n2521-gate-only-main.sh` (gate-only; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Chain + gate chạy từ main thread lượt cron 19:00 +07
  (worker scope cấm chạy neighbours/wiring/gate; worker báo
  GREEN-only — chain log `hidden_files/n2521-chain.log`):
  NEIGHBOURS-START 11:08:57Z (lần 1, script nohup — chết không
  EXIT), NEIGHBOURS-START 11:19:27Z (main thread relaunch bằng
  chain-main.sh),
  NEIGHBOURS-EXIT 0 11:34:09Z (267 passed, 0 flake),
  WIRING-START 11:34:09Z, WIRING-EXIT 0 11:36:13Z,
  GATE-START 11:37:09Z (gate-only-main.sh, main thread),
  GATE-EXIT 1 11:57:08Z.
  Ran 6293, failures=250 toàn Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2520,
  nhớ bump Done total 1749→1750 + row N2521 trong spec; comp
  571/474, defense 210/209 KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt scope, không đổi)

- N2521 = stamp live item inventory mà turret driver tick CÓ THỂ
  cung cấp hôm nay vào frame, để dispatch N2519 ngừng báo
  `handled:false` cho totalItems khi live turret tick (xem scope
  file `docs/superpowers/handoffs/hidden_files/n2521-scope.md`).
- Số slice N2521, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2520, xác minh lượt scope).
- MỘT pure function + MỘT tick call site (không phải hai slice:
  một mechanism, một tick, một frame). Hàm stamp ghi đúng 2 key
  (`items_is_null` / `items_total`); `items_total` là hằng 0 (xem
  correction trên); 4 graph key còn lại KHÔNG stamp — absent key
  giữ `handled:false` cho powerNet*.
- KHÔNG build logic-executor driver: chưa có vòng lặp LExecutor nào
  trong port (SenseI.run() chỉ tồn tại dạng pure function N2507/
  N2510) — đó là program, không phải slice. KHÔNG sửa 8 leg
  function, dispatch, test/proof N2519/N2520, SenseI pure functions.
  KHÔNG chạm tick drivers của non-duo ItemTurret (chưa có driver).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_turret_ammo_items_stamp.py`
  (4 test methods, 8 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_turret_ammo_items_stamp.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 14/14).
- Proof `C07TurretAmmoItemsStampProof.gd` + `.tscn` (8 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 11).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `BuildingComp.sense()` (`public double sense(LAccess sensor){`,
  BuildingComp.java:2093-2126): totalItems :2107 `case totalItems
  -> items == null ? 0 : items.total();`; item module tạo ở :145
  `if(block.hasItems) items = new ItemModule();`, field
  `@Nullable ItemModule items;` :81.
- `ItemTurret.java:28` `hasItems = true;` — set duy nhất trong 5
  implementation ticked. `ItemTurretBuild.handleItem`
  (:155-185) override `BuildingComp.handleItem` (:860-862,
  `items.add(item, 1);`) KHÔNG gọi super: chỉ cập nhật `totalAmmo`
  (`totalAmmo += type.ammoMultiplier;`, :168) và các entry `ammo`
  theo trọng số (`entry.amount += type.ammoMultiplier;`, :176);
  `handleStack` (:141-147) lặp `handleItem`; `read()` khôi phục
  `ammo` + `totalAmmo`, không ghi `items`.
- `ItemModule.java:174-176` `public int total(){ return total; }`
  — module rỗng nên total = 0 luôn.
- `Turret.java:283` `public int totalAmmo;` — `turret_ammo_stacks`
  của port là Java `ammo` Seq, KHÔNG phải module `items`.
- Tick là TurretBuild.updateTile() (`public void updateTile(){`,
  Turret.java:490), chạy cho mọi Turret-family build tick đã visit.
- N2520 đã stamp 5 sense key + `has_power` có sẵn — **sau N2521,
  8 trong 12 dispatch frame key đã có live input ở tầng tick**;
  chỉ còn 4 graph key chờ PowerGraph last-values prerequisite slice.

## Tiếp theo (sau N2521)

- Slice tiếp theo (N2522) cần scope mới từ backlog — kiểm tra `git
  log --all` trước khi chọn số (N2285–N2505 đã có trên branch
  khác). Ứng viên: PowerGraph last-values prerequisite slice
  (per-graph lastScaled/lastStored/lastCapacity snapshot +
  building→graph lookup trong tick — stamp 4 graph key còn lại);
  compose SenseI leg (N2510) với dispatch ở caller (chờ
  logic-executor driver); `controlled()` live wiring (cần player
  unit — khi đó tick truyền live player camera value thay 0.0).
  calculateHeat vẫn BLOCKED (live entity scan); findTarget vẫn
  BLOCKED.

## Deferred (không đổi + mới)

- Stamping `last_scaled_power_in` / `last_scaled_power_out` /
  `last_power_stored` / `last_capacity` — waits for the PowerGraph
  last-values prerequisite slice (per-graph lastScaled/lastStored/
  lastCapacity snapshot + building→graph lookup in the tick;
  PowerGraph.java:233-234, :236).
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
