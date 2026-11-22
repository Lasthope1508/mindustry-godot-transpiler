# Báo cáo — N2535 Weapon shotsPerSec(): pure Weapon.java shotsPerSec() port cho Weapon family (C07) [DONE + PUSHED]

Ngày: 2026-11-22 ~20:32 +07 (targeted re-run xác minh lượt đóng slice 17.70s; proof xanh lượt implement ~19:30 +07, đọc trực tiếp proof .json — tái sinh 12:51Z bởi neighbours run), gate xong 13:22:44Z (20:22:44 +07), slice commit TBA.

## Trạng thái

- N2534 DONE + PUSHED (origin/main 308b9f00).
- N2535 DONE + PUSHED (slice TBA, docs TBA, GOAL TBA, status TBA): port `shotsPerSec()` của `Weapon` thành 1 pure function mới `source_weapon_shots_per_sec_state` (SourceWeaponsCoreState.gd:73, sau `source_weapon_dps_state`, trước `set_rotation_state`) + 1 delegate cùng tên trong SourceWeaponsState.gd:179-180 (tiền lệ facade `setup_mounts_state`) cho Weapon family — KHÔNG driver tick call site (shotsPerSec() là read/estimate, không phải per-tick). Hàm nhận 2 tham số (`reload`, `shoot_shots`) và trả đúng 1 key `shots_per_sec`.

## Làm được lượt này (GREEN + gate xong)

- Công thức (Weapon.java:192-194): `return shoot.shots * 60f / reload;` — không cache, không guard.
- `reload` là float param (default 1, Weapon.java:75; `RELOAD_DEFAULT := 1.0` đã có trong SourceWeaponDefaults.gd). `shoot_shots` là int param (ShootPattern.shots default 1, ShootPattern.java:8-9; `SHOTS_DEFAULT := 1` đã có trong SourceShootPatternDefaults.gd; weapon giữ pattern là `public ShootPattern shoot = new ShootPattern();`, Weapon.java:97).
- shotsPerSec() KHÔNG có cache (không có `cachedDps` / `dpsEstimate` trong Weapon.java — khác BulletType `cachedDps` và UnitType `dpsEstimate`): tính lại mỗi lần gọi, nên KHÔNG có key `cached_shots_per_sec`, KHÔNG có `branch` — trả đúng 1 key `shots_per_sec` (tiền lệ N2526, mọi return key đều là symbol).
- shotsPerSec() KHÔNG có guard `reload == 0` (chỉ `addStats()` Weapon.java:180 mới guard `reload > 0` cho hiển thị): port trung thực, không thêm guard — Java float / 0 → Infinity, không throw; GDScript float / 0.0 cũng vậy. Edge này KHÔNG có proof key (chưa xác nhận harness Godot, theo scoping N2534).
- DORMANT live hôm nay (nói thẳng): shotsPerSec() là read/estimate, không caller nào đọc (không caller Java ngoài Weapon; C11 HUD / stats display đọc `shots_per_sec` là slice sau) → live behavior KHÔNG đổi. Khi wiring về, hàm này là canonical owner duy nhất của Weapon shotsPerSec().
- Proof 8 keys semantic: matches:true, 11/11 true (8 semantic + registry_valid + one_headquarter_per_ssot + matches; đọc trực tiếp `C07WeaponShotsPerSecProof.json`, mtime 12:51Z — tái sinh bởi neighbours run). 8 key: sps_java_defaults (1.0 / 1 → 60.0) / sps_reload_2 (2.0 / 1 → 30.0) / sps_reload_fractional (0.5 / 1 → 120.0) / sps_shots_3 (1 / 3 → 180.0) / sps_shots_zero (shots 0 → 0.0) / sps_reload_60 (60.0 / 1 → 1.0) / sps_fractional (1.5 / 2 → 80.0) / sps_large (0.5 / 2 → 240.0).
- `register_c07_weapon_shots_per_sec.py --verify`: 8/8. SSOT đo từ đĩa: 11731/1764/1697/3185 (symbols +1, Done +1, contracts +1, schemas +2); type slices 57, contracts 57 (+1/+1, N2535 vào type shard — java_source Weapon.java, tiền lệ N2533/N2534), comp 572/475 KHÔNG đổi. Deferred pool 503 (499 + 4: 1 ghi Weapon.shotsPerSec() DONE + 1 nợ Windows + 1 C11 HUD/stats display đọc `shots_per_sec` DEFERRED + 1 Weapon.drawOutline() DEFERRED). Ledger N2535 status done, java_source Weapon.java, godot_owner `SourceWeaponsCoreState.source_weapon_shots_per_sec_state`.
- Commit slice gồm 12 file (8 sửa + 4 mới — xác minh từ đĩa, đúng mẫu N2534: 2 file game + 6 file SSOT + test + register + proof .gd + .tscn).

## Test xanh/đỏ

- Xanh: targeted 4/4 OK (23 subtests, 17.70s, xác minh lại bởi lượt đóng slice, godot-bin trên PATH, port 7777 free; lượt implement GREEN 4/4 theo hidden_files/n2535-red-green-1930.md); register --verify 8/8; neighbours 323/323 SẠCH (1089.36s, NEIGHBOURS-EXIT 0 12:52:49Z); wiring 32 OK (122.951s, WIRING-EXIT 0 12:54:52Z); gate Ran 6349 trong 1248.688s, failures=264 toàn Godot-absent (xem Đỏ); `git diff --check` SẠCH (chạy lượt đóng slice).
- Đỏ: RED trước GREEN: 4 test fail (KeyError 'N2535', đúng kỳ vọng, theo hidden_files/n2535-red-green-1930.md). Gate lượt duy nhất (log full-suite-n2535-gate.log, chain log hidden_files/n2535-chain.log; GATE-START 13:01:54Z main-thread launch, GATE-EXIT 1 13:22:44Z) Ran 6349, failures=264, skipped=5, errors=0 — phân rã theo FAIL block: 264 FAIL block, TẤT CẢ `AssertionError: unexpectedly None` (264 lần xuất hiện, đúng 1 lần/block); 0 KeyError, 0 `return_schema_linkage`, 0 ERROR; +4 tests / +1 failure vs gate N2534, đúng mẫu — failure mới là reference-graph test của N2535 (test_reference_graph_and_actual_c07_weapon_shots_per_sec), Godot-absent vì chain script reset PATH không có godot-bin. Baseline N2534 là 263 (261 × unexpectedly None thuần + 2 FAIL block hydration-module không đổi: test_live_partial_apply_filter_cache_and_real_placement + test_live_block_shared_consumers_and_optional_efficiency_runtime) + 1 reference-graph của N2534.

## Blocker

- Không có blocker cho slice. Môi trường: javalang 0.13.0 + pytest 9.2.0 OK (không cần cài lại). Port 7777 free cả lượt. Không có VM restart trong lượt (restart gần nhất vẫn là #29 lúc 11:46:08Z, PID1 không đổi).

## Bước tiếp theo

- N2535 đóng xong lượt này: commit/push theo mẫu 5 commit của N2534 (slice + docs + GOAL + status + hashes), spec Done 1763→1764 + row N2535, GOAL §5 thêm nợ Windows cho C07WeaponShotsPerSecProof.
- Slice tiếp theo theo thứ tự Weapon.java (chưa scope): wiring N2533→N2534 (UnitType `sumf(Weapon::dps)` consumer, slice consumer riêng) hoặc `Weapon.drawOutline()` (Weapon.java:196+, `//TODO copy-pasted code`, draw code — rendering nằm ngoài game, có thể DEFERRED như các draw slice trước). Sau đó tiếp tục theo thứ tự UnitType.java / Weapon.java; calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; Turret live hasAmmo() computation vẫn DEFERRED; Turret liquid-module wiring BLOCKED cho driver tick của N2525; LaserTurret shouldConsume cần per-build bullets list.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-22-c07-weapon-shots-per-sec-handoff.md.
