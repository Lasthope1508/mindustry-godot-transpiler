# Handoff — N2510 SenseI LAccess numeric dispatch `se.sense(la)` (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice a86bd7a6, docs c4026c27, GOAL 9f1a413e; cập nhật lượt cron 04:30 +07 — gate main-thread xong GATE-EXIT 1 21:24:22Z, Ran 6249 trong 2145.733s, failures=239, skipped=5; xác minh độc lập: 239 FAIL = 239 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours XONG 222 passed + 1 failed (flake port-7777, re-run riêng 4/4 → thực chất 223/223), WIRING-EXIT 0 20:45:19Z; wiring XONG 32 tests OK. N2509 đã DONE + PUSHED (4793edfb). Slice commit a86bd7a6, docs c4026c27, GOAL 9f1a413e, status TBD. Targeted 4/4 (47 subtests, re-run độc lập lượt cron 04:30 +07, 14.72s pytest + 18.762s unittest, Godot trên PATH); register --verify 21/21; proof JSON matches:true 9/9 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11683/1739/1673/3137; `git diff --check` OK.

- N2509 DONE + PUSHED ~02:30 +07, origin/main == HEAD == 4793edfb.
- **N2510 GREEN xong lượt cron 03:15 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2510-scope.md`): 1 pure
  function `source_logic_sense_laccess_state(sensor,
  turret_handled, turret_sense_value, comp_handled,
  comp_sense_value)` trong SourceTurretBuildState.gd:688, ngay SAU
  `source_logic_sense_content_state` (N2508, :646), TRƯỚC
  `source_logic_sense_size_state` (N2509, :728 — bị đẩy từ :688),
  TRƯỚC `source_turret_progress_state` (:772). KHÔNG driver tick
  (logic read).
- **RED xác minh độc lập lượt cron 03:00 +07**: 4 failed trong
  24.36s (gồm test_reference_graph_and_actual_c07_turret_logic_sense_laccess
  và test_turret_logic_sense_laccess_state) — đúng kỳ vọng trước GREEN.
- **Xác minh độc lập lượt cron 04:30 +07 (lượt này, đọc trực tiếp
  từ đĩa + chạy lại)**: targeted **4/4 (47 subtests, 14.72s
  pytest; 18.762s unittest)**, Godot 4.6.2 trên PATH; register
  `--verify` **21/21 exprs present**; proof JSON
  **matches:true, 9/9 keys, 6 semantic all true**
  (`C07TurretLogicSenseLAccessProof.json`); SSOT đo từ đĩa
  **11683/1739/1673/3137** — đúng kỳ vọng scope (+3 symbols / +1
  Done / +1 contract / +2 schemas); comp **560/464**, defense
  **210/209 KHÔNG đổi** (N2510 sống ở canonical SSOT only —
  java_source LExecutor.java, `core/src/mindustry/logic/` không
  chọn vào shard nào, tiền lệ N2507/N2509); ledger N2510 status done
  (1739/1739 done). `git diff --check` SẠCH.
- **Neighbours XONG 222 passed + 1 failed** (chain log
  `hidden_files/n2510-chain.log`: NEIGHBOURS-START 20:17:55Z,
  NEIGHBOURS-EXIT 1 20:41:25Z, 1408.80s) + **wiring XONG 32 tests
  OK** (WIRING-START 20:41:25Z, WIRING-EXIT 0 20:45:19Z, 233.983s).
  Fail duy nhất: test_c07_point_defense_turret_aim_shoot.py —
  proof JSON matches:true, 11/11 key true, chỉ dính `ERROR: [MCP
  Runtime] Failed to start server on port 7777: 22` (CoolantProof
  giữ port lúc đó) — đúng flake port-7777 đã biết, không phải hồi
  quy (module này PASS 4/4 ở chain N2509). **Re-run riêng XONG 4
  passed trong 27.68s** (RERUN-EXIT 0 20:48:19Z, log
  `hidden_files/n2510-neighbours-rerun.log`) → neighbours thực chất
  **223/223**.
- **Gate XONG (main-thread launch, script
  `hidden_files/n2510-gate-only-main.sh`, GATE-START 20:48:34Z,
  GATE-EXIT 1 21:24:22Z)** — xác minh độc lập lượt cron 04:30 +07
  (đọc trực tiếp log `tools/mindustry_godot_transpiler/full-suite-n2510-gate.log`,
  160470 bytes): Ran 6249 trong 2145.733s, failures=239,
  skipped=5 — 239 FAIL = 239 × `AssertionError: unexpectedly
  None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2509 — đúng 4
  test mới của N2510, +1 failure là reference-graph test của N2510,
  Godot-absent vì chain script reset PATH không có godot-bin).
  Gate chậm hơn thường lệ (~35.8 phút vs ~20 phút các gate trước;
  đuôi suite có test nặng CPU) nhưng process sống tới EXIT, không
  chết giữa chừng, không VM restart trong lúc gate (PID1 vẫn
  19:34:36Z — restart lần 12 trong ngày, TRƯỚC GATE-START).
- **Môi trường sau gate**: lượt cron 04:30 +07 phát hiện
  javalang + pytest đã bị wipe khỏi hệ thống (import javalang lỗi,
  `which pytest` trống) dù không có VM restart mới sau GATE-EXIT —
  nguyên nhân wipe chưa rõ; đã cài lại javalang 0.13.0 (requirements.txt)
  + pytest 9.2.0 lượt này, xác minh import OK. Lượt sau vẫn kiểm
  tra lại javalang trước mọi gate theo quy tắc repo.
- **Gate xanh — commit + push theo mẫu 5 commit (slice a86bd7a6).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script sẵn:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2510-gate-only-main.sh`
  (chỉ chạy gate, KHÔNG chạy lại chain — chain sẽ truncate log
  neighbours/wiring; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Kỳ vọng gate: Ran ~6249, failures ~239, skipped=5, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2509 — đúng 4
  test mới của N2510, +1 failure là reference-graph test của
  N2510, Godot-absent vì chain script reset PATH không có godot-bin).
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506/N2507/N2508/N2509, nhớ bump Done total 1738→1739 + row N2510
  trong spec; comp 560/464, defense 210/209 KHÔNG đổi; GOAL §5 thêm
  dòng nợ Windows).

## Scope (khóa từ lượt RED, không đổi)

- N2510 = `SenseI.run()` LAccess leg — logic-processor `sense` op
  khi target IS a Senseable và sensor IS an LAccess
  (LExecutor.java:694-703). Xem chi tiết scope file
  `docs/superpowers/handoffs/hidden_files/n2510-scope.md`.
- Số slice N2510, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2509).
- 1 pure function, KHÔNG driver tick. Wire shape: `handled` +
  `sense_value` + `sense_value_is_nan` (3 keys mới → symbols +3,
  tiền lệ N2283/N2284).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_turret_logic_sense_laccess.py`
  (4 test methods, 6 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_turret_logic_sense_laccess.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 21/21).
- Proof `C07TurretLogicSenseLAccessProof.gd` + `.tscn` (6 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 9).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `SenseI.run()` LAccess leg (LExecutor.java:694-703): `}else
  if(sense instanceof LAccess la){` (:694); `Object objOut =
  se.senseObject(la);` (:695); `if(objOut ==
  Senseable.noSensed){` (:697) → `to.setnum(se.sense(la));`
  (:699); `else` → `to.setobj(objOut);` (:701).
- Java dispatch order là Turret.sense FIRST (`public double
  sense(LAccess sensor){`, Turret.java:405-419: `case ammo ->
  totalAmmo;` / `case ammoCapacity -> maxAmmo;` / `case rotation
  -> rotation;` / `case shootX -> World.conv(targetPos.x);` /
  `case shootY -> World.conv(targetPos.y);` / `case shooting ->
  isShooting ? 1 : 0;` / `case progress -> progress();`), `default`
  rơi xuống super.sense (`default -> super.sense(sensor);`,
  Turret.java:417; BuildingComp.sense, BuildingComp.java:2093-2126,
  23 handled legs), default NaN (`default -> Float.NaN; //gets
  converted to null in logic`, :2123). Overlap duy nhất là
  `rotation` — cả hai switch đều handle, cùng đọc live frame
  rotation; thứ tự pin bằng synthetic values khác nhau trong proof
  (`turret_wins_rotation`: turret 45.0 thắng comp 90.0).
- N2507 đã port dispatch outcome của nhánh này (null-target dead
  leg, senseObject-handled leg, noSensed fallback leg) nhưng nhận
  numeric value làm param; N2510 port đúng phần resolution của
  `se.sense(la)` mà N2507 chưa port. N2508 port Content leg
  (`se.sense(co)`), N2509 else-branch non-Senseable; N2510 là mảnh
  cuối chưa port của chính `SenseI.run()`.

## Tiếp theo (sau N2510)

- `SenseI.run()` đã port xong toàn bộ (N2507 dispatch hook +
  N2508 Content leg + N2509 else-branch + N2510 LAccess leg).
  Chọn slice tiếp theo từ deferred list — ứng viên: các sensor leg
  BÊN TRONG sense() (dead/health/totalItems/camera*/powerNet* —
  khi có live input); powerNet* graph legs. calculateHeat vẫn
  BLOCKED (live entity scan); findTarget vẫn BLOCKED.

## Deferred (không đổi)

- BuildingComp.sense() deferred sensor legs — dead (`!isValid()`,
  BuildingComp.java:2097; needs tile state not in the frame),
  health (`case health -> health;`, :2100; live building health
  not in the frame — no `health` key stamped in PortGame.gd),
  totalItems (`case totalItems -> items == null ? 0 :
  items.total();`, :2107; live inventory total, not in the frame),
  cameraX/cameraY/cameraWidth/cameraHeight (:2122; need
  UnitComp.sense delegation for the proxy unit, its own later
  slice), powerNetIn/powerNetOut/powerNetStored/powerNetCapacity
  when power is present (:2114-2117; the graph is not live in the
  frame). For duo they all still report handled false + NaN
  through this slice (duo has no power, so powerNet* folds to 0
  inside N2284 itself — that fold is N2284's, not this slice's).
- Wiring the LAccess numeric dispatch into a live
  logic-executor driver tick — the logic executor is not in the
  driver yet (same deferral as N2507 dispatch hook, N2508 Content
  leg, N2509 size legs, Turret control() shootp live wiring).
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity
  scan.
