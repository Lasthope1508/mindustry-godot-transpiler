# Handoff — N2508 SenseI Content leg (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice c1405c4e, docs af49f3b3, GOAL 8c527fee; cập nhật lượt cron 01:15 +07 — gate main-thread xong GATE-EXIT 1 18:10:15Z, Ran 6241 trong 1214.008s, failures=237, skipped=5; xác minh độc lập: 237 FAIL = 237 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours XONG 215 passed, exit 0, 16:58:30–17:10:18Z; wiring XONG 32 tests OK, exit 0, 17:10:18–17:12:24Z. N2507 đã DONE + PUSHED (c7fa6325). Slice commit c1405c4e, docs af49f3b3, GOAL 8c527fee, status TBD. Targeted 4/4 (47 subtests, re-run độc lập lượt cron 01:15 +07, 16.75s, Godot trên PATH); register --verify 23/23 (re-run độc lập lượt cron 00:45 +07, exit 0); proof JSON matches:true 9/9 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11676/1737/1671/3133; `git diff --check` OK.

- N2507 DONE + PUSHED ~23:24 +07, origin/main == HEAD == c7fa6325.
- **N2508 GREEN xong lượt cron 23:30 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2508-scope.md`): 1 pure
  function `source_logic_sense_content_state(content_kind, has_items,
  item_count, has_liquids, liquid_amount, has_payloads,
  payload_unit_count, payload_block_count)` trong
  SourceTurretBuildState.gd, ngay SAU
  `source_logic_sense_dispatch_state` (N2507), TRƯỚC
  `source_turret_progress_state`. KHÔNG driver tick (logic read).
- **Xác minh độc lập lượt cron 00:45 +07 (lượt này, đọc trực tiếp
  từ đĩa + chạy lại)**: targeted **4/4 (47 subtests, 19.54s**,
  Godot trên PATH); register `--verify` **23/23 exprs present**,
  exit 0; proof JSON **matches:true, 9/9 keys, 6 semantic all
  true** (`C07TurretLogicSenseContentProof.json`); SSOT đo từ đĩa
  **11676/1737/1671/3133** — đúng kỳ vọng scope (+4 symbols / +1
  Done / +1 contract / +2 schemas); comp **560/464**, defense
  **210/209 KHÔNG đổi**; ledger N2508 status done (1737/1737 done);
  symbol đã đăng ký (12 occurrences
  `source_logic_sense_content_state*` trong registry, owner
  `SourceTurretBuildState.source_logic_sense_content_state`).
  `git diff --check` SẠCH. HEAD vẫn c7fa6325 (N2507).
- **Neighbours XONG 215 passed** (chain log
  `hidden_files/n2508-chain.log`: NEIGHBOURS-START 16:58:30Z,
  NEIGHBOURS-EXIT 0 17:10:18Z, 707.50s, gồm module N2508 4/4) +
  **wiring XONG 32 tests OK** (WIRING-START 17:10:18Z, WIRING-EXIT 0
  17:12:24Z, 125.625s). Đã đọc trực tiếp log, không qua báo cáo
  worker. (Một neighbours worker-launch trước đó chết giữa chừng —
  `n2508-neighbours-partial-worker.log` — main-thread relaunch mới
  xong, đúng bài học N2284/N2506/N2507.)
- **Gate CHẾT giữa chừng lần 1 — VM restart 17:34:24Z** (lượt 00:45 xác minh:
  `uptime` 12 phút lúc 17:46Z, `last reboot` 17:34; GATE-START
  17:17:54Z trong chain log, KHÔNG có GATE-EXIT; log
  `full-suite-n2508-gate.log` chỉ 5923 bytes, dừng ở dòng dots
  giữa chừng, không có dòng summary `Ran`; không còn process gate
  nào chạy; port 7777 free; ps sạch). Đây là lần restart thứ ~11
  trong ngày 2026-11-20. Partial log giữ thành
  `full-suite-n2508-gate-partial-restart-1734z.log`.
- **Gate XONG lần 2 (relaunch main-thread, PID 3661, GATE-START 17:50:00Z,
  GATE-EXIT 1 18:10:15Z)** — xác minh độc lập lượt cron 01:15 +07 (đọc trực
  tiếp log `full-suite-n2508-gate.log`, 159162 bytes): Ran 6241 trong
  1214.008s, failures=237, skipped=5 — 237 FAIL = 237 × `AssertionError:
  unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2507 — đúng 4 test mới
  của N2508, +1 failure là reference-graph test của N2508, Godot-absent vì
  chain script reset PATH không có godot-bin).
- **javalang + pytest đã bị restart xóa** — lượt này đã cài lại:
  javalang OK (requirements.txt) + pytest 9.2.0. Gate script
  `n2508-gate-only-main.sh` kiểm `import javalang` trước nên lần
  relaunch sẽ chạy được.
- **Gate xanh — commit + push theo mẫu 5 commit (slice c1405c4e).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script sẵn:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2508-gate-only-main.sh`
  (chỉ chạy gate, KHÔNG chạy lại chain — chain sẽ truncate log
  neighbours/wiring; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Kỳ vọng gate: Ran ~6241, failures ~237, skipped=5, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2507 — đúng 4
  test mới của N2508, +1 failure là reference-graph test của
  N2508, Godot-absent vì chain script reset PATH không có
  godot-bin).
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506/N2507, nhớ bump Done total 1736→1737 + row N2508 trong
  spec; comp 560/464, defense 210/209 KHÔNG đổi; GOAL §5 thêm dòng
  nợ Windows).

## Scope (khóa từ lượt RED, không đổi)

- N2508 = `SenseI.run()` Content leg — logic-processor `sense` op
  với `Content` sensor (LExecutor.java:692-693), gọi
  `BuildingComp.sense(Content)` (BuildingComp.java:2139-2147).
  Xem chi tiết scope file
  `docs/superpowers/handoffs/hidden_files/n2508-scope.md`.
- Số slice N2508, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2507).
- 1 pure function, KHÔNG driver tick. Wire shape: `handled` +
  `output_kind` (luôn "num") + `output_value` + `is_invalid`
  (4 keys mới → symbols +4).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_turret_logic_sense_content.py`
  (4 test methods, 6 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_turret_logic_sense_content.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 23/23).
- Proof `C07TurretLogicSenseContentProof.gd` + `.tscn` (6 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 9).
  Proof .json KHÔNG stage (quy tắc repo).

## Java evidence

- `SenseI.run()` Content branch (LExecutor.java:692-693):
  `if(sense instanceof Content co){ to.setnum(se.sense(co)); }`.
- `BuildingComp.sense(Content)` (BuildingComp.java:2139-2147):
  Item + `items != null` → `items.get(i)` (:2140); Liquid +
  `liquids != null` → `liquids.get(l)` (:2141); `getPayloads() !=
  null` → UnitType → `getPayloads().get(u)` (:2143), Block →
  `getPayloads().get(b)` (:2144); else `return Float.NaN; //invalid
  sense` (:2146).
- Subtlety đã pin: Item sensor với `items == null` KHÔNG rơi vào
  payload legs — instanceof checks theo thứ tự Item → Liquid →
  payloads. Proof key `content_item_no_items_invalid` chứng minh
  (item + has_items false + has_payloads true → NaN, is_invalid
  true).

## Tiếp theo (sau N2508)

- Chọn slice tiếp theo từ deferred list — ứng viên: SenseI
  non-Senseable size/bufferSize legs (LExecutor.java:704-717,
  target không phải building); dead/health/totalItems/camera* legs
  (khi có live input); powerNet* graph legs. calculateHeat vẫn
  BLOCKED (live entity scan); findTarget vẫn BLOCKED.

## Deferred (không đổi)

- SenseI.run() non-Senseable legs — NOT N2508; target không phải
  building (string / sequence logic var).
- Wiring Content leg vào live logic-executor driver tick — logic
  executor chưa có trong driver (cùng deferral với N2507 dispatch
  hook và Turret control() shootp live wiring).
- Live inventory counts trong frame (items / liquids / payloads) —
  counts là params ở đây; stamp từ live tick là frame work riêng
  (cùng lý do N2284 deferred totalItems).
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan.
- Turret control() shootp live wiring — logic executor chưa có
  trong driver.
- findTarget (BLOCKED); các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn
  BLOCKED (catalog capture).
- `controlled()` live wiring (needs a player unit).
- LaserTurret shouldConsume() consumer wiring — cần bullets live
  list; chênh một tick snapshot.
- Activation early-return skip — vacuous cho mọi def hiện tại.
- validateTarget effective-team live wiring — chờ findTarget slice.
- findTarget ally-tile acquisition — BLOCKED, live entity scan.
- sense() cho def khác duo (maxAmmo per-def) — caller khác, pure
  function đã param hóa.
