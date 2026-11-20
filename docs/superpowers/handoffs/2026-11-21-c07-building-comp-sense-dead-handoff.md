# Handoff — N2511 BuildingComp.sense() `dead` leg (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (slice dcca355e, docs 8350bfe8, GOAL 11814f45; cập nhật lượt cron 05:45 +07 — gate main-thread xong GATE-EXIT 1 22:39:45Z, Ran 6253 trong 1195.247s, failures=240, skipped=5; xác minh độc lập: 240 FAIL = 240 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours XONG 225 passed + 2 failed (flake port-7777, re-run độc lập 8 passed → thực chất 227/227), WIRING-EXIT 0 22:17:02Z; wiring XONG 32 tests OK. N2510 đã DONE + PUSHED (fee79e05). Slice commit dcca355e, docs 8350bfe8, GOAL 11814f45, status 5f45c84f. Targeted 4/4 (33 subtests, re-run độc lập lượt cron 05:45 +07, 14.84s pytest + 14.359s unittest, Godot trên PATH); register --verify 11/11; proof JSON matches:true 9/9 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11686/1740/1674/3139; `git diff --check` OK.

- N2510 DONE + PUSHED ~04:24 +07, origin/main == HEAD == fee79e05.
- **N2511 GREEN xong lượt cron 05:15 +07** (scope khóa
  `docs/superpowers/handoffs/hidden_files/n2511-scope.md`): 1 pure
  function `source_building_comp_sense_dead_state(tile_build_is_self,
  is_dead)` trong SourceTurretBuildState.gd:537, ngay SAU
  `source_building_comp_sense_state` (N2284, :313, kết thúc ~:536),
  TRƯỚC `source_turret_sense_object_state` (N2506, :566 — bị đẩy từ
  :537) (mirror Java order — sense() :2093 → senseObject() :2128).
  KHÔNG driver tick (logic read). KHÔNG sửa
  `source_building_comp_sense_state`: dead vẫn `handled:false`
  trong big dispatch cho tới slice wiring sau.
- **Xác minh độc lập lượt cron 05:45 +07 (lượt này, đọc trực tiếp
  từ đĩa + chạy lại)**: targeted **4/4 (33 subtests, 14.84s
  pytest; 14.359s unittest)**, Godot 4.6.2 trên PATH; register
  `--verify` **11/11 exprs present, exit 0**; proof JSON
  **matches:true, 9/9 keys, 6 semantic all true**
  (`C07BuildingCompSenseDeadProof.json`, GREEN ~05:18 +07); SSOT đo
  từ đĩa **11686/1740/1674/3139** — đúng kỳ vọng scope (+3 symbols
  / +1 Done / +1 contract / +2 schemas); comp **561/465** (+1/+1,
  N2511 vào comp shard — java_source BuildingComp.java, tiền lệ
  N2267/N2284/N2506/N2508); defense **210/209 KHÔNG đổi**; ledger
  N2511 status done (1740/1740 done). `git diff --check` SẠCH.
- **Neighbours XONG 225 passed + 2 failed** (chain log
  `hidden_files/n2511-chain.log`: NEIGHBOURS-START 22:02:14Z,
  NEIGHBOURS-EXIT 1 22:14:56Z, 761.44s) + **wiring XONG 32 tests
  OK** (WIRING-START 22:14:56Z, WIRING-EXIT 0 22:17:02Z, 125.299s).
  2 fail đều là flake port-7777 đã biết: test_c07_point_defense_turret_setstats_icons
  và test_c07_point_defense_turret_spawn_team_stamp — proof JSON
  matches:true, 11/11 và 9/9 key true, chỉ dính `ERROR: [MCP
  Runtime] Failed to start server on port 7777: 22` (một proof
  scene khác giữ port lúc đó) — không phải hồi quy (cả hai module
  PASS ở chain N2510). **Re-run độc lập lượt cron 05:45 +07 XONG 8
  passed trong 33.48s** (pytest, Godot trên PATH) → neighbours thực
  chất **227/227**.
- **Gate XONG (main-thread launch, script
  `hidden_files/n2511-gate-only-main.sh`, GATE-START 22:19:48Z,
  GATE-EXIT 1 22:39:45Z)** — xác minh độc lập lượt cron 05:45 +07
  (đọc trực tiếp log `tools/mindustry_godot_transpiler/full-suite-n2511-gate.log`,
  161121 bytes): Ran 6253 trong 1195.247s, failures=240,
  skipped=5 — 240 FAIL = 240 × `AssertionError: unexpectedly
  None` (239 plain + 1 suffix pre-existing `Godot required for
  hydration proof` ở test_liquid_consumer_apply_hydration), 0
  KeyError, 0 `return_schema_linkage`, 0 ERROR thật (240 hit grep
  `ERROR` đều là chữ trong `AssertionError`), toàn Godot-absent
  (+4 tests / +1 failure đúng mẫu vs N2510 — đúng 4 test mới của
  N2511, +1 failure là reference-graph test của N2511, Godot-absent
  vì chain script reset PATH không có godot-bin).
- **Môi trường sau gate**: javalang 0.13.0 + pytest 9.2.0 vẫn còn
  (không bị wipe lượt này); port 7777 free trước mỗi lần chạy
  proof. Lượt sau vẫn kiểm tra lại javalang trước mọi gate theo
  quy tắc repo.
- **Gate xanh — commit + push theo mẫu 5 commit (slice dcca355e).**

## GATE — CHỈ MAIN THREAD LAUNCH (worker KHÔNG launch)

- Script sẵn:
  `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2511-gate-only-main.sh`
  (chỉ chạy gate, KHÔNG chạy lại chain — chain sẽ truncate log
  neighbours/wiring; mirror PATH reset: Godot off PATH nên
  reference-graph tests fail Godot-absent như kỳ vọng).
- Kỳ vọng gate: Ran ~6253, failures ~240, skipped=5, toàn
  Godot-absent (+4 tests / +1 failure đúng mẫu vs N2510 — đúng 4
  test mới của N2511, +1 failure là reference-graph test của
  N2511, Godot-absent vì chain script reset PATH không có godot-bin).
- Sau gate xanh: docs + commit + push (5 commit mẫu N2280–N2284/
  N2506/N2507/N2508/N2509/N2510, nhớ bump Done total 1739→1740 + row N2511
  trong spec; comp 561/465, defense 210/209 KHÔNG đổi; GOAL §5 thêm
  dòng nợ Windows).

## Scope (khóa từ lượt RED, không đổi)

- N2511 = `BuildingComp.sense()` `dead` leg — leg deferred đầu tiên
  BÊN TRONG `sense()` (BuildingComp.java:2098), đầu tiên trong Java
  switch order giữa các deferred legs (dead :2098, health :2101,
  totalItems :2107, camera* :2122, powerNet* :2114-2117). Xem chi
  tiết scope file
  `docs/superpowers/handoffs/hidden_files/n2511-scope.md`.
- Số slice N2511, KHÔNG phải N2285 (N2285–N2505 đã có trên branch
  khác; `git log --all` max là N2510).
- 1 pure function, KHÔNG driver tick. Wire shape: `handled` +
  `sense_value` + `sense_value_is_nan` (3 keys mới → symbols +3,
  tiền lệ N2283/N2284).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_building_comp_sense_dead.py`
  (4 test methods, 6 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_building_comp_sense_dead.py`
  (EXACT_EXPRS + inputs/outputs; `--verify` 11/11).
- Proof `C07BuildingCompSenseDeadProof.gd` + `.tscn` (6 semantic
  keys + registry_valid + one_headquarter_per_ssot + matches = 9).
  Proof .json KHÔNG stage (quy tắc repo — file gitignored).

## Java evidence

- `BuildingComp.sense()` `dead` leg (`public double sense(LAccess
  sensor){`, BuildingComp.java:2093-2126): `case dead ->
  !isValid() ? 1 : 0;` (:2098), với `isValid()` `public boolean
  isValid(){` / `return tile.build == self() && !dead();`
  (:2030-2032). Hai conjuncts được truyền vào làm params (tiền lệ
  per-def-param N2212/N2220): `tile_build_is_self` là `tile.build
  == self()` (:2031, conjunct đầu) và `is_dead` là `dead()` (:2031,
  conjunct thứ hai, bị phủ định trong `isValid()`).
- N2284 đã port 23 handled legs của BuildingComp.sense
  (BuildingComp.java:2093-2126) và để dead/health/totalItems/camera*/
  powerNet* deferred — dead deferred vì `isValid()` cần tile state
  chưa có trong frame (note trong `source_building_comp_sense_state`,
  SourceTurretBuildState.gd:313). N2511 port đúng leg `dead`.
- N2507 đã port dispatch outcome của SenseI.run() (null-target dead
  leg, senseObject-handled leg, noSensed fallback leg); N2510 là mảnh
  cuối chưa port của chính `SenseI.run()`. N2511 mở đầu các sensor
  leg BÊN TRONG sense() mà SenseI.run() gọi tới qua `se.sense(la)`.

## Tiếp theo (sau N2511)

- Các sensor leg BÊN TRONG `sense()` còn deferred, theo Java switch
  order: health (`case health -> health;`, :2101; live building
  health chưa có trong frame), totalItems (`case totalItems ->
  items == null ? 0 : items.total();`, :2107; live inventory total
  chưa có trong frame), powerNet* (:2114-2117; graph chưa live trong
  frame), camera* (:2122; cần UnitComp.sense delegation cho proxy
  unit, slice riêng). calculateHeat vẫn BLOCKED (live entity scan);
  findTarget vẫn BLOCKED.

## Deferred (không đổi)

- BuildingComp.sense() deferred sensor legs — health (`case health
  -> health;`, :2101; live building health not in the frame — no
  `health` key stamped in PortGame.gd), totalItems (`case totalItems
  -> items == null ? 0 : items.total();`, :2107; live inventory
  total, not in the frame), cameraX/cameraY/cameraWidth/cameraHeight
  (:2122; need UnitComp.sense delegation for the proxy unit, its own
  later slice), powerNetIn/powerNetOut/powerNetStored/powerNetCapacity
  when power is present (:2114-2117; the graph is not live in the
  frame). For duo they all still report handled false + NaN through
  this slice (duo has no power, so powerNet* folds to 0 inside N2284
  itself — that fold is N2284's, not this slice's).
- Wiring the dead leg into a live logic-executor driver tick — the
  logic executor is not in the driver yet (same deferral as N2507
  dispatch hook, N2508 Content leg, N2509 size legs, N2510 LAccess
  leg, Turret control() shootp live wiring).
- Stamping tile state (`tile.build == self()`, `dead()`) from a live
  tick into the frame — frame work riêng, params của N2511 là live
  inputs slice đó sẽ cung cấp.
- calculateHeat live proximity scan (BuildingComp.java:410-461) —
  BLOCKED, live entity scan. findTarget — BLOCKED, live entity
  scan.
