# Handoff — N2512 BuildingComp.sense() `health` leg (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice d0d4bbd7, docs b4ab1fc5, GOAL da22af06; cập nhật lượt cron 07:15 +07 — gate main-thread relaunch xong GATE-EXIT 1 ~00:08:10Z, Ran 6257 trong 1210.653s, failures=241, skipped=5; xác minh độc lập: 241 FAIL = 241 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours XONG 231 passed, 0 failed (NEIGHBOURS-EXIT 0 23:29:11Z, 755.41s), WIRING-EXIT 0 23:31:20Z; wiring XONG 32 tests OK. N2511 đã DONE + PUSHED (82a501d5). Slice commit d0d4bbd7, docs b4ab1fc5, GOAL da22af06, status TBD. Targeted 4/4 (29 subtests, re-run độc lập lượt cron 07:15 +07, 18.93s pytest + 14.063s unittest, Godot trên PATH); register --verify 9/9; proof JSON matches:true 9/9 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11689/1741/1675/3141; `git diff --check` OK.

- N2511 DONE + PUSHED ~05:40 +07, origin/main == HEAD == 82a501d5.
- **N2512 GREEN xong trước lượt cron 06:15 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2512-scope.md`): 1 pure
  function `source_building_comp_sense_health_state(health)` trong
  SourceTurretBuildState.gd:566, ngay SAU
  `source_building_comp_sense_dead_state` (N2511, :537, kết thúc
  ~:565), TRƯỚC `source_turret_sense_object_state` (N2506, :566 —
  bị đẩy xuống :595) (mirror Java order — sense() :2093 →
  senseObject() :2128; trong sense() dead :2098 → health :2101).
  KHÔNG driver tick (logic read). KHÔNG sửa
  `source_building_comp_sense_state`: health vẫn `handled:false`
  trong big dispatch cho tới slice wiring sau.
- **Xác minh độc lập lượt cron 07:15 +07 (lượt này, đọc trực tiếp
  từ đĩa + chạy lại)**: targeted **4/4 (29 subtests, 18.93s
  pytest; 14.063s unittest)**, Godot 4.6.2 trên PATH; register
  `--verify` **9/9 exprs present, exit 0**; proof JSON
  **matches:true, 9/9 keys, 6 semantic all true**
  (`C07BuildingCompSenseHealthProof.json`, GREEN lúc ~06:1x +07,
  xác minh lại 07:18 +07 khi chạy lại targeted — JSON viết lại
  vẫn 9/9 true); SSOT đo từ đĩa **11689/1741/1675/3141** — đúng kỳ
  vọng scope (+3 symbols / +1 Done / +1 contract / +2 schemas);
  comp **562/466** (+1/+1, N2512 vào comp shard — java_source
  BuildingComp.java, tiền lệ N2267/N2284/N2506/N2508/N2511);
  defense **210/209 KHÔNG đổi**; ledger N2512 status done
  (1741/1741 done). `git diff --check` SẠCH.
- **Neighbours XONG 231 passed, 0 failed** (chain log
  `hidden_files/n2512-chain.log`: NEIGHBOURS-START 23:16:35Z
  relaunch main-thread sau khi chain worker-launch chết ở 20%,
  NEIGHBOURS-EXIT 0 23:29:11Z, 755.41s — sạch, không flake lần
  này, tốt hơn N2511) + **wiring XONG 32 tests OK**
  (WIRING-START 23:29:11Z, WIRING-EXIT 0 23:31:20Z, 128.753s).
- **Gate XONG (main-thread launch, script
  `hidden_files/n2512-gate-only-main.sh`, lần 1 GATE-START
  23:32:37Z chết do VM restart #14 23:36:55Z — log partial
  `full-suite-n2512-gate-partial-restart-2336z.log`; relaunch
  GATE-START 23:47:58Z, GATE-EXIT 1 ~00:08:10Z)** — xác minh độc
  lập lượt cron 07:15 +07 (đọc trực tiếp log
  `tools/mindustry_godot_transpiler/full-suite-n2512-gate.log`,
  1942 KB, 161784 dòng): Ran 6257 trong 1210.653s, failures=241,
  skipped=5 — 241 FAIL = 241 × `AssertionError: unexpectedly
  None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2511 — đúng 4
  test mới của N2512, +1 failure là reference-graph test của
  N2512, Godot-absent vì chain script reset PATH không có
  godot-bin).
- **Môi trường sau gate**: VM restart #14 (23:36:55Z) đã wipe
  javalang + pytest — đã cài lại 0.13.0 / 9.2.0 trước relaunch
  gate, xác minh importable OK; port 7777 free trước mỗi lần
  chạy proof. Lượt sau vẫn kiểm tra lại javalang trước mọi gate
  theo quy tắc repo.
- **Gate xanh — commit + push theo mẫu 5 commit (slice d0d4bbd7).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2512-gate-only-main.sh`
  (chỉ chạy gate, KHÔNG chạy lại chain — chain sẽ truncate log
  neighbours/wiring; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Gate lần 1 chết do VM restart #14 (23:36:55Z); relaunch main
  thread xong GATE-EXIT 1 ~00:08:10Z, Ran 6257, failures=241 toàn
  Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506/N2507/N2508/N2509/N2510/N2511, nhớ bump Done total
  1740→1741 + row N2512 trong spec; comp 562/466, defense 210/209
  KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt RED, không đổi)

- N2512 = `BuildingComp.sense()` `health` leg — leg deferred thứ
  hai BÊN TRONG `sense()` (BuildingComp.java:2101), tiếp theo
  trong Java switch order sau `dead` (dead :2098, health :2101,
  totalItems :2107, camera* :2122, powerNet* :2114-2117). Xem chi
  tiết scope file
  `docs/superpowers/handoffs/hidden_files/n2512-scope.md`.
- Số slice N2512, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2511).
- 1 pure function, KHÔNG driver tick. Wire shape: `handled` +
  `sense_value` + `sense_value_is_nan` (3 keys mới → symbols +3,
  tiền lệ N2283/N2284/N2511).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_building_comp_sense_health.py`
  (4 test methods, 6 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_building_comp_sense_health.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 9/9).
- Proof `C07BuildingCompSenseHealthProof.gd` + `.tscn` (6 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 9).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `BuildingComp.sense()` `health` leg (`public double sense(LAccess
  sensor){`, BuildingComp.java:2093-2126): `case health -> health;`
  (:2101), với `health` là field health hiện tại của building
  (`float health;`, HealthComp.java:11 — BuildingComp mixes
  HealthComp). Giá trị trả về chính xác, không clamp, không làm
  tròn, không đổi qua `healthf()` (accessor khác,
  HealthComp.java:20).
- N2284 đã port 23 handled legs của BuildingComp.sense
  (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/
  powerNet* deferred — health deferred vì live building health chưa
  có trong frame. N2511 port `dead`; N2512 port đúng leg `health`.
- N2507 đã port dispatch outcome của SenseI.run() (null-target dead
  leg, senseObject-handled leg, noSensed fallback leg); N2510 là mảnh
  cuối chưa port của chính `SenseI.run()`. N2511/N2512 mở đầu các
  sensor leg BÊN TRONG sense() mà SenseI.run() gọi tới qua
  `se.sense(la)`.

## Tiếp theo (sau N2512)

- Các sensor leg BÊN TRONG `sense()` còn deferred, theo Java switch
  order: totalItems (`case totalItems -> items == null ? 0 :
  items.total();`, :2107; live inventory total chưa có trong
  frame), powerNet* (:2114-2117; graph chưa live trong frame),
  camera* (:2122; cần UnitComp.sense delegation cho proxy unit,
  slice riêng). calculateHeat vẫn BLOCKED (live entity scan);
  findTarget vẫn BLOCKED.

## Deferred (không đổi)

- BuildingComp.sense() deferred sensor legs — totalItems (`case
  totalItems -> items == null ? 0 : items.total();`, :2107; live
  inventory total, not in the frame), cameraX/cameraY/cameraWidth/
  cameraHeight (:2122; need UnitComp.sense delegation for the proxy
  unit, its own later slice), powerNetIn/powerNetOut/powerNetStored/
  powerNetCapacity when power is present (:2114-2117; the graph is
  not live in the frame). For duo they all still report handled
  false + NaN through this slice (duo has no power, so powerNet*
  folds to 0 inside N2284 itself — that fold is N2284's, not this
  slice's).
- Wiring the health leg into a live logic-executor driver tick — the
  logic executor is not in the driver yet (same deferral as N2507
  dispatch hook, N2508 Content leg, N2509 size legs, N2510 LAccess
  leg, N2511 dead leg, Turret control() shootp live wiring).
- Stamping live building health from a tick into the frame — frame
  work riêng, param của N2512 là live input slice đó sẽ cung cấp.
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity
  scan.
