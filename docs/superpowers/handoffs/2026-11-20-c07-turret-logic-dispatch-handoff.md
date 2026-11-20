# Handoff — N2507 Turret logic-processor sense dispatch hook (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice 39b0231b, docs 554e57a8, GOAL 3e020b02; cập nhật lượt cron 23:15 +07 — gate main-thread xong GATE-EXIT 1 16:08:08Z, Ran 6237 trong 1214.760s, failures=236, skipped=5; xác minh độc lập: 236 FAIL = 236 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours XONG 211 passed, exit 0, 14:54:49–15:06:27Z; wiring XONG 32 tests OK, exit 0, 15:06:27–15:08:32Z. N2506 đã DONE + PUSHED (254197a6). Slice commit 39b0231b, docs 554e57a8, GOAL 3e020b02, status TBD. Targeted 4/4 (63 subtests, re-run độc lập lượt cron 23:15 +07, 19.07s, Godot trên PATH); register --verify 29/29 (re-run độc lập lượt cron 23:15 +07, exit 0); proof JSON matches:true 9/9 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11672/1736/1670/3131; `git diff --check` OK.

- N2506 DONE + PUSHED ~21:15 +07, origin/main == HEAD == 254197a6.
  SSOT lúc push 11668/1735/1669/3129; comp 559/463; defense 210/209.
- **N2507 GREEN xong lượt này**: 1 pure function
  `source_logic_sense_dispatch_state(sensor, target_is_null,
  sense_object_handled, sense_object, sense_value)` trong
  SourceTurretBuildState.gd, ngay SAU
  `source_turret_sense_object_state`, TRƯỚC
  `source_turret_progress_state`. KHÔNG driver tick (logic read).
- **Targeted 4/4 (63 subtests, 17.37s)** — gồm proof test Godot
  headless. **Proof JSON matches:true, 6 semantic keys all true,
  9 keys tổng** (`C07TurretLogicSenseDispatchProof.json`). Register
  `--verify`: **29/29 exprs present**.
- **SSOT sau GREEN (đo từ đĩa): 11672/1736/1670/3131** — đúng kỳ
  vọng scope (+4 symbols / +1 Done / +1 contract / +2 schemas).
  comp 559/463, defense 210/209 KHÔNG đổi (canonical-only, đúng
  shard routing đã pin — java_source LExecutor.java, không shard
  /logic/).
- `git diff --check`: SẠCH. HEAD vẫn 254197a6 (N2506). Worktree giữ
  file N2507 chưa commit (pure function + proof .gd/.tscn + SSOT
  JSONs + test + register + handoff/scope). **Không commit/push
  (gate chưa xanh).**
- javalang 0.13.0 + pytest 9.2.0 OK; port 7777 free; ps sạch.
  Godot chạy với `PATH="$HOME/workspace/godot-bin:$PATH"` (không
  có trên PATH mặc định của exec).
- LƯU Ý: proof .gd lúc viết lần đầu có 1 dòng ternary rác ở key
  `dispatch_type_duo_obj` — đã sửa sạch trước khi chạy targeted
  (dòng hiện tại là boolean `and` thuần như các key khác).

## CHAIN + GATE (CHƯA LÀM — CHỈ MAIN THREAD LAUNCH)

- Tạo chain script `n2507-chain-main.sh` mirror `n2506-chain-main.sh`
  (50 module neighbours + thêm
  `tests/test_c07_turret_logic_sense_dispatch.py` vào danh sách,
  kỳ vọng ~211 passed), rồi launch từ MAIN THREAD. Worker-launch
  chết theo session (bài học N2284/N2506) — worker KHÔNG launch.
- Sau chain: gate full-suite từ main thread, kỳ vọng Ran ~6237,
  failures ~236, skipped=5, toàn Godot-absent (+4 tests / +1
  failure đúng mẫu vs N2506).
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506, nhớ bump Done total 1735→1736 + row N2507 trong spec;
  comp/defense KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt RED, không đổi)

- N2507 = LExecutor `SenseI.run()` dispatch hook cho duo — slice tiếp
  theo, chọn từ deferred list của N2283/N2284/N2506 (ứng viên còn lại:
  Content leg; non-Senseable size/bufferSize legs; dead/health/totalItems/
  camera* legs; powerNet* graph legs).
- **Số slice N2507, KHÔNG phải N2285**: `git log --all` max là N2506,
  không có branch N2507 nào. (Cùng quy tắc N2506: N2285–N2505 đã có trên
  branch khác.)
- Scope đã khóa: `docs/superpowers/handoffs/hidden_files/n2507-scope.md`.
  1 pure function `source_logic_sense_dispatch_state(sensor, target_is_null,
  sense_object_handled, sense_object, sense_value)` trong
  SourceTurretBuildState.gd, ngay SAU `source_turret_sense_object_state`
  (:537), TRƯỚC `source_turret_progress_state` (:566). KHÔNG driver tick
  (logic read, tiền lệ N2206/N2208/N2223/N2283/N2284/N2506).
  Wire shape: `handled` + `output_kind` ("num" / "obj") + `output_value` +
  `is_no_sensed` (4 keys mới → symbols +4).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_turret_logic_sense_dispatch.py`
  (4 test methods, 6 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_turret_logic_sense_dispatch.py`
  (EXACT_EXPRS 20 + inputs 5 + outputs 4).
- RED xác nhận lượt 21:30: **4 failed** trong 1.47s — registration KeyError
  'N2507', exact-evidence KeyError 'N2507', state AssertionError signature
  `source_logic_sense_dispatch_state(...)` not found, proof Godot exit 1
  `ERROR: Cannot open file 'res://tools/runtime_proofs/C07TurretLogicSenseDispatchProof.tscn'`
  (proof chưa viết — việc của lượt GREEN). Đúng lý do RED, không fail lạ.
  Register `--verify`: **29/29 exprs present**, exit 0.
- SSOT baseline (đo từ đĩa): symbols **11668**, Done **1735**, contracts
  **1669**, schemas **3129**; comp slices 559 / contracts 463; defense
  210/209. Kỳ vọng sau GREEN: 11672/1736/1670/3131; comp/defense KHÔNG
  đổi (N2507 là slice đầu tiên có java_source dưới
  `core/src/mindustry/logic/` — không có shard `/logic/`, chỉ sống ở
  canonical SSOT; xem scope §Shard routing — GREEN KHÔNG được "fix"
  bằng cách đăng ký java_source BuildingComp.java).

## Java evidence

- `SenseI.run()` — LExecutor.java:681-718 (`public static class SenseI
  implements LInstruction{`, :668): null target + `dead` → `to.setnum(1)`
  (:685-687, checked FIRST); Senseable + Content → `to.setnum(se.sense(co))`
  (:692-693, DEFERRED); Senseable + LAccess → `objOut = se.senseObject(la)`
  (:695), `if(objOut == Senseable.noSensed){ to.setnum(se.sense(la)); }`
  (:697-699) else `to.setobj(objOut)` (:701-703); non-Senseable +
  size/bufferSize → length/size (:706-714, DEFERRED), else `to.setobj(null)`
  (:716).
- `noSensed` sentinel (`Object noSensed = new Object();`,
  Senseable.java:6); default `senseObject()` returns it
  (`default Object senseObject(LAccess sensor){ return noSensed; }`,
  Senseable.java:14-16).
- Composed functions: `senseObject()` (BuildingComp.java:2128-2136, N2506)
  + `sense()` (Turret.java:405-419, N2283; BuildingComp.java:2093-2126,
  N2284). `dead` là `dead,` (LAccess.java:47).
- Subtlety đã pin: `config` / `payloadType` trả null từ senseObject nhưng
  đó KHÔNG phải sentinel → dispatch viết obj null (`output_kind` "obj"),
  KHÔNG fallback sang numeric sense. Proof key `dispatch_config_null_obj`
  + `dispatch_payload_type_null_obj` chứng minh điều này.

## GREEN (ĐÃ XONG lượt cron 21:45 +07)

- Pure function `source_logic_sense_dispatch_state` theo scope (3 return
  shape — null+dead → num 1.0; handled → obj sense_object; noSensed →
  num sense_value + is_no_sensed true), kèm comment Java evidence đủ 20
  EXACT_EXPRS (test assert từng expr có trong .gd).
- Proof `C07TurretLogicSenseDispatchProof.gd` + `.tscn` (6 semantic keys +
  registry_valid + one_headquarter_per_ssot + matches = 9; JSON
  matches:true 9/9, 6 semantic all true).
- Register đã chạy (ghi SSOT), targeted 4/4 (63 subtests, 17.37s),
  register --verify 29/29. SSOT 11672/1736/1670/3131; comp/defense
  KHÔNG đổi.
- CÒN LẠI: neighbours + wiring + gate — CHỈ main thread launch (xem
  §CHAIN + GATE ở trên). Sau gate xanh: docs + commit + push (5 commit
  mẫu N2280–N2284/N2506, nhớ bump Done total 1735→1736 + row N2507
  trong spec; comp/defense KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## CHAIN + GATE — CẬP NHẬT lượt cron 22:15 +07 (xác minh độc lập từ log đĩa)

- **CHAIN ĐÃ CHẠY TỪ MAIN THREAD, XANH**: `n2507-chain.log`
  NEIGHBOURS-START 2026-11-20T14:54:49Z, NEIGHBOURS-EXIT 0
  15:06:27Z; WIRING-START 15:06:27Z, WIRING-EXIT 0 15:08:32Z.
  **Neighbours 211 passed** (696.99s, gồm module N2507 4/4) +
  **wiring 32 tests OK** (124.8s). Đã đọc trực tiếp log, không qua
  báo cáo worker.
- **Gate script đã tạo**: `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2507-gate-only-main.sh`
  (mirror `n2506-gate-only-main.sh`, log gate vào
  `full-suite-n2507-gate.log`, append GATE-START/EXIT vào
  `n2507-chain.log`). **CHỈ MAIN THREAD LAUNCH — worker không launch
  gate** (bài học N2284/N2506: worker-launch chết giữa chừng).
- **Xác minh lại lượt này (22:15)**: register `--verify` 29/29;
  SSOT đo từ đĩa **11672/1736/1670/3131** (ledger 1736 slices, tất cả
  status done); proof JSON `matches:true`, 6 semantic keys true, 9
  keys tổng; javalang 0.13.0 + pytest 9.2.0 OK; port 7777 free;
  `git diff --check` SẠCH (đã kiểm lượt 21:45, worktree không đổi
  từ đó). HEAD vẫn 254197a6 (N2506). **Chưa commit/push — chờ gate.**
- Kỳ vọng gate: Ran ~6237, failures ~236, skipped=5, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2506).

## GATE XONG — lượt cron 23:15 +07 (xác minh độc lập từ log đĩa)

- **Gate launch 1 chết**: GATE-START 15:19:02Z, không có EXIT —
  partial log `full-suite-n2507-gate-partial-restart-1534z.log`
  (VM restart ~15:34Z).
- **Gate launch 2 (main thread) XONG**: GATE-START 15:47:52Z,
  GATE-EXIT 1 16:08:08Z (log `full-suite-n2507-gate.log`, chain log
  `hidden_files/n2507-chain.log`).
- **Ran 6237 trong 1214.760s, FAILED (failures=236, skipped=5)** —
  xác minh độc lập từ log đĩa: 236 FAIL = 236 ×
  `AssertionError: unexpectedly None`, 0 KeyError, 0
  `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests /
  +1 failure đúng mẫu vs N2506 — đúng 4 test mới của N2507, +1
  failure là reference-graph test của N2507, Godot-absent vì chain
  script reset PATH không có godot-bin).
- **Re-run độc lập lượt này**: targeted 4/4 (63 subtests, 19.07s,
  Godot trên PATH); register `--verify` 29/29 exit 0; proof JSON
  `matches:true`, 9 keys, 6 semantic true (đọc trực tiếp từ đĩa);
  SSOT đo từ đĩa 11672/1736/1670/3131; `git diff --check` sạch.
- **Slice commit `39b0231b`** (9 files, 1281 insertions, staged đúng
  file slice — không stage proof .json, .gd.uid, log, hidden_files).
- Tiếp theo: docs commit (handoff + report + spec, bump Done
  1735→1736) → GOAL commit → status commit → hashes commit → push
  origin main.

## Tiếp theo (sau N2507)

- Chọn slice tiếp theo từ deferred list — ứng viên: SenseI Content leg
  (`BuildingComp.sense(Content)`, BuildingComp.java:2139-2147, cần live
  items/liquids/payloads counts); SenseI non-Senseable size/bufferSize
  legs; dead/health/totalItems/camera* legs (khi có live input);
  powerNet* graph legs. calculateHeat vẫn BLOCKED (live entity scan);
  findTarget vẫn BLOCKED.

## Deferred (không đổi, trừ dispatch hook nay đang làm N2507)

- Logic-processor dispatch hook — slice riêng sau → NAY LÀ N2507.
- SenseI.run() Content leg — NOT N2507; cần live inventory counts.
- SenseI.run() non-Senseable size/bufferSize legs — NOT N2507; target
  không phải building.
- Wiring dispatch hook vào live logic-executor driver tick — logic
  executor chưa có trong driver (cùng deferral với Turret control()
  shootp live wiring).
- super.sense() deferred legs: dead (tile validity), health (chưa live
  trong frame), totalItems (items inventory chưa live), cameraX/Y/Width/
  Height (cần UnitComp.sense delegation cho proxy unit), powerNet* khi
  has_power=true (graph chưa live).
- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED,
  live entity scan.
- Turret control() shootp live wiring — logic executor chưa có trong driver.
- findTarget (BLOCKED); các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED
  (catalog capture).
- `controlled()` live wiring (needs a player unit).
- LaserTurret shouldConsume() consumer wiring — cần bullets live list;
  chênh một tick snapshot (Java updateConsumption trước updateTile).
- Activation early-return skip — vacuous cho mọi def hiện tại.
- validateTarget effective-team live wiring (`canHeal() ? Team.derelict :
  team`, Turret.java:632) — chờ findTarget slice; can_heal live sẽ feed nó.
- findTarget ally-tile acquisition (`if(target == null && canHeal()){...}`,
  Turret.java:660) — BLOCKED, live entity scan.
- sense() cho def khác duo (maxAmmo per-def) — caller khác, pure function
  đã param hóa.
