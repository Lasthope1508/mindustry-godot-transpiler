# Báo cáo — N2530 Turret canControl(): pure Turret.java canControl() port cho Turret family (C07) [DONE + PUSHED]

Ngày: 2026-11-22 ~12:15 +07 (proof xanh, đọc trực tiếp proof .json mtime 04:10:03Z; targeted 4/4 xác minh lượt này), gate xong 05:11:04Z (12:11:04 +07), push ~12:20 +07.

## Trạng thái

- N2529 DONE + PUSHED (origin/main 50bde34b).
- N2530 DONE + PUSHED (slice 611231fe, docs 1d874d53, GOAL d1b8433a, status TBD): port `canControl()` của `TurretBuild` thành 1 pure function mới `source_turret_can_control_state` (SourceTurretBuildState.gd:632) cho Turret family — KHÔNG driver tick call site (canControl() là read predicate, không phải per-tick; không caller nào đọc nó hôm nay, player control / UI là C11). Hàm nhận 1 tham số duy nhất `player_controllable: bool`, trả đúng 1 key `can_control`.

## Làm được lượt này (GREEN + gate xong)

- Công thức (Turret.java:376-379, override ControlBlock default): `return playerControllable;` — field `playerControllable` (Turret.java:97, default `true`), thu hẹp default `canControl()` trả `true` của `ControlBlock.java:15-17`. Không có per-def override trong Blocks.java (grep `playerControllable` trong Blocks.java = 0 kết quả) nên catalog hôm nay đồng nhất `true` — nhưng hàm vẫn nhận param tường minh theo mẫu N2526/N2527, KHÔNG hardcode.
- KHÔNG nhầm với `canControlSelect` (BuildingComp.java:677, method khác, đã có stub `source_building_can_control_select_state` trong SourceBuildingControlState.gd) và KHÔNG nhầm với `SourceUnitLifecycleState.player_controllable_state` (mức Unit type, khác hàm).
- Java gốc: `Turret.java:376-379` canControl; `:97` field `playerControllable`; `ControlBlock.java:15-17` default; `BuildTurret.java:103-105` canControl trả `true` — family khác (BuildTurret), KHÔNG thuộc N2530.
- DORMANT live hôm nay (nói thẳng): canControl() là read predicate, không caller nào đọc, driver tick chưa gọi hàm này → live behavior KHÔNG đổi. Khi C11 player control về, hàm này là canonical owner duy nhất của Turret canControl().
- Proof 8 keys semantic: matches:true, 11/11 true (8 semantic + registry_valid + one_headquarter_per_ssot + matches; đọc trực tiếp `C07TurretCanControlProof.json`, mtime 04:10:03Z). 8 key: can_control_base_default_true / can_control_bool_type / can_control_default_true / can_control_duo_true / can_control_false / can_control_param_driven / can_control_single_key / can_control_true.
- `register_c07_turret_can_control.py --verify`: 8/8 (xác minh lượt này). SSOT đo từ đĩa: 11724/1759/1692/3175 (symbols +1, Done +1, contracts +1, schemas +2); defense slices 217, contracts 216 (+1/+1, N2530 vào defense shard — java_source Turret.java, tiền lệ N2523/N2524/N2525/N2526/N2527/N2528), comp 572/475 KHÔNG đổi. Deferred pool đo lại: 485 → 487, đúng 2 entry mới, 0 entry bị xóa (1 ghi canControl() WIRED/DONE + 1 nợ Windows). Ledger N2530 status done, java_source Turret.java, godot_owner `SourceTurretBuildState.source_turret_can_control_state`.
- Commit 1 gồm 11 file (7 sửa + 4 mới — xác minh từ đĩa, đúng mẫu N2529).

## Test xanh/đỏ

- Xanh: targeted 4/4 OK (24 subtests, 16.76s, xác minh lượt này, chạy với godot-bin trên PATH, port 7777 free; proof headless chạy trong test); neighbours 303 passed trong 1014.26s (NEIGHBOURS-EXIT 0 04:11:43Z, log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2530-neighbours.log`); wiring 32 tests OK trong 127.844s (WIRING-EXIT 0 04:13:51Z, log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2530-wiring.log`); `git diff --check` SẠCH.
- Gate: chain log `hidden_files/n2530-chain.log` — GATE-START 04:16:36Z (chết theo VM restart #25 lúc 04:37Z, partial giữ riêng `n2530-gate-partial-restart25.log`), GATE-START 04:47:44Z (chết ~3 phút sau launch, mẫu drain timeout N2523, partial giữ riêng `n2530-gate-partial-run2-0447.log`), GATE-START 04:50:41Z (main-thread launch, sống tới EXIT), GATE-EXIT 1 05:11:04Z (log tools/mindustry_godot_transpiler/full-suite-n2530-gate.log). Ran 6329 trong 1221.013s, failures=259, skipped=5, errors=0 — xác minh độc lập lượt này (đếm theo FAIL block, không đếm substring): 259 FAIL = 258 × `AssertionError: unexpectedly None` thuần + 1 × `AssertionError: unexpectedly None : Godot required for hydration proof` trong 1 failure block pre-existing (test_liquid_consumer_hydration.py:66), 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2529 — đúng 4 test mới của N2530, +1 failure là reference-graph test của N2530, Godot-absent vì gate reset PATH không có godot-bin).
- Đỏ: không có test đỏ ngoài 259 failure Godot-absent trong gate (mẫu đã biết). BÀI HỌC ĐẾM (nhắc lại từ N2520–N2529): chuỗi `Godot required for hydration proof` xuất hiện 2 lần nhưng cả 2 lần đều thuộc CÙNG 1 failure block (test_liquid_consumer_hydration.py:66 — dòng assert trong traceback + dòng AssertionError); hydration là HẰNG SỐ baseline (N2526 = 254 + 1, N2527 = 255 + 1, N2528 = 256 + 1, N2529 = 257 + 1, N2530 = 258 + 1), không phải +1 của slice nào — đếm chuỗi sẽ nhân đôi, luôn đếm theo FAIL block + tên test. (Test `test_live_partial_apply_filter_cache_and_real_placement` có tên chứa "hydration" nhưng fail với `unexpectedly None` thuần — không phải hydration baseline.)

## Blocker

- Không có blocker cho slice. Môi trường: VM restart #25 lúc 04:37Z (11:37 +07, uptime 40 phút lúc kiểm tra); javalang/pytest vẫn OK sau restart (gate lượt 3 import javalang thành công và chạy tới EXIT — xác minh lượt này, không cần cài lại, mẫu restart #23/#24 khác nhau: kiểm tra trước khi cài lại). Gate 2 lượt đầu chết (restart + drain timeout), lượt 3 main-thread launch sống tới EXIT. Lượt sau vẫn kiểm tra lại javalang trước mọi gate theo quy tắc repo.

## Bước tiếp theo

- Push N2530 (slice + docs + GOAL + status + hashes, theo mẫu N2529).
- Slice tiếp theo theo thứ tự Turret.java (chưa scope): `fogRadius()` (Turret.java:420-423 — cần range() N2526 + hasAmmo param + peekAmmo rangeChange + tilesize + fogRadiusMultiplier), `drawrot()` (Turret.java:359-362 — `return rotation - 90;`, trivial), `UnitType.estimateDps()` (UnitType.java:1132-1144 — `weapons.sumf(Weapon::dps)` + suicide /15, DEFERRED từ N2529). calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; Turret liquid-module wiring BLOCKED cho driver tick của N2525; LaserTurret shouldConsume cần per-build bullets list.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-22-c07-turret-can-control-handoff.md.
