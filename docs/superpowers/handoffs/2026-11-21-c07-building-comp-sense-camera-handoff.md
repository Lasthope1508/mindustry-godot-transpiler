# Handoff — N2518 BuildingComp.sense() `cameraX/cameraY/cameraWidth/cameraHeight` legs (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice 16a4c589, docs 35fe74b7, GOAL 4c1421f4; cập nhật lượt cron 14:45 +07 — chain + gate xong GATE-EXIT 1 07:38:59Z, Ran 6281 trong 1222.743s, failures=247, skipped=5; xác minh độc lập: 247 FAIL = 247 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours 255/255 sạch (0 flake), WIRING-EXIT 0 07:17:21Z; wiring XONG 32 tests OK. N2517 đã DONE + PUSHED (cd95fc18). Slice commit 16a4c589, docs 35fe74b7, GOAL 4c1421f4, status TBD. Targeted 4/4 (34 subtests, xác minh độc lập lượt này, Godot trên PATH); register --verify 11/11; proof JSON matches:true 11/11 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11707/1747/1681/3153; `git diff --check` OK.

- N2517 DONE + PUSHED ~13:30 +07, origin/main == HEAD == cd95fc18.
- **N2518 GREEN xong ~14:15 +07, lượt cron 14:45 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2518-scope.md`): 1 pure
  function `source_building_comp_sense_camera_state(sensor: String, is_control_block: bool, unit_sense_value: float)` trong
  SourceTurretBuildState.gd:791, ngay SAU
  `source_building_comp_sense_power_net_capacity_state` (N2517, :749, kết thúc
  ~:790), TRƯỚC `source_turret_sense_object_state` (N2506, :841 —
  bị đẩy từ :791) (mirror Java order — sense() :2093 →
  senseObject() :2128; trong sense() dead :2098 → health :2101 →
  totalItems :2107 → powerNetIn :2114 → powerNetOut :2115 →
  powerNetStored :2116 → powerNetCapacity :2117 → camera* :2122 — leg
  CUỐI CÙNG của sense()). KHÔNG driver tick (logic read). KHÔNG sửa
  `source_building_comp_sense_state`: camera* vẫn `handled:false`
  trong big dispatch cho tới slice wiring sau.
- **Xác minh độc lập lượt cron 14:45 +07 (lượt này, đọc trực tiếp
  từ đĩa + log, tự chạy lại targeted + register)**: targeted **4/4
  (34 subtests, 17.33s, Godot trên PATH)**; register
  `--verify` **11/11 exprs present**; proof JSON **matches:true, 11/11
  keys, 8 semantic all true**
  (`C07BuildingCompSenseCameraProof.json`, đọc trực tiếp từ
  đĩa — file được targeted run tái tạo lại giống hệt sau khi đọc lần đầu);
  SSOT đo từ đĩa
  **11707/1747/1681/3153** — đúng kỳ vọng scope (+3 symbols / +1
  Done / +1 contract / +2 schemas); comp **568/472** (+1/+1, N2518
  vào comp shard — java_source BuildingComp.java, tiền lệ
  N2267/N2284/N2506/N2508/N2511/N2512/N2513/N2514/N2515/N2516/N2517); defense **210/209
  KHÔNG đổi**; ledger N2518 status done, java_source
  BuildingComp.java, godot_owner
  `SourceTurretBuildState.source_building_comp_sense_camera_state`.
  `git diff --check` SẠCH.
- **Neighbours 255/255 sạch** (chain log
  `hidden_files/n2518-chain.log`: NEIGHBOURS-START 06:53:24Z
  worker-launch partial, relaunch main thread 07:01:20Z,
  NEIGHBOURS-EXIT 0 07:15:17Z, 255 passed trong 836.70s, 0 flake) +
  **wiring XONG 32 tests OK** (WIRING-START 07:15:17Z, WIRING-EXIT 0
  07:17:21Z, Ran 32 tests trong 123.904s, OK).
- **Gate XONG (chain log `hidden_files/n2518-chain.log`,
  GATE-START 07:17:28Z worker-launch chết partial, relaunch main
  thread 07:18:35Z, GATE-EXIT 1 07:38:59Z)** — xác minh độc lập
  lượt cron 14:45 +07 (đọc trực tiếp log
  `tools/mindustry_godot_transpiler/full-suite-n2518-gate.log`,
  165993 byte): Ran 6281 trong 1222.743s, failures=247,
  skipped=5 — 247 FAIL = 247 × `AssertionError: unexpectedly
  None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2517 — đúng 4
  test mới của N2518, +1 failure là reference-graph test của
  N2518, Godot-absent vì chain script reset PATH không có
  godot-bin).
- **Môi trường sau gate**: VM restart #17 lúc 05:41:54Z — TRƯỚC
  chain (06:53Z/07:01Z), KHÔNG có restart trong lúc chain/gate; gate chạy
  sau restart và sống tới EXIT; javalang 0.13.0 + pytest 9.2.0
  importable OK (xác minh lượt này); port 7777 free. Lượt sau vẫn
  kiểm tra lại javalang trước mọi gate theo quy tắc repo.
- **Gate xanh — commit + push theo mẫu 5 commit (slice 16a4c589).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2518-chain-main.sh`
  (neighbours + wiring, NO gate) và
  `hidden_files/n2518-gate-only-main.sh` (gate-only; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Chain + gate chạy từ main thread lượt cron 14:15 +07
  (worker scope cấm chạy neighbours/wiring/gate; worker báo
  GREEN-only — chain log `hidden_files/n2518-chain.log`):
  NEIGHBOURS-START 06:53:24Z (worker-launch partial, log
  `hidden_files/n2518-neighbours-partial-worker.log` /
  `n2518-chain-partial-worker.log`),
  NEIGHBOURS-START 07:01:20Z (relaunch main thread),
  NEIGHBOURS-EXIT 0 07:15:17Z (255 passed, 0 flake),
  WIRING-START 07:15:17Z, WIRING-EXIT 0 07:17:21Z,
  GATE-START 07:17:28Z (worker-launch chết partial, log
  `full-suite-n2518-gate-partial-worker.log`),
  GATE-START 07:18:35Z (relaunch main thread),
  GATE-EXIT 1 07:38:59Z.
  Ran 6281, failures=247 toàn Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517, nhớ bump Done total
  1746→1747 + row N2518 trong spec; comp 568/472, defense 210/209
  KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt RED, không đổi)

- N2518 = `BuildingComp.sense()` `cameraX/cameraY/cameraWidth/cameraHeight`
  legs — BỐN leg camera trong MỘT case line Java, leg CUỐI CÙNG bên
  trong `sense()` (BuildingComp.java:2122), tiếp theo trong Java switch
  order sau `powerNetCapacity` (dead :2098, health :2101, totalItems
  :2107, powerNetIn :2114, powerNetOut :2115, powerNetStored :2116,
  powerNetCapacity :2117, camera* :2122). Xem chi tiết scope file
  `docs/superpowers/handoffs/hidden_files/n2518-scope.md`.
- Số slice N2518, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2517).
- ONE slice ports ALL FOUR legs (một case line, một delegation
  expression `c.unit().sense(sensor)`, sensor name là input phân biệt
  duy nhất): 1 pure function với param `sensor: String` (một trong bốn
  LAccess label), KHÔNG validate sensor (dispatch đảm bảo, tiền lệ
  N2511–N2517). Wire shape: `handled` + `sense_value` +
  `sense_value_is_nan` (3 keys mới → symbols +3, tiền lệ
  N2283/N2284/N2511/N2512/N2513/N2514/N2515/N2516/N2517).
- Delegation: unit sense camera legs ĐÃ port trong
  `SourceUnitSensorState.laccess_state` (SourceUnitSensorState.gd:41-44,
  UnitComp.java:264, :283-286) — slice này chỉ port BuildingComp gate
  (`instanceof ControlBlock` + fallback 0 + pass-through unit sense
  value); KHÔNG re-port unit-side camera math. `unit_sense_value` là
  param (per-def-param precedent N2212/N2220/N2511–N2517); wiring slice
  sau sẽ gọi `SourceUnitSensorState.laccess_state(sensor, unit_state,
  tilesize)` và pass `value` vào. `c.unit()` không cần null branch:
  proxy unit tạo lúc construction (Turret.java:291, :434-439).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_building_comp_sense_camera.py`
  (4 test methods, 8 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_building_comp_sense_camera.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 11/11).
- Proof `C07BuildingCompSenseCameraProof.gd` + `.tscn` (8 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 11).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `BuildingComp.sense()` camera legs (`public double sense(LAccess
  sensor){`, BuildingComp.java:2093-2126): `case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`
  (:2122; sensor spellings là LAccess enum names, LAccess.java:37-40).
  Giá trị trả về chính xác: 0.0 khi KHÔNG phải ControlBlock, else
  `unit_sense_value` chính xác (float widen chính xác sang double),
  không clamp, không làm tròn, không World.conv ở đây (conv đã xảy ra
  bên trong unit sense call). `handled` luôn true; `sense_value_is_nan`
  luôn false.
- UnitComp.sense camera legs (UnitComp.java:264, :283-286): `case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;`
  (cameraY / cameraWidth / cameraHeight tương tự) — 0 khi controller
  không phải Player, else `World.conv` của player view / core camera
  value. Đã port trong `SourceUnitSensorState.laccess_state`.
- N2284 đã port 23 handled legs của BuildingComp.sense
  (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/
  powerNet* deferred — N2511 port `dead`; N2512 port `health`; N2513 port
  `totalItems`; N2514 port `powerNetIn`; N2515 port `powerNetOut`;
  N2516 port `powerNetStored`; N2517 port `powerNetCapacity`; N2518 port
  camera* — **sense() legs đã HOÀN TẤT, không còn leg deferred nào bên
  trong sense()**.
- N2507 đã port dispatch outcome của SenseI.run() (null-target dead
  leg, senseObject-handled leg, noSensed fallback leg); N2510 là mảnh
  cuối chưa port của chính `SenseI.run()`. N2511–N2518 mở đầu các sensor
  leg BÊN TRONG sense() mà SenseI.run() gọi tới qua `se.sense(la)`.

## Tiếp theo (sau N2518)

- Các sensor leg BÊN TRONG `sense()` đã port HẾT (dead, health,
  totalItems, powerNetIn, powerNetOut, powerNetStored, powerNetCapacity,
  camera*) — sense() hoàn tất ở tầng pure function. Slice tiếp theo
  (N2519) cần scope mới từ backlog: wiring các sense leg vào live
  logic-executor driver tick (logic executor chưa có trong driver) hoặc
  item deferred tiếp theo trong BuildingComp. calculateHeat vẫn BLOCKED
  (live entity scan); findTarget vẫn BLOCKED.

## Deferred (không đổi)

- Wiring các camera legs vào live logic-executor driver tick — wiring
  slice sẽ gọi `SourceUnitSensorState.laccess_state(sensor, unit_state,
  tilesize)` cho proxy unit và pass `value` làm `unit_sense_value`
  (logic executor chưa có trong driver).
- Stamping live unit sense values từ tick vào frame — frame work
  riêng, params của N2518 là live input slice đó sẽ cung cấp.
- Wiring các sense leg khác (dead/health/totalItems/powerNet*) vào live
  logic-executor driver tick — cùng deferral như N2518.
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity scan.
