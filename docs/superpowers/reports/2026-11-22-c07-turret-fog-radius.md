# Báo cáo — N2531 Turret fogRadius(): pure Turret.java fogRadius() port cho Turret family (C07) [DONE + PUSHED]

Ngày: 2026-11-22 ~14:05 +07 (targeted re-run xác minh lượt này; proof xanh lượt implement 12:51 +07, đọc trực tiếp proof .json — tái sinh 07:01:07Z bởi targeted re-run lượt này), gate xong 06:58:29Z (13:58:29 +07), slice commit 34cbcc90.

## Trạng thái

- N2530 DONE + PUSHED (origin/main eafdfdb4).
- N2531 DONE + PUSHED (slice 34cbcc90, docs 903bf260, GOAL b6d497fc): port `fogRadius()` của `TurretBuild` thành 1 pure function mới `source_turret_fog_radius_state` (SourceTurretBuildState.gd, sau can_control :632, trước can_heal) cho Turret family — KHÔNG driver tick call site (fogRadius() là read, không phải per-tick; không caller nào đọc nó hôm nay, fog-of-war / draw logic là slice sau). Hàm nhận 5 tham số (`range_value`, `has_ammo`, `peek_ammo_range_change`, `tilesize`, `fog_radius_multiplier`) và trả đúng 1 key `fog_radius`.

## Làm được lượt này (GREEN + gate xong)

- Công thức (Turret.java:420-422, TurretBuild override): `(range + (hasAmmo() ? peekAmmo().rangeChange : 0f)) / tilesize * fogRadiusMultiplier` — `range_value` là field `range` (BaseTurret.java:21, default 80f), KHÔNG phải range() (Turret.java:343-347); `has_ammo` là param vì hasAmmo() MUTATES ammo stack (Turret.java:703); `peek_ammo_range_change` là param (BulletType.rangeChange, BulletType.java:157, default 0f); `tilesize` = 8 (Vars.java:135); `fogRadiusMultiplier` default 1f (BaseTurret.java:24), per-def override scathe 0.4f (Blocks.java:5627).
- KHÔNG nhầm với block-init fogRadius (BaseTurret.java:59, field init ở block level) và KHÔNG nhầm với guard source-text `if(fogRadius > 0){` trong SourceBlockInitFlagsSourceTextState.gd.
- DORMANT live hôm nay (nói thẳng): fogRadius() là read, không caller nào đọc, driver tick chưa gọi hàm này → live behavior KHÔNG đổi. Khi fog-of-war / draw logic về, hàm này là canonical owner duy nhất của Turret fogRadius().
- Proof 8 keys semantic: matches:true, 11/11 true (8 semantic + registry_valid + one_headquarter_per_ssot + matches; đọc trực tiếp `C07TurretFogRadiusProof.json`). 8 key: fog_radius_ammo / fog_radius_default / fog_radius_float_type / fog_radius_no_ammo / fog_radius_param_driven / fog_radius_range_change_ignored / fog_radius_scathe_multiplier / fog_radius_single_key.
- `register_c07_turret_fog_radius.py --verify`: 13/13 (lượt implement). SSOT đo từ đĩa: 11725/1760/1693/3177 (symbols +1, Done +1, contracts +1, schemas +2); defense slices 218, contracts 217 (+1/+1, N2531 vào defense shard — java_source Turret.java, tiền lệ N2523–N2530), comp 572/475 KHÔNG đổi. Deferred pool 489 (487 + 2: 1 ghi fogRadius() DONE + 1 nợ Windows). Ledger N2531 status done, java_source Turret.java, godot_owner `SourceTurretBuildState.source_turret_fog_radius_state`.
- Commit slice gồm 11 file (7 sửa + 4 mới — xác minh từ đĩa, đúng mẫu N2530).

## Test xanh/đỏ

- Xanh: targeted 4/4 OK (25 subtests, 16.86s, xác minh lượt này bởi main thread, chạy với godot-bin trên PATH, port 7777 free; lượt implement 14.14s, RED xác nhận fail đúng 4 failed trước GREEN); neighbours 307 passed trong 1014.57s (NEIGHBOURS-EXIT 0 06:33:22Z, log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2531-neighbours.log`; 2 lượt partial trước 05:55/05:58 chết theo mẫu drain timeout, log giữ riêng `n2531-neighbours-partial-run1-0555.log`); wiring 32 tests OK trong 123.116s (WIRING-EXIT 0 06:35:25Z, log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2531-wiring.log`); `git diff --check` SẠCH.
- Gate: chain log `hidden_files/n2531-chain.log` — GATE-START 06:36:01Z (chết ~2 phút sau launch, mẫu drain timeout N2523, partial giữ riêng `n2531-gate-partial-run1-0636.log`), GATE-START 06:38:00Z (main-thread launch, sống tới EXIT), GATE-EXIT 1 06:58:29Z (log tools/mindustry_godot_transpiler/full-suite-n2531-gate.log). Ran 6333 trong 1227.548s, failures=260, skipped=5, errors=0 — xác minh độc lập lượt này (đếm theo FAIL block, không đếm substring): 260 FAIL = 259 × `AssertionError: unexpectedly None` thuần + 1 × hydration pre-existing (test_liquid_consumer_hydration.py:66), 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2530 — đúng 4 test mới của N2531, +1 failure là reference-graph test của N2531, Godot-absent vì gate reset PATH không có godot-bin).
- Đỏ: không có test đỏ ngoài 260 failure Godot-absent trong gate (mẫu đã biết). BÀI HỌC ĐẾM (nhắc lại từ N2520–N2530): chuỗi `Godot required for hydration proof` xuất hiện 2 lần nhưng cả 2 lần đều thuộc CÙNG 1 failure block (test_liquid_consumer_hydration.py:66); hydration là HẰNG SỐ baseline (N2528 = 256 + 1, N2529 = 257 + 1, N2530 = 258 + 1, N2531 = 259 + 1), không phải +1 của slice nào — đếm chuỗi sẽ nhân đôi, luôn đếm theo FAIL block + tên test.

## Blocker

- Không có blocker cho slice. Môi trường: không có VM restart lượt này (gate lượt 1 chết do drain timeout ~60s sau launch, mẫu N2523; lượt 2 main-thread launch sống tới EXIT). javalang 0.13.0 + pytest 9.2.0 OK (kiểm tra đầu lượt, không cần cài lại). Port 7777 free cả lượt.

## Bước tiếp theo

- Push N2531 (docs + GOAL + status + hashes, theo mẫu N2530) rồi báo cáo.
- Slice tiếp theo theo thứ tự Turret.java (chưa scope): `drawrot()` (Turret.java:359-362 — `return rotation - 90;`, trivial), `UnitType.estimateDps()` (UnitType.java:1132-1144 — `weapons.sumf(Weapon::dps)` + suicide /15, DEFERRED từ N2529). calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; Turret live hasAmmo() computation vẫn DEFERRED; Turret liquid-module wiring BLOCKED cho driver tick của N2525; LaserTurret shouldConsume cần per-build bullets list.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-22-c07-turret-fog-radius-handoff.md.
