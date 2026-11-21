# Handoff — N2516 BuildingComp.sense() `powerNetStored` leg (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice 8f09495d, docs 7163cbf4, GOAL e742c1c3; cập nhật lượt cron 12:30 +07 — chain + gate xong GATE-EXIT 1 05:23:15Z, Ran 6273 trong 1482.999s, failures=245, skipped=5; xác minh độc lập: 245 FAIL = 245 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours XONG 247/247 sạch (0 flake, 921.09s), WIRING-EXIT 0 04:55:59Z; wiring XONG 32 tests OK. N2515 đã DONE + PUSHED (d9f55e2e). Slice commit 8f09495d, docs 7163cbf4, GOAL e742c1c3, status 7ee9409f. Targeted 4/4 (30 subtests, xác minh độc lập lượt này, Godot trên PATH); register --verify 10/10; proof JSON matches:true 9/9 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11701/1745/1679/3149; `git diff --check` OK.

- N2515 DONE + PUSHED ~11:14 +07, origin/main == HEAD == d9f55e2e.
- **N2516 GREEN xong ~11:53 +07, lượt cron 12:30 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2516-scope.md`): 1 pure
  function `source_building_comp_sense_power_net_stored_state(power_is_null, last_power_stored)` trong
  SourceTurretBuildState.gd:708, ngay SAU
  `source_building_comp_sense_power_net_out_state` (N2515, :668, kết thúc
  ~:707), TRƯỚC `source_turret_sense_object_state` (N2506, :749 —
  bị đẩy từ :708) (mirror Java order — sense() :2093 →
  senseObject() :2128; trong sense() dead :2098 → health :2101 →
  totalItems :2107 → powerNetIn :2114 → powerNetOut :2115 →
  powerNetStored :2116). KHÔNG driver tick (logic read). KHÔNG sửa
  `source_building_comp_sense_state`: powerNetStored vẫn `handled:false`
  trong big dispatch cho tới slice wiring sau.
- **Xác minh độc lập lượt cron 12:30 +07 (lượt này, đọc trực tiếp
  từ đĩa + log, tự chạy lại targeted + register)**: targeted **4/4
  (30 subtests, 20.33s, Godot trên PATH)**; register
  `--verify` **10/10 exprs present**; proof JSON **matches:true, 9/9
  keys, 6 semantic all true**
  (`C07BuildingCompSensePowerNetStoredProof.json`, mtime 04:53:19Z
  ~11:53 +07, đọc trực tiếp từ đĩa); SSOT đo từ đĩa
  **11701/1745/1679/3149** — đúng kỳ vọng scope (+3 symbols / +1
  Done / +1 contract / +2 schemas); comp **566/470** (+1/+1, N2516
  vào comp shard — java_source BuildingComp.java, tiền lệ
  N2267/N2284/N2506/N2508/N2511/N2512/N2513/N2514/N2515); defense **210/209
  KHÔNG đổi**; ledger N2516 status done, java_source
  BuildingComp.java, godot_owner
  `SourceTurretBuildState.source_building_comp_sense_power_net_stored_state`.
  `git diff --check` SẠCH.
- **Neighbours XONG 247/247 sạch** (chain log
  `hidden_files/n2516-chain.log`: NEIGHBOURS-START 04:38:15Z,
  NEIGHBOURS-EXIT 0 04:53:37Z, 247 passed trong 921.09s, 0 flake) +
  **wiring XONG 32 tests OK** (WIRING-START 04:53:37Z, WIRING-EXIT 0
  04:55:59Z, Ran 32 tests trong 142.052s, OK).
- **Gate XONG (chain log `hidden_files/n2516-chain.log`,
  GATE-START 04:58:30Z, GATE-EXIT 1 05:23:15Z)** — xác minh độc lập
  lượt cron 12:30 +07 (đọc trực tiếp log
  `tools/mindustry_godot_transpiler/full-suite-n2516-gate.log`,
  164597 byte): Ran 6273 trong 1482.999s, failures=245,
  skipped=5 — 245 FAIL = 245 × `AssertionError: unexpectedly
  None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2515 — đúng 4
  test mới của N2516, +1 failure là reference-graph test của
  N2516, Godot-absent vì chain script reset PATH không có
  godot-bin).
- **Môi trường sau gate**: VM restart #16 lúc 03:34:45Z — TRƯỚC
  chain (04:38Z), KHÔNG có restart trong lúc chain/gate; gate chạy
  sau restart và sống tới EXIT; javalang 0.13.0 + pytest 9.2.0
  importable OK (xác minh lượt này); port 7777 free. Lượt sau vẫn
  kiểm tra lại javalang trước mọi gate theo quy tắc repo.
- **Gate xanh — commit + push theo mẫu 5 commit (slice 8f09495d).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2516-chain-main.sh`
  (chain + gate liền một mạch; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng) và
  `hidden_files/n2516-gate-only-main.sh` (gate-only, dự phòng).
- Chain + gate chạy liền một mạch từ main thread lượt cron trước
  (worker scope cấm chạy neighbours/wiring/gate; worker báo
  GREEN-only — chain log `hidden_files/n2516-chain.log`):
  NEIGHBOURS-START 04:38:15Z, NEIGHBOURS-EXIT 0 04:53:37Z,
  WIRING-START 04:53:37Z, WIRING-EXIT 0 04:55:59Z,
  GATE-START 04:58:30Z, GATE-EXIT 1 05:23:15Z.
  Ran 6273, failures=245 toàn Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515, nhớ bump Done total
  1744→1745 + row N2516 trong spec; comp 566/470, defense 210/209
  KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt RED, không đổi)

- N2516 = `BuildingComp.sense()` `powerNetStored` leg — leg deferred thứ
  ba trong bốn powerNet leg BÊN TRONG `sense()`
  (BuildingComp.java:2116), tiếp theo trong Java switch order sau
  `powerNetOut` (dead :2098, health :2101, totalItems :2107,
  powerNetIn :2114, powerNetOut :2115, powerNetStored :2116,
  powerNetCapacity :2117, camera* :2122). Xem chi tiết scope file
  `docs/superpowers/handoffs/hidden_files/n2516-scope.md`.
- Số slice N2516, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2515).
- 1 pure function, KHÔNG driver tick. Wire shape: `handled` +
  `sense_value` + `sense_value_is_nan` (3 keys mới → symbols +3,
  tiền lệ N2283/N2284/N2511/N2512/N2513/N2514/N2515).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_building_comp_sense_power_net_stored.py`
  (4 test methods, 6 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_building_comp_sense_power_net_stored.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 10/10).
- Proof `C07BuildingCompSensePowerNetStoredProof.gd` + `.tscn` (6 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 9).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `BuildingComp.sense()` `powerNetStored` leg (`public double sense(LAccess
  sensor){`, BuildingComp.java:2093-2126): `case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();`
  (:2116), với `power` là power module của building
  (`@Nullable PowerModule power;`, BuildingComp.java:80) và
  `power.graph.getLastPowerStored()` là last stored battery power của
  graph (`public float getLastPowerStored(){ return lastPowerStored; }`,
  PowerGraph.java:73-75; cập nhật :236
  `lastPowerStored = getBatteryStored()`). KHÔNG có `* 60` ở đây —
  stored value là absolute amount (battery charge), không phải
  per-tick rate, nên trả về as-is. Giá trị trả về
  chính xác: 0.0 khi power null, else `last_power_stored` chính xác
  (float widen chính xác sang double), không clamp, không làm tròn.
- N2284 đã port 23 handled legs của BuildingComp.sense
  (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/
  powerNet* deferred — powerNetStored deferred vì live graph values chưa
  có trong frame. N2511 port `dead`; N2512 port `health`; N2513 port
  `totalItems`; N2514 port `powerNetIn`; N2515 port `powerNetOut`;
  N2516 port đúng leg `powerNetStored` (leg powerNet thứ ba).
- N2507 đã port dispatch outcome của SenseI.run() (null-target dead
  leg, senseObject-handled leg, noSensed fallback leg); N2510 là mảnh
  cuối chưa port của chính `SenseI.run()`. N2511/N2512/N2513/N2514/N2515/N2516 mở
  đầu các sensor leg BÊN TRONG sense() mà SenseI.run() gọi tới qua
  `se.sense(la)`.

## Tiếp theo (sau N2516)

- Các sensor leg BÊN TRONG `sense()` còn deferred, theo Java switch
  order: powerNetCapacity (:2117;
  graph chưa live trong frame), camera* (:2122; cần UnitComp.sense
  delegation cho proxy unit, slice riêng). calculateHeat vẫn BLOCKED
  (live entity scan); findTarget vẫn BLOCKED.

## Deferred (không đổi)

- BuildingComp.sense() deferred sensor legs — powerNetCapacity
  (:2117; the graph is not live in the frame),
  cameraX/cameraY/cameraWidth/cameraHeight (:2122; need
  UnitComp.sense delegation for the proxy unit, its own later slice).
  For duo they all still report handled false + NaN through this slice
  (duo has no power, so powerNet* folds to 0 inside N2284 itself — that fold is N2284's, not this
  slice's).
- Wiring the powerNetStored leg into a live logic-executor driver tick — the
  logic executor is not in the driver yet (same deferral as N2507
  dispatch hook, N2508 Content leg, N2509 size legs, N2510 LAccess
  leg, N2511 dead leg, N2512 health leg, N2513 totalItems leg,
  N2514 powerNetIn leg, N2515 powerNetOut leg, Turret control() shootp live wiring).
- Stamping live graph values from a tick into the frame — frame
  work riêng, params của N2516 là live input slice đó sẽ cung cấp.
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity
  scan.
