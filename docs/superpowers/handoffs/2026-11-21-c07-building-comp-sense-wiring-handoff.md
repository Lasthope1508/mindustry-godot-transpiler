# Handoff — N2519 BuildingComp.sense() wiring: 8 legs vào dispatch (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice f7db9a06, docs f5be1814, GOAL 4cd99a05; cập nhật lượt cron 16:15 +07 — chain + gate xong GATE-EXIT 1 09:08:03Z, Ran 6285 trong 1193.929s, failures=248, skipped=5; xác minh độc lập: 248 FAIL = 247 × unexpectedly None + 1 × unexpectedly None : Godot required for hydration proof, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours 259/259 (254 passed + 5 flake port-7777 re-run xanh), WIRING-EXIT 0 08:33:10Z; wiring XONG 32 tests OK. N2518 đã DONE + PUSHED (5a8bca23). Slice commit f7db9a06, docs f5be1814, GOAL 4cd99a05, status 238fa980. Targeted 4/4 (88 subtests, xác minh độc lập lượt này — tự chạy lại, Godot trên PATH); register --verify 26/26; proof matches:true 18/18 (15 semantic keys, xác minh qua targeted run); SSOT đo từ đĩa 11707/1748/1681/3153; `git diff --check` OK.

- N2518 DONE + PUSHED ~14:40 +07, origin/main == HEAD == 5a8bca23.
- **N2519 GREEN xong ~15:00 +07, lượt cron 16:15 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2519-scope.md`): wiring TÁM
  leg `BuildingComp.sense()` đã port (N2511–N2518) vào big dispatch
  `source_building_comp_sense_state` (SourceTurretBuildState.gd:393,
  N2284). KHÔNG thêm pure function mới — tái dùng 8 leg function;
  KHÔNG driver tick (sense là logic read). Signature dispatch GIỮ
  NGUYÊN 24 params (tiền lệ N2235): 12 frame key mới đọc qua
  `frame.has`/`frame.get`, thiếu key giữ `handled:false` cũ.
- **Xác minh độc lập lượt cron 16:15 +07 (lượt này, đọc trực tiếp
  từ đĩa + log, tự chạy lại targeted + register)**: targeted **4/4
  (88 subtests, 17.82s, Godot trên PATH, port 7777 free)**; register
  `--verify` **26/26 exprs present**; proof **matches:true, 18/18
  keys, 15 semantic all true** (test assert `proofs[0]['matches']`
  và từng PROOF_KEY trong
  `tests/test_c07_building_comp_sense_wiring.py:236-245`); SSOT đo
  từ đĩa **11707/1748/1681/3153** — đúng kỳ vọng scope (+0 symbols /
  +1 Done / +0 contracts / +0 schemas — wiring không thêm symbol
  mới); comp **569/472** (+1/+0, N2519 vào comp shard —
  java_source BuildingComp.java, tiền lệ N2267/N2284/N2506/N2508/
  N2511–N2518); defense **210/209 KHÔNG đổi**; ledger N2519 status
  done, java_source BuildingComp.java, godot_owner
  `SourceTurretBuildState.source_building_comp_sense_state`.
  `git diff --check` SẠCH.
- **Neighbours 259/259** (chain log
  `hidden_files/n2519-chain.log`: NEIGHBOURS-START 08:16:09Z,
  NEIGHBOURS-EXIT 1 08:31:04Z, 254 passed + 5 failed trong 894.48s;
  5 failed là flake port-7777 — 5 module
  hit_size_removal / live_bullets_wiring / persistence_integration /
  should_consume_cooling / write_read re-run xanh 4/4 mỗi module,
  log `hidden_files/n2519-neighbours-rerun.log` 08:47) +
  **wiring XONG 32 tests OK** (WIRING-START 08:31:04Z, WIRING-EXIT 0
  08:33:10Z, Ran 32 tests trong 125.463s, OK).
- **Gate XONG (chain log `hidden_files/n2519-chain.log`,
  GATE-START 08:48:08Z, GATE-EXIT 1 09:08:03Z)** — xác minh độc lập
  lượt cron 16:15 +07 (đọc trực tiếp log
  `tools/mindustry_godot_transpiler/full-suite-n2519-gate.log`,
  166656 byte): Ran 6285 trong 1193.929s, failures=248,
  skipped=5 — 248 FAIL = 247 × `AssertionError: unexpectedly
  None` + 1 × `AssertionError: unexpectedly None : Godot required
  for hydration proof`, 0 KeyError, 0 `return_schema_linkage`, 0
  ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs
  N2518 — đúng 4 test mới của N2519, +1 failure là reference-graph
  test của N2519, Godot-absent vì gate script reset PATH không có
  godot-bin).
- **Môi trường sau gate**: VM restart #17 lúc 05:41:54Z (PID1) —
  TRƯỚC chain (08:16Z), KHÔNG có restart trong lúc chain/gate; gate
  chạy sau restart và sống tới EXIT; javalang importable OK (xác
  minh lượt này); port 7777 free. Lượt sau vẫn kiểm tra lại javalang
  trước mọi gate theo quy tắc repo.
- **Gate xanh — commit + push theo mẫu 5 commit (slice f7db9a06).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2519-chain-main.sh`
  (neighbours + wiring, NO gate) và
  `hidden_files/n2519-gate-only-main.sh` (gate-only; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Chain + gate chạy từ main thread lượt cron 15:00 +07
  (worker scope cấm chạy neighbours/wiring/gate; worker báo
  GREEN-only — chain log `hidden_files/n2519-chain.log`):
  NEIGHBOURS-START 08:16:09Z,
  NEIGHBOURS-EXIT 1 08:31:04Z (254 passed + 5 flake port-7777,
  rerun 08:47 xanh 5/5),
  WIRING-START 08:31:04Z, WIRING-EXIT 0 08:33:10Z,
  GATE-START 08:48:08Z (main thread, gate-only script),
  GATE-EXIT 1 09:08:03Z.
  Ran 6285, failures=248 toàn Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518, nhớ bump Done total
  1747→1748 + row N2519 trong spec; comp 569/472, defense 210/209
  KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt RED, không đổi)

- N2519 = wiring TÁM leg `BuildingComp.sense()` đã port vào dispatch
  `source_building_comp_sense_state` — MỘT slice wire TẤT CẢ (cùng
  một mechanism: đọc leg input từ frame, delegate tới leg function,
  trả kết quả), không phải tám slice (xem scope file
  `docs/superpowers/handoffs/hidden_files/n2519-scope.md`).
- Số slice N2519, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2518).
- Signature dispatch KHÔNG đổi (24 params, tiền lệ N2235): leg inputs
  tới qua 12 frame key mới (`tile_build_is_self`, `is_dead`,
  `health`, `items_is_null`, `items_total`,
  `last_scaled_power_in`, `last_scaled_power_out`,
  `last_power_stored`, `last_capacity`, `is_control_block`,
  `unit_sense_value` + `has_power` đã có); `items_total` đã tồn tại
  làm frame key cùng nghĩa ở SourceLaunchPadBuildState.gd:207 /
  SourceMassDriverBuildState.gd:83, không collision. Thiếu key →
  `handled:false` + null + NaN (fallback cũ).
- Fold `has_power == false` → 0.0 handled:true GIỮ NGUYÊN ĐẦU
  nhánh powerNet*; wiring chỉ thay fallthrough `has_power == true`
  bằng per-leg delegation + absent-key fallback.
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_building_comp_sense_wiring.py`
  (4 test methods, 15 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_building_comp_sense_wiring.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 26/26).
- Proof `C07BuildingCompSenseWiringProof.gd` + `.tscn` (15 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 18).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `BuildingComp.sense()` (`public double sense(LAccess sensor){`,
  BuildingComp.java:2093-2126): dead :2098 `case dead -> !isValid() ? 1 : 0;`;
  health :2101 `case health -> health;`; totalItems :2107
  `case totalItems -> items == null ? 0 : items.total();`; powerNetIn
  :2114 `case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`;
  powerNetOut :2115 `case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;`;
  powerNetStored :2116 `case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();`;
  powerNetCapacity :2117 `case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();`;
  camera* :2122 `case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`.
- N2284 đã port 23 handled legs của `sense()` và để
  dead/health/totalItems/camera*/powerNet* deferred — N2511 port
  `dead`; N2512 port `health`; N2513 port `totalItems`; N2514 port
  `powerNetIn`; N2515 port `powerNetOut`; N2516 port `powerNetStored`;
  N2517 port `powerNetCapacity`; N2518 port camera*; N2519 wire TẤT
  CẢ TÁM leg vào dispatch — **sense() hoàn tất cả pure function lẫn
  dispatch wiring, không còn leg nào `handled:false` vì chưa wiring**.
- N2507 đã port dispatch outcome của SenseI.run() (null-target dead
  leg, senseObject-handled leg, noSensed fallback leg); N2510 là mảnh
  cuối chưa port của chính `SenseI.run()`. N2511–N2519 là các sensor
  leg BÊN TRONG sense() mà SenseI.run() gọi tới qua `se.sense(la)`.

## Tiếp theo (sau N2519)

- `sense()` đã hoàn tất cả pure function lẫn dispatch wiring. Slice
  tiếp theo (N2520) cần scope mới từ backlog: wiring các sense leg
  vào live logic-executor driver tick (logic executor chưa có trong
  driver; wiring slice sẽ gọi
  `SourceUnitSensorState.laccess_state(sensor, unit_state, tilesize)`
  cho proxy unit và stamp live values vào 12 frame key mới của
  N2519) hoặc item deferred tiếp theo trong BuildingComp.
  calculateHeat vẫn BLOCKED (live entity scan); findTarget vẫn
  BLOCKED.

## Deferred (không đổi)

- Wiring các sense leg vào live logic-executor driver tick — logic
  executor chưa có trong driver; stamping live values (is_dead,
  health, items_total, graph values, unit sense value) từ tick vào
  frame là frame work riêng, các frame key của N2519 là input slice
  đó sẽ cung cấp.
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity scan.
