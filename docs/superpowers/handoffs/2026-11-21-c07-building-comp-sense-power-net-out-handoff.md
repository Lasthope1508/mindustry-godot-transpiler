# Handoff — N2515 BuildingComp.sense() `powerNetOut` leg (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice 7a7bd733, docs 1eef0f4c, GOAL 6d601f2d; cập nhật lượt cron 11:15 +07 — chain + gate main-thread xong GATE-EXIT 1 04:14:20Z, Ran 6269 trong 1468.612s, failures=244, skipped=5; xác minh độc lập: 244 FAIL = 244 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours XONG 243/243 sạch (0 flake, 825.91s), WIRING-EXIT 0 03:33:21Z; wiring XONG 32 tests OK. N2514 đã DONE + PUSHED (10574d77). Slice commit 7a7bd733, docs 1eef0f4c, GOAL 6d601f2d, status TBD. Targeted 4/4 (30 subtests, lượt worker GREEN, Godot trên PATH); register --verify 10/10; proof JSON matches:true 9/9 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11698/1744/1678/3147; `git diff --check` OK.

- N2514 DONE + PUSHED ~10:1x +07, origin/main == HEAD == 10574d77.
- **N2515 GREEN xong ~11:02 +07, lượt cron 11:15 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2515-scope.md`): 1 pure
  function `source_building_comp_sense_power_net_out_state(power_is_null, last_scaled_power_out)` trong
  SourceTurretBuildState.gd:668, ngay SAU
  `source_building_comp_sense_power_net_in_state` (N2514, :629, kết thúc
  ~:667), TRƯỚC `source_turret_sense_object_state` (N2506, :708 —
  bị đẩy từ :668) (mirror Java order — sense() :2093 →
  senseObject() :2128; trong sense() dead :2098 → health :2101 →
  totalItems :2107 → powerNetIn :2114 → powerNetOut :2115).
  KHÔNG driver tick (logic read). KHÔNG sửa
  `source_building_comp_sense_state`: powerNetOut vẫn `handled:false`
  trong big dispatch cho tới slice wiring sau.
- **Xác minh độc lập lượt cron 11:15 +07 (lượt này, đọc trực tiếp
  từ đĩa + log, KHÔNG chạy lại test/proof/gate)**: targeted **4/4
  (30 subtests, lượt worker GREEN, Godot trên PATH)**; register
  `--verify` **10/10 exprs present**; proof JSON **matches:true, 9/9
  keys, 6 semantic all true**
  (`C07BuildingCompSensePowerNetOutProof.json`, mtime 04:02:19Z
  ~11:02 +07, đọc trực tiếp từ đĩa); SSOT đo từ đĩa
  **11698/1744/1678/3147** — đúng kỳ vọng scope (+3 symbols / +1
  Done / +1 contract / +2 schemas); comp **565/469** (+1/+1, N2515
  vào comp shard — java_source BuildingComp.java, tiền lệ
  N2267/N2284/N2506/N2508/N2511/N2512/N2513/N2514); defense **210/209
  KHÔNG đổi**; ledger N2515 status done, java_source
  BuildingComp.java, godot_owner
  `SourceTurretBuildState.source_building_comp_sense_power_net_out_state`.
  `git diff --check` SẠCH.
- **Neighbours XONG 243/243 sạch** (chain log
  `hidden_files/n2515-chain.log`: NEIGHBOURS-START 03:17:23Z,
  NEIGHBOURS-EXIT 0 03:31:09Z, 243 passed trong 825.91s, 0 flake) +
  **wiring XONG 32 tests OK** (WIRING-START 03:31:09Z, WIRING-EXIT 0
  03:33:21Z, Ran 32 tests trong 131.024s, OK).
- **Gate XONG (main-thread relaunch, script
  `hidden_files/n2515-gate-only-main.sh`, GATE-START 03:47:44Z
  worker launch chết theo session — log partial
  `full-suite-n2515-gate-partial-worker.log`; GATE-START 03:49:49Z
  main-thread relaunch, GATE-EXIT 1 04:14:20Z)** — xác minh độc lập
  lượt cron 11:15 +07 (đọc trực tiếp log
  `tools/mindustry_godot_transpiler/full-suite-n2515-gate.log`,
  163876 byte): Ran 6269 trong 1468.612s, failures=244,
  skipped=5 — 244 FAIL = 244 × `AssertionError: unexpectedly
  None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2514 — đúng 4
  test mới của N2515, +1 failure là reference-graph test của
  N2515, Godot-absent vì chain script reset PATH không có
  godot-bin). Log gate KHÔNG có marker GATE-START/GATE-EXIT bên
  trong file — giờ gate lấy từ chain log
  `hidden_files/n2515-chain.log`.
- **Môi trường sau gate**: VM restart ~03:35Z (uptime 45 phút lúc
  04:20Z) — SAU wiring (03:33Z), TRƯỚC gate (03:47Z); gate chạy
  sau restart và sống tới EXIT; javalang 0.13.0 + pytest 9.2.0
  importable OK (xác minh lượt này); port 7777 free. Lượt sau vẫn
  kiểm tra lại javalang trước mọi gate theo quy tắc repo.
- **Gate xanh — commit + push theo mẫu 5 commit (slice 7a7bd733).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2515-gate-only-main.sh`
  (chỉ chạy gate, KHÔNG chạy lại chain — chain sẽ truncate log
  neighbours/wiring; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Chain + gate chạy liền một mạch từ main thread lượt cron trước
  (chain log `hidden_files/n2515-chain.log`):
  NEIGHBOURS-START 03:17:23Z, NEIGHBOURS-EXIT 0 03:31:09Z,
  WIRING-START 03:31:09Z, WIRING-EXIT 0 03:33:21Z,
  GATE-START 03:47:44Z (worker, chết), GATE-START 03:49:49Z
  (main-thread relaunch), GATE-EXIT 1 04:14:20Z.
  Ran 6269, failures=244 toàn Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514, nhớ bump Done total
  1743→1744 + row N2515 trong spec; comp 565/469, defense 210/209
  KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt RED, không đổi)

- N2515 = `BuildingComp.sense()` `powerNetOut` leg — leg deferred thứ
  hai trong bốn powerNet leg BÊN TRONG `sense()`
  (BuildingComp.java:2115), tiếp theo trong Java switch order sau
  `powerNetIn` (dead :2098, health :2101, totalItems :2107,
  powerNetIn :2114, powerNetOut :2115, powerNetStored :2116,
  powerNetCapacity :2117, camera* :2122). Xem chi tiết scope file
  `docs/superpowers/handoffs/hidden_files/n2515-scope.md`.
- Số slice N2515, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2514).
- 1 pure function, KHÔNG driver tick. Wire shape: `handled` +
  `sense_value` + `sense_value_is_nan` (3 keys mới → symbols +3,
  tiền lệ N2283/N2284/N2511/N2512/N2513/N2514).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_building_comp_sense_power_net_out.py`
  (4 test methods, 6 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_building_comp_sense_power_net_out.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 10/10).
- Proof `C07BuildingCompSensePowerNetOutProof.gd` + `.tscn` (6 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 9).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `BuildingComp.sense()` `powerNetOut` leg (`public double sense(LAccess
  sensor){`, BuildingComp.java:2093-2126): `case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;`
  (:2115), với `power` là power module của building
  (`@Nullable PowerModule power;`, BuildingComp.java:80) và
  `power.graph.getLastScaledPowerOut()` là last scaled power-out mỗi
  tick của graph (`public float getLastScaledPowerOut(){ return
  lastScaledPowerOut; }`, PowerGraph.java:49-51; cập nhật :234
  `lastScaledPowerOut = powerNeeded / Time.delta`).
  `* 60` đổi giá trị mỗi tick sang rate mỗi giây. Giá trị trả về
  chính xác: 0.0 khi power null, else `last_scaled_power_out * 60.0`
  chính xác (float * int literal 60; Java `sense()` returns double,
  float widen chính xác), không clamp, không làm tròn.
- N2284 đã port 23 handled legs của BuildingComp.sense
  (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/
  powerNet* deferred — powerNetOut deferred vì live graph values chưa
  có trong frame. N2511 port `dead`; N2512 port `health`; N2513 port
  `totalItems`; N2514 port `powerNetIn`; N2515 port đúng leg
  `powerNetOut` (leg powerNet thứ hai).
- N2507 đã port dispatch outcome của SenseI.run() (null-target dead
  leg, senseObject-handled leg, noSensed fallback leg); N2510 là mảnh
  cuối chưa port của chính `SenseI.run()`. N2511/N2512/N2513/N2514/N2515 mở
  đầu các sensor leg BÊN TRONG sense() mà SenseI.run() gọi tới qua
  `se.sense(la)`.

## Tiếp theo (sau N2515)

- Các sensor leg BÊN TRONG `sense()` còn deferred, theo Java switch
  order: powerNetStored / powerNetCapacity (:2116-2117;
  graph chưa live trong frame), camera* (:2122; cần UnitComp.sense
  delegation cho proxy unit, slice riêng). calculateHeat vẫn BLOCKED
  (live entity scan); findTarget vẫn BLOCKED.

## Deferred (không đổi)

- BuildingComp.sense() deferred sensor legs — powerNetStored/
  powerNetCapacity (:2116-2117; the graph is not live in the frame),
  cameraX/cameraY/cameraWidth/cameraHeight (:2122; need
  UnitComp.sense delegation for the proxy unit, its own later slice).
  For duo they all still report handled false + NaN through this slice
  (duo has no power, so powerNet* folds to 0 inside N2284 itself — that fold is N2284's, not this
  slice's).
- Wiring the powerNetOut leg into a live logic-executor driver tick — the
  logic executor is not in the driver yet (same deferral as N2507
  dispatch hook, N2508 Content leg, N2509 size legs, N2510 LAccess
  leg, N2511 dead leg, N2512 health leg, N2513 totalItems leg,
  N2514 powerNetIn leg, Turret control() shootp live wiring).
- Stamping live graph values from a tick into the frame — frame
  work riêng, params của N2515 là live input slice đó sẽ cung cấp.
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity
  scan.
