# Handoff — N2506 Turret senseObject() (C07, duo) [DONE + PUSHED]

## Cập nhật lượt cron 21:15 +07 (main thread kiểm tra — gate XONG, xác minh độc lập, re-run targeted + register, commit slice)

- **Gate XONG**: GATE-START 13:45:49Z → GATE-EXIT 1 14:05:31Z (log `tools/mindustry_godot_transpiler/full-suite-n2506-gate.log`, chain log `hidden_files/n2506-chain.log`). **Ran 6233 trong 1179.933s, failures=235, skipped=5** — xác minh độc lập: 235 FAIL = 235 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2284, đúng 4 test mới; +1 failure là reference-graph test của N2506, Godot-absent trong gate vì chain script reset PATH không có godot-bin). Lưu ý: hai launch trước 13:31:13Z và 13:35:06Z chết không EXIT (partial log `full-suite-n2506-gate-partial-2worker-runs.log`, worker-launch) — gate hoàn thành là bản main-thread 13:45:49Z.
- **Targeted re-run độc lập lượt này: 4/4 xanh, 72 subtests passed in 19.11s** (Godot trên PATH). Register `--verify` re-run độc lập: **32/32 exprs present**, exit 0. Proof JSON đọc trực tiếp từ đĩa: **matches:true, 9 keys, 0 false**.
- **Slice commit `51258c1e`** (11 files, 1240 insertions, staged đúng file slice — không stage proof .json, .gd.uid, log, hidden_files). `git diff --check` sạch. SSOT đo từ đĩa: 11668/1735/1669/3129; comp 559/463; defense 210/209 không đổi.
- Tiếp theo: docs commit (handoff + report + spec, bump Done 1734→1735) → GOAL commit → status commit → hashes commit → push origin main.

## Status: DONE + PUSHED (slice 51258c1e, docs db59b8cd, GOAL ac693c14; cập nhật lượt cron 21:15 +07 — gate main-thread xong GATE-EXIT 1 14:05:31Z, Ran 6233 trong 1179.933s, failures=235, skipped=5; xác minh độc lập: 235 FAIL = 235 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours XONG 207 passed, exit 0, 13:06:52–13:18:18Z; wiring XONG 32 tests OK, exit 0, 13:18:18–13:20:22Z. N2284 đã DONE + PUSHED (6c18436d). Slice commit 51258c1e, docs db59b8cd, GOAL ac693c14, status TBD. Targeted 4/4 (72 subtests, re-run độc lập lượt cron 21:15 +07, 19.11s, Godot trên PATH); register --verify 32/32 (re-run độc lập lượt cron 21:15 +07, exit 0); proof JSON matches:true 9/9 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11668/1735/1669/3129; `git diff --check` OK.

- N2284 DONE + PUSHED 19:30 +07, origin/main == 6c18436d. SSOT lúc push
  11665/1734/1668/3127; defense slices 210, contracts 209; comp 558/462.
- **GREEN XONG lượt này**: pure function
  `source_turret_sense_object_state(sensor, block_id, first_item)` đã viết
  vào SourceTurretBuildState.gd (sau `source_building_comp_sense_state`,
  trước `source_turret_progress_state`), 4 legs + default đúng scope;
  proof `C07TurretSenseObjectProof.gd` + `.tscn` đã viết; proof JSON
  **matches:true 9/9** (6 semantic + registry_valid +
  one_headquarter_per_ssot + matches).
- **Targeted 4/4 (72 subtests)** trong 17.07s, Godot trên PATH
  (`$HOME/workspace/godot-bin`); **register --verify 32/32**, exit 0;
  register đã ghi SSOT. SSOT đo từ đĩa: **11668/1735/1669/3129** (đúng kỳ
  vọng +3/+1/+1/+2); comp slices **559** / contracts **463**; defense giữ
  210/209. `git diff --check`: SẠCH. HEAD vẫn 6c18436d (N2284 DONE +
  PUSHED). Không commit/push (gate chưa xanh).
- **CHƯA LÀM — CHỈ MAIN THREAD**: neighbours + wiring (chain script
  `n2506-chain-main.sh` chưa tạo — mirror `n2284-chain-main.sh`, thêm
  `tests/test_c07_turret_sense_object.py` vào danh sách neighbours, kỳ
  vọng ~207 passed) rồi gate (kỳ vọng Ran ~6233, failures ~235,
  skipped=5, toàn Godot-absent). Worker KHÔNG launch chain/gate (quy tắc
  N2284: worker-launch chết theo session). Sau gate xanh: docs + commit +
  push (5 commit mẫu N2280–N2284, nhớ bump Done total 1734→1735; defense
  210/209 không đổi, N2506 route comp shard; GOAL §5 thêm dòng nợ Windows).
- javalang 0.13.0 + pytest 9.2.0 OK (kiểm tra độc lập lượt này); port 7777
  free; ps sạch (không pytest/unittest/godot nào chạy).

## Status trước đó: SCOPED + RED (2026-11-20 ~19:45 +07, lượt cron 19:45)

- N2284 DONE + PUSHED 19:30 +07, origin/main == 6c18436d. SSOT lúc push
  11665/1734/1668/3127; defense slices 210, contracts 209; comp 558/462.
- **N2506 = BuildingComp `senseObject()` cho duo** — slice tiếp theo, chọn từ
  deferred list của N2284 (ứng viên còn lại: logic-processor dispatch hook;
  dead/health/totalItems/camera* legs; powerNet* graph legs).
- **Số slice N2506, KHÔNG phải N2285**: N2285–N2505 đã có người dùng trên các
  branch khác (pump/bridge/drill/write-back + merge-wave line
  `codex/godot-all-debt-20261119`, KHÔNG nằm trên main; `git log --all` max
  N2505, không có N2506 ở đâu). Lấy N2285 sẽ đụng branch
  `slice/N2285-pump-dump-liquid` khi merge.
- Scope đã khóa: `docs/superpowers/handoffs/hidden_files/n2506-scope.md`.
  1 pure function `source_turret_sense_object_state(sensor, block_id,
  first_item)` trong SourceTurretBuildState.gd, ngay SAU
  `source_building_comp_sense_state` (:313), TRƯỚC
  `source_turret_progress_state` (:537). KHÔNG driver tick (logic read,
  tiền lệ N2206/N2208/N2223/N2283/N2284/N2234).
- RED tests:
  `tools/mindustry_godot_transpiler/tests/test_c07_turret_sense_object.py`
  (4 test methods, 6 proof keys) +
  `tools/mindustry_godot_transpiler/register_c07_turret_sense_object.py`
  (EXACT_EXPRS 26 + inputs 3 + outputs 3).
- RED xác nhận lượt này: **4 failed** trong 0.47s — registration KeyError
  'N2506', exact-evidence KeyError 'N2506', state AssertionError signature
  `source_turret_sense_object_state(...)` not found, proof Godot exit 1
  `Cannot open file 'res://tools/runtime_proofs/C07TurretSenseObjectProof.tscn'`
  (proof chưa viết — việc của lượt GREEN). Đúng lý do RED, không fail lạ.
  Register `--verify`: **32/32 exprs present**, exit 0.
- SSOT baseline (đo từ đĩa): symbols **11665**, Done **1734**, contracts
  **1668**, schemas **3127**; comp slices 558 / contracts 462; defense
  210/209. Kỳ vọng sau GREEN: 11668/1735/1669/3129; comp 559/463.
- `git diff --check`: SẠCH. HEAD vẫn 6c18436d (N2284 DONE + PUSHED).
  Worktree giữ file N2506 chưa commit (scope + test + register, untracked).
  Không commit/push (gate chưa xanh). javalang 0.13.0 + pytest 9.2.0 OK;
  port 7777 free; ps sạch.
- LƯU Ý PATH: Godot nằm ở `~/workspace/godot-bin/godot` (symlink tới
  `Godot_v4.6.2-stable_linux.x86_64`) nhưng KHÔNG có trên PATH mặc định
  của exec — targeted proof test fail `assertIsNotNone(godot)` nếu không
  export. Lượt GREEN phải chạy với
  `PATH="$HOME/workspace/godot-bin:$PATH"` (đã xác minh: Godot
  4.6.2.stable.official.71f334935 chạy được, proof test fail đúng lý do
  thiếu .tscn).

## Java evidence

- `senseObject()` — BuildingComp.java:2128-2136 (`public Object
  senseObject(LAccess sensor){ return switch(sensor){ case type -> block;
  case firstItem -> items == null ? null : items.first(); case config ->
  block.configSenseable() ? config() : null; case payloadType ->
  getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload()
  instanceof BuildPayload p2 ? p2.block() : null; default -> noSensed; };
  }`).
- Unhandled sensor → `noSensed` sentinel (`Object noSensed = new Object();`,
  Senseable.java:6), logic converts to numeric `sense()` fallback
  (`if(objOut == Senseable.noSensed){` / `to.setnum(se.sense(la));`,
  LExecutor.java:697-699) — port reports `handled: false` +
  `is_no_sensed: true` (tiền lệ sense() N2223 `sense_value_is_nan`).
- Leg-by-leg (đã xác minh từ disk, xem scope): type → block_id "duo"
  (Blocks.java:3257); firstItem → param `first_item` ("" = null), duo
  hasItems=true (ItemTurret.java:28) nên items non-null,
  `first()` quét content order (ItemModule.java:182-189); config →
  constant null (duo không đăng ký `config(...)` nào → `configSenseable()`
  false, Block.java:809-812; base `config()` null, BuildingComp.java:2024);
  payloadType → constant null (base `getPayload()` null,
  BuildingComp.java:984-985, không override ở turret).

## GREEN (lượt cron 20:00 +07 — ĐÃ XONG)

- Pure function `source_turret_sense_object_state` theo scope (3 return
  shape — type → block_id; firstItem → first_item_value; config /
  payloadType → null; default → handled false + is_no_sensed true).
- Proof `C07TurretSenseObjectProof.gd` + `.tscn` (6 semantic keys +
  registry_valid + one_headquarter_per_ssot + matches = 9; JSON trên đĩa
  matches:true 9/9).
- Register đã chạy (ghi SSOT), targeted 4/4 (72 subtests, NHỚ export PATH
  godot-bin — đã làm), neighbours + wiring + gate CHỈ main thread launch.
- Kỳ vọng gate: Ran ~6233, failures ~235, skipped=5, toàn Godot-absent (+4
  tests / +1 failure đúng mẫu vs N2284).

## Tiếp theo (sau N2506)

- Chọn slice tiếp theo từ deferred list — ứng viên: logic-processor
  dispatch hook (LExecutor sense → turret sense → super.sense →
  senseObject fallback); dead/health/totalItems/camera* legs (khi có live
  input); powerNet* graph legs. calculateHeat vẫn BLOCKED (live entity
  scan); findTarget vẫn BLOCKED.

## Deferred (không đổi, trừ senseObject nay đang làm N2506)

- Logic-processor dispatch hook — slice riêng sau.
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
