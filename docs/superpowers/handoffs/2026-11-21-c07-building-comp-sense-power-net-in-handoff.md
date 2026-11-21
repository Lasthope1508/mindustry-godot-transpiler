# Handoff — N2514 BuildingComp.sense() `powerNetIn` leg (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice 05ee5b98, docs d1be1800, GOAL 7b5ebb66; cập nhật lượt cron 10:10 +07 — chain + gate main-thread xong GATE-EXIT 1 02:51:13Z, Ran 6265 trong 1192.788s, failures=243, skipped=5; xác minh độc lập: 243 FAIL = 243 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours XONG thực chất 239/239 (238 passed + 1 flake port-7777, coolant re-run 4 passed 56 subtests xanh), WIRING-EXIT 0 02:20:43Z; wiring XONG 32 tests OK. N2513 đã DONE + PUSHED (451bb8c5). Slice commit 05ee5b98, docs d1be1800, GOAL 7b5ebb66, status 11d49ae7. Targeted 4/4 (30 subtests, lượt worker GREEN, Godot trên PATH; re-run độc lập lượt cron 10:0x +07: 3 passed + 1 fail Godot-absent reference-graph, 24 subtests passed, Godot không có trên PATH shell này); register --verify 10/10 (re-run độc lập lượt này); proof JSON matches:true 9/9 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11695/1743/1677/3145; `git diff --check` OK.

- N2513 DONE + PUSHED ~08:23 +07, origin/main == HEAD == 451bb8c5.
- **N2514 GREEN xong ~09:19 +07, lượt cron 09:15 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2514-scope.md`): 1 pure
  function `source_building_comp_sense_power_net_in_state(power_is_null, last_scaled_power_in)` trong
  SourceTurretBuildState.gd:629, ngay SAU
  `source_building_comp_sense_total_items_state` (N2513, :595, kết thúc
  ~:628), TRƯỚC `source_turret_sense_object_state` (N2506, :668 —
  bị đẩy từ :629) (mirror Java order — sense() :2093 →
  senseObject() :2128; trong sense() dead :2098 → health :2101 →
  totalItems :2107 → powerNetIn :2114).
  KHÔNG driver tick (logic read). KHÔNG sửa
  `source_building_comp_sense_state`: powerNetIn vẫn `handled:false`
  trong big dispatch cho tới slice wiring sau.
- **Xác minh độc lập lượt cron 10:00 +07 (lượt này, đọc trực tiếp
  từ đĩa + chạy lại)**: targeted **3 passed + 1 fail Godot-absent
  (reference-graph test, `shutil.which('godot')` None trong shell
  này), 24 subtests passed** — worker GREEN 4/4 (30 subtests, Godot
  trên PATH); register `--verify` **10/10 exprs present, exit 0**
  (chạy lại lượt này); proof JSON **matches:true, 9/9 keys, 6
  semantic all true** (`C07BuildingCompSensePowerNetInProof.json`,
  mtime 02:19:06Z ~09:19 +07, đọc trực tiếp từ đĩa); SSOT đo từ đĩa
  **11695/1743/1677/3145** — đúng kỳ vọng scope (+3 symbols / +1
  Done / +1 contract / +2 schemas); comp **564/468** (+1/+1, N2514
  vào comp shard — java_source BuildingComp.java, tiền lệ
  N2267/N2284/N2506/N2508/N2511/N2512/N2513); defense **210/209
  KHÔNG đổi**; ledger N2514 status done, java_source
  BuildingComp.java, godot_owner
  `SourceTurretBuildState.source_building_comp_sense_power_net_in_state`.
  `git diff --check` SẠCH.
- **Neighbours XONG thực chất 239/239** (chain log
  `hidden_files/n2514-chain.log`: NEIGHBOURS-START 02:05:21Z,
  NEIGHBOURS-EXIT 1 02:18:33Z, 791.00s — 238 passed, 1 failed:
  coolant test flake port-7777, proof của nó matches:true đủ 15 key,
  chỉ dính `ERROR: [MCP Runtime] Failed to start server on port 7777:
  22`; re-run module đó 4 passed, 56 subtests passed trong 16.83s,
  log `hidden_files/n2514-neighbours-rerun.log`) + **wiring XONG 32
  tests OK** (WIRING-START 02:18:33Z, WIRING-EXIT 0 02:20:43Z,
  130.176s).
- **Gate XONG (main-thread relaunch, script
  `hidden_files/n2514-gate-only-main.sh`, GATE-START 02:24:05Z
  worker launch chết theo session — log partial
  `full-suite-n2514-gate-partial-worker.log`; GATE-START 02:31:18Z
  main-thread relaunch, GATE-EXIT 1 02:51:13Z)** — xác minh độc lập
  lượt cron 10:00 +07 (đọc trực tiếp log
  `tools/mindustry_godot_transpiler/full-suite-n2514-gate.log`,
  163173 byte): Ran 6265 trong 1192.788s, failures=243,
  skipped=5 — 243 FAIL = 243 × `AssertionError: unexpectedly
  None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2513 — đúng 4
  test mới của N2514, +1 failure là reference-graph test của
  N2514, Godot-absent vì chain script reset PATH không có
  godot-bin).
- **Môi trường sau gate**: VM restart #15 lúc 01:36:30Z (uptime 1:29
  lúc 03:06Z) — TRƯỚC khi N2514 RED/GREEN (test file 01:42Z, proof
  .gd 01:43Z); không VM restart trong lúc chain/gate (02:05–02:51Z
  liền mạch); javalang 0.13.0 + pytest 9.2.0 importable OK (xác minh
  lượt này — pytest chạy được); port 7777 free trước mỗi lần chạy
  proof. Lượt sau vẫn kiểm tra lại javalang trước mọi gate theo quy
  tắc repo.
- **Gate xanh — commit + push theo mẫu 5 commit (slice TBD).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2514-gate-only-main.sh`
  (chỉ chạy gate, KHÔNG chạy lại chain — chain sẽ truncate log
  neighbours/wiring; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Chain + gate chạy liền một mạch từ main thread lượt cron trước
  (chain log `hidden_files/n2514-chain.log`):
  NEIGHBOURS-START 02:05:21Z, NEIGHBOURS-EXIT 1 02:18:33Z,
  WIRING-START 02:18:33Z, WIRING-EXIT 0 02:20:43Z,
  GATE-START 02:24:05Z (worker, chết), GATE-START 02:31:18Z
  (main-thread relaunch), GATE-EXIT 1 02:51:13Z.
  Ran 6265, failures=243 toàn Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513, nhớ bump Done total
  1742→1743 + row N2514 trong spec; comp 564/468, defense 210/209
  KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt RED, không đổi)

- N2514 = `BuildingComp.sense()` `powerNetIn` leg — leg deferred đầu
  tiên trong bốn powerNet leg BÊN TRONG `sense()`
  (BuildingComp.java:2114), tiếp theo trong Java switch order sau
  `totalItems` (dead :2098, health :2101, totalItems :2107,
  powerNetIn :2114, powerNetOut :2115, powerNetStored :2116,
  powerNetCapacity :2117, camera* :2122). Xem chi tiết scope file
  `docs/superpowers/handoffs/hidden_files/n2514-scope.md`.
- Số slice N2514, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2513).
- 1 pure function, KHÔNG driver tick. Wire shape: `handled` +
  `sense_value` + `sense_value_is_nan` (3 keys mới → symbols +3,
  tiền lệ N2283/N2284/N2511/N2512/N2513).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_building_comp_sense_power_net_in.py`
  (4 test methods, 6 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_building_comp_sense_power_net_in.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 10/10).
- Proof `C07BuildingCompSensePowerNetInProof.gd` + `.tscn` (6 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 9).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `BuildingComp.sense()` `powerNetIn` leg (`public double sense(LAccess
  sensor){`, BuildingComp.java:2093-2126): `case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;`
  (:2114), với `power` là power module của building
  (`@Nullable PowerModule power;`, BuildingComp.java:80) và
  `power.graph.getLastScaledPowerIn()` là last scaled power-in mỗi
  tick của graph (`public float getLastScaledPowerIn(){ return
  lastScaledPowerIn; }`, PowerGraph.java:45-47; cập nhật :233
  `lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta`).
  `* 60` đổi giá trị mỗi tick sang rate mỗi giây. Giá trị trả về
  chính xác: 0.0 khi power null, else `last_scaled_power_in * 60.0`
  chính xác (float * int literal 60; Java `sense()` returns double,
  float widen chính xác), không clamp, không làm tròn.
- N2284 đã port 23 handled legs của BuildingComp.sense
  (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/
  powerNet* deferred — powerNetIn deferred vì live graph values chưa
  có trong frame. N2511 port `dead`; N2512 port `health`; N2513 port
  `totalItems`; N2514 port đúng leg `powerNetIn` (leg powerNet đầu
  tiên).
- N2507 đã port dispatch outcome của SenseI.run() (null-target dead
  leg, senseObject-handled leg, noSensed fallback leg); N2510 là mảnh
  cuối chưa port của chính `SenseI.run()`. N2511/N2512/N2513/N2514 mở
  đầu các sensor leg BÊN TRONG sense() mà SenseI.run() gọi tới qua
  `se.sense(la)`.

## Tiếp theo (sau N2514)

- Các sensor leg BÊN TRONG `sense()` còn deferred, theo Java switch
  order: powerNetOut / powerNetStored / powerNetCapacity (:2115-2117;
  graph chưa live trong frame), camera* (:2122; cần UnitComp.sense
  delegation cho proxy unit, slice riêng). calculateHeat vẫn BLOCKED
  (live entity scan); findTarget vẫn BLOCKED.

## Deferred (không đổi)

- BuildingComp.sense() deferred sensor legs — powerNetOut/powerNetStored/
  powerNetCapacity (:2115-2117; the graph is not live in the frame),
  cameraX/cameraY/cameraWidth/cameraHeight (:2122; need
  UnitComp.sense delegation for the proxy unit, its own later slice).
  For duo they all still report handled false + NaN through this slice
  (duo has no power, so powerNet* folds to 0 inside N2284 itself — that fold is N2284's, not this
  slice's).
- Wiring the powerNetIn leg into a live logic-executor driver tick — the
  logic executor is not in the driver yet (same deferral as N2507
  dispatch hook, N2508 Content leg, N2509 size legs, N2510 LAccess
  leg, N2511 dead leg, N2512 health leg, N2513 totalItems leg,
  Turret control() shootp live wiring).
- Stamping live graph values from a tick into the frame — frame
  work riêng, params của N2514 là live input slice đó sẽ cung cấp.
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity
  scan.
