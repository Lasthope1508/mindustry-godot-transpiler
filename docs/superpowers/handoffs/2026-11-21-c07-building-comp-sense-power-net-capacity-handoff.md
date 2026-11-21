# Handoff — N2517 BuildingComp.sense() `powerNetCapacity` leg (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice d1cab0a5, docs 425df203, GOAL e385c91c; cập nhật lượt cron 13:30 +07 — chain + gate xong GATE-EXIT 1 06:27:00Z, Ran 6277 trong 1215.192s, failures=246, skipped=5; xác minh độc lập: 246 FAIL = 246 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours thực chất 251/251 (250 pass + 1 flake port-7777, re-run 4/4 xanh), WIRING-EXIT 0 06:02:01Z; wiring XONG 32 tests OK. N2516 đã DONE + PUSHED (a22c8dcf). Slice commit d1cab0a5, docs 425df203, GOAL e385c91c, status e1da580e. Targeted 4/4 (30 subtests, xác minh độc lập lượt này, Godot trên PATH); register --verify 10/10; proof JSON matches:true 9/9 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11704/1746/1680/3151; `git diff --check` OK.

- N2516 DONE + PUSHED ~12:30 +07, origin/main == HEAD == a22c8dcf.
- **N2517 GREEN xong ~12:40 +07, lượt cron 13:30 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2517-scope.md`): 1 pure
  function `source_building_comp_sense_power_net_capacity_state(power_is_null, last_capacity)` trong
  SourceTurretBuildState.gd:749, ngay SAU
  `source_building_comp_sense_power_net_stored_state` (N2516, :708, kết thúc
  ~:748), TRƯỚC `source_turret_sense_object_state` (N2506, :791 —
  bị đẩy từ :749) (mirror Java order — sense() :2093 →
  senseObject() :2128; trong sense() dead :2098 → health :2101 →
  totalItems :2107 → powerNetIn :2114 → powerNetOut :2115 →
  powerNetStored :2116 → powerNetCapacity :2117). KHÔNG driver tick (logic read). KHÔNG sửa
  `source_building_comp_sense_state`: powerNetCapacity vẫn `handled:false`
  trong big dispatch cho tới slice wiring sau.
- **Xác minh độc lập lượt cron 13:30 +07 (lượt này, đọc trực tiếp
  từ đĩa + log, tự chạy lại targeted + register)**: targeted **4/4
  (30 subtests, 17.21s, Godot trên PATH)** — lần chạy đầu không có
  Godot trên PATH báo 3/4 (reference-graph test fail vì không tìm
  thấy godot, đúng bài học N2515), chạy lại với
  `~/workspace/godot-bin` trên PATH thì 4/4 xanh; register
  `--verify` **10/10 exprs present**; proof JSON **matches:true, 9/9
  keys, 6 semantic all true**
  (`C07BuildingCompSensePowerNetCapacityProof.json`, đọc trực tiếp từ
  đĩa); SSOT đo từ đĩa
  **11704/1746/1680/3151** — đúng kỳ vọng scope (+3 symbols / +1
  Done / +1 contract / +2 schemas); comp **567/471** (+1/+1, N2517
  vào comp shard — java_source BuildingComp.java, tiền lệ
  N2267/N2284/N2506/N2508/N2511/N2512/N2513/N2514/N2515/N2516); defense **210/209
  KHÔNG đổi**; ledger N2517 status done, java_source
  BuildingComp.java, godot_owner
  `SourceTurretBuildState.source_building_comp_sense_power_net_capacity_state`.
  `git diff --check` SẠCH.
- **Neighbours thực chất 251/251** (chain log
  `hidden_files/n2517-chain.log`: NEIGHBOURS-START 05:46:10Z
  main-thread relaunch, NEIGHBOURS-EXIT 1 05:59:56Z, 250 passed + 1
  failed trong 824.92s; failed duy nhất là
  `test_reference_graph_and_actual_c07_point_defense_turret_target_acquire`
  — ERROR `[MCP Runtime] Failed to start server on port 7777: 22`,
  flake port-7777 đã biết, KHÔNG phải regression; re-run module đó
  4 passed / 38 subtests trong 13.87s, log
  `hidden_files/n2517-neighbours-rerun.log`) +
  **wiring XONG 32 tests OK** (WIRING-START 05:59:56Z, WIRING-EXIT 0
  06:02:01Z, Ran 32 tests trong 125.527s, OK).
- **Gate XONG (chain log `hidden_files/n2517-chain.log`,
  GATE-START 06:06:43Z, GATE-EXIT 1 06:27:00Z)** — xác minh độc lập
  lượt cron 13:30 +07 (đọc trực tiếp log
  `tools/mindustry_godot_transpiler/full-suite-n2517-gate.log`,
  165330 byte): Ran 6277 trong 1215.192s, failures=246,
  skipped=5 — 246 FAIL = 246 × `AssertionError: unexpectedly
  None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2516 — đúng 4
  test mới của N2517, +1 failure là reference-graph test của
  N2517, Godot-absent vì chain script reset PATH không có
  godot-bin).
- **Môi trường sau gate**: VM restart #17 lúc 05:41Z — TRƯỚC
  chain (05:44Z/05:46Z), KHÔNG có restart trong lúc chain/gate; gate chạy
  sau restart và sống tới EXIT; javalang 0.13.0 + pytest 9.2.0
  importable OK (xác minh lượt này); port 7777 free. Lượt sau vẫn
  kiểm tra lại javalang trước mọi gate theo quy tắc repo.
- **Gate xanh — commit + push theo mẫu 5 commit (slice d1cab0a5).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2517-chain-main.sh`
  (chain + gate liền một mạch; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng) và
  `hidden_files/n2517-gate-only-main.sh` (gate-only, dự phòng).
- Chain + gate chạy liền một mạch từ main thread lượt cron 12:45 +07
  (worker scope cấm chạy neighbours/wiring/gate; worker báo
  GREEN-only — chain log `hidden_files/n2517-chain.log`):
  NEIGHBOURS-START 05:46:10Z (relaunch main thread; lần worker-launch
  05:44:07Z chết partial, log
  `hidden_files/n2517-chain-partial-0544z.log` /
  `n2517-neighbours-partial-0544z.log`),
  NEIGHBOURS-EXIT 1 05:59:56Z (1 flake port-7777, re-run 4/4 xanh),
  WIRING-START 05:59:56Z, WIRING-EXIT 0 06:02:01Z,
  GATE-START 06:06:43Z, GATE-EXIT 1 06:27:00Z.
  Ran 6277, failures=246 toàn Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516, nhớ bump Done total
  1745→1746 + row N2517 trong spec; comp 567/471, defense 210/209
  KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt RED, không đổi)

- N2517 = `BuildingComp.sense()` `powerNetCapacity` leg — leg deferred
  cuối cùng trong bốn powerNet leg BÊN TRONG `sense()`
  (BuildingComp.java:2117), tiếp theo trong Java switch order sau
  `powerNetStored` (dead :2098, health :2101, totalItems :2107,
  powerNetIn :2114, powerNetOut :2115, powerNetStored :2116,
  powerNetCapacity :2117, camera* :2122). Xem chi tiết scope file
  `docs/superpowers/handoffs/hidden_files/n2517-scope.md`.
- Số slice N2517, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2516).
- 1 pure function, KHÔNG driver tick. Wire shape: `handled` +
  `sense_value` + `sense_value_is_nan` (3 keys mới → symbols +3,
  tiền lệ N2283/N2284/N2511/N2512/N2513/N2514/N2515/N2516).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_building_comp_sense_power_net_capacity.py`
  (4 test methods, 6 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_building_comp_sense_power_net_capacity.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 10/10).
- Proof `C07BuildingCompSensePowerNetCapacityProof.gd` + `.tscn` (6 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 9).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `BuildingComp.sense()` `powerNetCapacity` leg (`public double sense(LAccess
  sensor){`, BuildingComp.java:2093-2126): `case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();`
  (:2117), với `power` là power module của building
  (`@Nullable PowerModule power;`, BuildingComp.java:80) và
  `power.graph.getLastCapacity()` là last total battery capacity của
  graph (`public float getLastCapacity(){ return lastCapacity; }`,
  PowerGraph.java:53-54; cập nhật :235
  `lastCapacity = getTotalBatteryCapacity()`). KHÔNG có `* 60` ở đây —
  capacity là absolute amount (total battery capacity), không phải
  per-tick rate, nên trả về as-is (giống powerNetStored). Tên method
  chính xác là `getLastCapacity()`, KHÔNG phải
  `getLastPowerCapacity()`. Giá trị trả về
  chính xác: 0.0 khi power null, else `last_capacity` chính xác
  (float widen chính xác sang double), không clamp, không làm tròn.
- N2284 đã port 23 handled legs của BuildingComp.sense
  (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/
  powerNet* deferred — powerNetCapacity deferred vì live graph values chưa
  có trong frame. N2511 port `dead`; N2512 port `health`; N2513 port
  `totalItems`; N2514 port `powerNetIn`; N2515 port `powerNetOut`;
  N2516 port `powerNetStored`; N2517 port đúng leg `powerNetCapacity`
  (leg powerNet cuối cùng trong bốn leg).
- N2507 đã port dispatch outcome của SenseI.run() (null-target dead
  leg, senseObject-handled leg, noSensed fallback leg); N2510 là mảnh
  cuối chưa port của chính `SenseI.run()`. N2511/N2512/N2513/N2514/N2515/N2516/N2517 mở
  đầu các sensor leg BÊN TRONG sense() mà SenseI.run() gọi tới qua
  `se.sense(la)`.

## Tiếp theo (sau N2517)

- Các sensor leg BÊN TRONG `sense()` còn deferred, theo Java switch
  order: camera* (:2122; cần UnitComp.sense delegation cho proxy
  unit, slice riêng). Bốn leg powerNet đã port xong
  (powerNetIn/powerNetOut/powerNetStored/powerNetCapacity).
  calculateHeat vẫn BLOCKED (live entity scan); findTarget vẫn BLOCKED.

## Deferred (không đổi)

- BuildingComp.sense() deferred sensor legs — cameraX/cameraY/
  cameraWidth/cameraHeight (:2122; need UnitComp.sense delegation for
  the proxy unit, its own later slice). For duo they all still report
  handled false + NaN through this slice (duo has no power, so
  powerNet* folds to 0 inside N2284 itself — that fold is N2284's,
  not this slice's).
- Wiring the powerNetCapacity leg into a live logic-executor driver tick — the
  logic executor is not in the driver yet (same deferral as N2507
  dispatch hook, N2508 Content leg, N2509 size legs, N2510 LAccess
  leg, N2511 dead leg, N2512 health leg, N2513 totalItems leg,
  N2514 powerNetIn leg, N2515 powerNetOut leg, N2516 powerNetStored leg,
  Turret control() shootp live wiring).
- Stamping live graph values from a tick into the frame — frame
  work riêng, params của N2517 là live input slice đó sẽ cung cấp.
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity
  scan.
