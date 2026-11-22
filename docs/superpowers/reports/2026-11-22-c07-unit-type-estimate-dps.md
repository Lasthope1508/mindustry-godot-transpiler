# Báo cáo — N2533 UnitType estimateDps(): pure UnitType.java estimateDps() port cho UnitType family (C07) [DONE + PUSHED]

Ngày: 2026-11-22 ~17:20 +07 (targeted re-run xác minh lượt này; proof xanh lượt implement ~16:00 +07, đọc trực tiếp proof .json — tái sinh 10:18:46Z bởi targeted re-run lượt này), gate xong 10:12:29Z (17:12:29 +07), slice commit 33a284de.

## Trạng thái

- N2532 DONE + PUSHED (origin/main e45de296).
- N2533 DONE + PUSHED (slice 33a284de, docs 2af6eca0, GOAL c10e80c8, status e7822e30): port `estimateDps()` của `UnitType` thành 1 pure function mới `source_unit_type_estimate_dps_state` (SourceUnitTypeState.gd:179, sau `landed_state`, trước các generated bridge) cho UnitType family — KHÔNG driver tick call site (estimateDps() là read/estimate, không phải per-tick; call site `UnitType.init()` là content-init, không phải driver). Hàm nhận 3 tham số (`cached_dps`, `weapons_dps_sum`, `has_kill_shooter_weapon`) và trả đúng 3 key `estimate_dps` / `cached_dps` / `branch`.

## Làm được lượt này (GREEN + gate xong)

- Công thức (UnitType.java:1132-1144): cache check `dpsEstimate < 0` trước — cached >= 0 → trả `cached_dps` (branch `cached`); cache âm (init `dpsEstimate = -1`, UnitType.java:104) → recompute `dpsEstimate = weapons.sumf(Weapon::dps)`; nếu weapons chứa bullet có `killShooter` → `dpsEstimate /= 15f` trên đúng field vừa cộng nên giá trị đã chia mới là giá trị được cache (branch `computed_suicide`), ngược lại branch `computed`.
- Cached 0.0 LÀ hit (0 không < 0) — khác với guard `>= 0f` của BulletType (N2529); KHÔNG nhầm hai guard này.
- `weapons_dps_sum` là float param (caller cộng `weapons.sumf(Weapon::dps)`) vì Weapon.dps() (Weapon.java:188-190, `(bullet.estimateDPS() / reload) * shoot.shots * 60f`) CHƯA port — slice riêng sau. `has_kill_shooter_weapon` là bool param (caller scan weapons tìm bullet có `killShooter`, BulletType.java:105).
- DORMANT live hôm nay (nói thẳng): estimateDps() là read/estimate, không caller nào đọc (N2529 vẫn nhận `spawn_unit_dps` / `despawn_unit_dps` làm param; C11 HUD / stats display đọc `estimate_dps` là slice sau) → live behavior KHÔNG đổi. Khi slice Weapon.dps() và wiring N2529→N2533 về, hàm này là canonical owner duy nhất của UnitType estimateDps().
- Proof 8 keys semantic: matches:true, 11/11 true (8 semantic + registry_valid + one_headquarter_per_ssot + matches; đọc trực tiếp `C07UnitTypeEstimateDpsProof.json`). 8 key: estimate_dps_cached_hit (42.0, cache thắng cả khi có suicide) / estimate_dps_cached_zero (0.0 LÀ hit) / estimate_dps_negative_cached_recomputes (-5.0 → 30.0) / estimate_dps_weapons_sum (120.0) / estimate_dps_fractional_sum (37.5) / estimate_dps_suicide (150.0 → 10.0) / estimate_dps_suicide_fraction (100.0 → 100/15) / estimate_dps_java_defaults (-1, no weapons → 0.0).
- `register_c07_unit_type_estimate_dps.py --verify`: 13/13 (xác minh lượt này). SSOT đo từ đĩa: 11729/1762/1695/3181 (symbols +3, Done +1, contracts +1, schemas +2); type slices 55, contracts 55 (+1/+1, N2533 vào type shard — java_source UnitType.java, tiền lệ N1871–N1882), comp 572/475 KHÔNG đổi. Deferred pool 495 (491 + 4: 1 ghi estimateDps() DONE + 1 nợ Windows + 1 wiring N2529→N2533 DEFERRED + 1 Weapon.dps() DEFERRED). Ledger N2533 status done, java_source UnitType.java, godot_owner `SourceUnitTypeState.source_unit_type_estimate_dps_state`.
- Commit slice gồm 11 file (7 sửa + 4 mới — xác minh từ đĩa, đúng mẫu N2532).

## Test xanh/đỏ

- Xanh: targeted 4/4 OK (29 subtests, 16.09s, xác minh lượt này bởi main thread, chạy với godot-bin trên PATH, port 7777 free); neighbours 315 passed trong 1050.09s (NEIGHBOURS-EXIT 0 09:27:52Z, chain log `hidden_files/n2533-chain.log`); wiring 32 tests OK trong 124.993s (WIRING-EXIT 0 09:29:57Z); `git diff --check` SẠCH.
- Gate: chain log `hidden_files/n2533-chain.log` — GATE-START 09:31:26Z (chết ~60-90s sau launch, partial giữ riêng `full-suite-n2533-gate-partial-run1-0931.log`), GATE-START 09:33:28Z (chết theo VM restart #28 lúc 09:45:13Z, partial giữ riêng `full-suite-n2533-gate-partial-restart28.log`), GATE-START 09:49:19Z (chết ~60-90s sau launch, partial giữ riêng `full-suite-n2533-gate-partial-run3-0949.log`), GATE-START 09:51:39Z (main-thread launch, sống tới EXIT), GATE-EXIT 1 10:12:29Z (log tools/mindustry_godot_transpiler/full-suite-n2533-gate.log). Ran 6341 trong 1248.732s, failures=262, skipped=5, errors=0 — xác minh độc lập lượt này (đếm theo FAIL block, không đếm substring): 262 FAIL = 261 × `AssertionError: unexpectedly None` thuần + 1 × hydration pre-existing (test_liquid_consumer_hydration.py:66), 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2532 — đúng 4 test mới của N2533, +1 failure là reference-graph test của N2533, Godot-absent vì gate reset PATH không có godot-bin).
- Đỏ: không có test đỏ ngoài 262 failure Godot-absent trong gate (mẫu đã biết). BÀI HỌC ĐẾM (nhắc lại từ N2520–N2532): chuỗi `Godot required for hydration proof` xuất hiện 2 lần nhưng cả 2 lần đều thuộc CÙNG 1 failure block (test_liquid_consumer_hydration.py:66); hydration là HẰNG SỐ baseline (N2528 = 256 + 1, N2529 = 257 + 1, N2530 = 258 + 1, N2531 = 259 + 1, N2532 = 260 + 1, N2533 = 261 + 1), không phải +1 của slice nào — đếm chuỗi sẽ nhân đôi, luôn đếm theo FAIL block + tên test. Lưu ý lượt này: grep `^FAIL: test_liquid_consumer_hydration` cho 0 kết quả vì tên test là `test_live_block_shared_consumers_and_optional_efficiency_runtime`, module mới là `test_liquid_consumer_hydration` — đếm theo FAIL block + tên test đầy đủ.

## Blocker

- Không có blocker cho slice. Môi trường: VM restart #28 lúc 09:45:13Z (16:45:13 +07) giết gate lượt 2; gate lượt 1 và lượt 3 chết ~60-90s sau launch theo mẫu drain timeout N2523 (cả hai đều là worker-launch, worker ghi "survival-checked" là SAI/stale); gate lượt 4 main-thread launch sống tới EXIT. javalang 0.13.0 + pytest 9.2.0 OK (đã cài lại sau restart #28, kiểm tra lượt này). Port 7777 free cả lượt.

## Bước tiếp theo

- Push N2533 (docs + GOAL + status + hashes, theo mẫu N2532) rồi báo cáo.
- Slice tiếp theo theo thứ tự UnitType.java (chưa scope): `Weapon.dps()` (Weapon.java:188-190 — `(bullet.estimateDPS() / reload) * shoot.shots * 60f`; `bullet.estimateDPS()` đã có (N2529) nhưng wiring qua param hay gọi trực tiếp, `shoot.shots` (ShootPattern) là field hay param, `reload` field default — cần scope riêng). calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; Turret live hasAmmo() computation vẫn DEFERRED; Turret liquid-module wiring BLOCKED cho driver tick của N2525; LaserTurret shouldConsume cần per-build bullets list.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-22-c07-unit-type-estimate-dps-handoff.md.
