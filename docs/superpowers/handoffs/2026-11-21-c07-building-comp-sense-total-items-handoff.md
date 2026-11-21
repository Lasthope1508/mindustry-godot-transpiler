# Handoff — N2513 BuildingComp.sense() `totalItems` leg (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice 1d726f35, docs 35ff1650, GOAL a5fa9a34; cập nhật lượt cron 08:30 +07 — chain + gate main-thread xong GATE-EXIT 1 01:23:13Z, Ran 6261 trong 1210.614s, failures=242, skipped=5; xác minh độc lập: 242 FAIL = 242 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours XONG 235 passed, 0 failed (NEIGHBOURS-EXIT 0 00:53:19Z, 797.83s), WIRING-EXIT 0 00:55:24Z; wiring XONG 32 tests OK. N2512 đã DONE + PUSHED (69d55c39). Slice commit 1d726f35, docs 35ff1650, GOAL a5fa9a34, status TBD. Targeted 4/4 (30 subtests, re-run độc lập lượt cron 08:30 +07, 17.74s pytest + 14.337s unittest, Godot trên PATH); register --verify 10/10; proof JSON matches:true 9/9 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11692/1742/1676/3143; `git diff --check` OK.

- N2512 DONE + PUSHED ~07:08 +07, origin/main == HEAD == 69d55c39.
- **N2513 GREEN xong ~07:35 +07, lượt cron 07:30 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2513-scope.md`): 1 pure
  function `source_building_comp_sense_total_items_state(items_is_null, items_total)` trong
  SourceTurretBuildState.gd:595, ngay SAU
  `source_building_comp_sense_health_state` (N2512, :566, kết thúc
  ~:594), TRƯỚC `source_turret_sense_object_state` (N2506, :629 —
  bị đẩy từ :595) (mirror Java order — sense() :2093 →
  senseObject() :2128; trong sense() dead :2098 → health :2101 →
  totalItems :2107).
  KHÔNG driver tick (logic read). KHÔNG sửa
  `source_building_comp_sense_state`: totalItems vẫn `handled:false`
  trong big dispatch cho tới slice wiring sau.
- **Xác minh độc lập lượt cron 08:30 +07 (lượt này, đọc trực tiếp
  từ đĩa + chạy lại)**: targeted **4/4 (30 subtests, 17.74s
  pytest; 14.337s unittest)**, Godot 4.6.2 trên PATH; register
  `--verify` **10/10 exprs present, exit 0**; proof JSON
  **matches:true, 9/9 keys, 6 semantic all true**
  (`C07BuildingCompSenseTotalItemsProof.json`, GREEN lúc ~07:35 +07,
  xác minh lại 08:32 +07 khi chạy lại targeted — JSON viết lại
  vẫn 9/9 true); SSOT đo từ đĩa **11692/1742/1676/3143** — đúng kỳ
  vọng scope (+3 symbols / +1 Done / +1 contract / +2 schemas);
  comp **563/467** (+1/+1, N2513 vào comp shard — java_source
  BuildingComp.java, tiền lệ N2267/N2284/N2506/N2508/N2511/N2512);
  defense **210/209 KHÔNG đổi**; ledger N2513 status done
  (1742/1742 done). `git diff --check` SẠCH.
- **Neighbours XONG 235 passed, 0 failed** (chain log
  `hidden_files/n2513-chain.log`: NEIGHBOURS-START 00:40:00Z,
  NEIGHBOURS-EXIT 0 00:53:19Z, 797.83s — sạch, không flake lần
  này) + **wiring XONG 32 tests OK**
  (WIRING-START 00:53:19Z, WIRING-EXIT 0 00:55:24Z, 124.872s).
- **Gate XONG (main-thread launch, script
  `hidden_files/n2513-gate-only-main.sh`, GATE-START 01:03:01Z,
  GATE-EXIT 1 01:23:13Z)** — xác minh độc lập lượt cron 08:30 +07
  (đọc trực tiếp log
  `tools/mindustry_godot_transpiler/full-suite-n2513-gate.log`,
  162476 byte): Ran 6261 trong 1210.614s, failures=242,
  skipped=5 — 242 FAIL = 242 × `AssertionError: unexpectedly
  None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2512 — đúng 4
  test mới của N2513, +1 failure là reference-graph test của
  N2513, Godot-absent vì chain script reset PATH không có
  godot-bin).
- **Môi trường sau gate**: không VM restart trong lúc chain/gate
  (lần restart gần nhất #14 lúc 23:36:55Z, trước N2512); javalang
  0.13.0 + pytest 9.2.0 importable OK (xác minh lượt này); port
  7777 free trước mỗi lần chạy proof. Lượt sau vẫn kiểm tra lại
  javalang trước mọi gate theo quy tắc repo.
- **Gate xanh — commit + push theo mẫu 5 commit (slice 1d726f35).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script đã dùng:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2513-gate-only-main.sh`
  (chỉ chạy gate, KHÔNG chạy lại chain — chain sẽ truncate log
  neighbours/wiring; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Chain + gate chạy liền một mạch từ main thread lượt cron trước
  (chain log `hidden_files/n2513-chain.log`):
  NEIGHBOURS-START 00:40:00Z, NEIGHBOURS-EXIT 0 00:53:19Z,
  WIRING-START 00:53:19Z, WIRING-EXIT 0 00:55:24Z,
  GATE-START 01:03:01Z, GATE-EXIT 1 01:23:13Z.
  Ran 6261, failures=242 toàn Godot-absent.
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506/N2507/N2508/N2509/N2510/N2511/N2512, nhớ bump Done total
  1741→1742 + row N2513 trong spec; comp 563/467, defense 210/209
  KHÔNG đổi; GOAL §5 thêm dòng nợ Windows).

## Scope (khóa từ lượt RED, không đổi)

- N2513 = `BuildingComp.sense()` `totalItems` leg — leg deferred thứ
  ba BÊN TRONG `sense()` (BuildingComp.java:2107), tiếp theo
  trong Java switch order sau `health` (dead :2098, health :2101,
  totalItems :2107, powerNet* :2114-2117, camera* :2122). Xem chi
  tiết scope file
  `docs/superpowers/handoffs/hidden_files/n2513-scope.md`.
- Số slice N2513, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2512).
- 1 pure function, KHÔNG driver tick. Wire shape: `handled` +
  `sense_value` + `sense_value_is_nan` (3 keys mới → symbols +3,
  tiền lệ N2283/N2284/N2511/N2512).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_building_comp_sense_total_items.py`
  (4 test methods, 6 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_building_comp_sense_total_items.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 10/10).
- Proof `C07BuildingCompSenseTotalItemsProof.gd` + `.tscn` (6 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 9).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `BuildingComp.sense()` `totalItems` leg (`public double sense(LAccess
  sensor){`, BuildingComp.java:2093-2126): `case totalItems -> items == null ? 0 : items.total();`
  (:2107), với `items` là item module của building
  (`@Nullable ItemModule items;`, BuildingComp.java:81) và
  `items.total()` là tổng số item (`public int total(){`,
  ItemModule.java:174 — returns int). Giá trị trả về chính xác:
  0.0 khi items null, else `float(items_total)` (Java `sense()`
  returns double; int widen chính xác), không clamp, không làm tròn.
- N2284 đã port 23 handled legs của BuildingComp.sense
  (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/
  powerNet* deferred — totalItems deferred vì live inventory total
  chưa có trong frame. N2511 port `dead`; N2512 port `health`;
  N2513 port đúng leg `totalItems`.
- N2507 đã port dispatch outcome của SenseI.run() (null-target dead
  leg, senseObject-handled leg, noSensed fallback leg); N2510 là mảnh
  cuối chưa port của chính `SenseI.run()`. N2511/N2512/N2513 mở đầu
  các sensor leg BÊN TRONG sense() mà SenseI.run() gọi tới qua
  `se.sense(la)`.

## Tiếp theo (sau N2513)

- Các sensor leg BÊN TRONG `sense()` còn deferred, theo Java switch
  order: powerNet* (`case powerNetIn / powerNetOut / powerNetStored /
  powerNetCapacity`, :2114-2117; graph chưa live trong frame),
  camera* (:2122; cần UnitComp.sense delegation cho proxy unit,
  slice riêng). calculateHeat vẫn BLOCKED (live entity scan);
  findTarget vẫn BLOCKED.

## Deferred (không đổi)

- BuildingComp.sense() deferred sensor legs — powerNetIn/powerNetOut/powerNetStored/
  powerNetCapacity (:2114-2117; the graph is not live in the frame),
  cameraX/cameraY/cameraWidth/cameraHeight (:2122; need
  UnitComp.sense delegation for the proxy unit, its own later slice).
  For duo they all still report handled false + NaN through this slice
  (duo has no power, so powerNet* folds to 0 inside N2284 itself — that fold is N2284's, not this
  slice's).
- Wiring the totalItems leg into a live logic-executor driver tick — the
  logic executor is not in the driver yet (same deferral as N2507
  dispatch hook, N2508 Content leg, N2509 size legs, N2510 LAccess
  leg, N2511 dead leg, N2512 health leg, Turret control() shootp live wiring).
- Stamping live inventory total from a tick into the frame — frame
  work riêng, params của N2513 là live input slice đó sẽ cung cấp.
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity
  scan.
