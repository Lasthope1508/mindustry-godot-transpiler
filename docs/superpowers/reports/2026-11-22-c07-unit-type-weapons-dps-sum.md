# Báo cáo — N2536 UnitType `weapons.sumf(Weapon::dps)`: wiring N2533→N2534 (C07) [DONE + PUSHED]

Ngày: 2026-11-22 ~21:50 +07 (targeted re-run xác minh lượt đóng slice 17.28s; proof xanh lượt implement ~21:13 +07, đọc trực tiếp proof .json — mtime gốc 14:13Z, tái sinh 14:48Z bởi targeted re-run lượt đóng slice, nội dung không đổi), gate xong 14:40:26Z (21:40 +07), slice commit 3a6481d9.

## Trạng thái

- N2535 DONE + PUSHED (origin/main a98557c4).
- N2536 DONE + PUSHED (slice 3a6481d9, docs TBA, GOAL TBA, status TBA): wiring `weapons.sumf(Weapon::dps)` của `UnitType.estimateDps()` thành 1 pure function mới `source_unit_type_weapons_dps_sum_state` (SourceUnitTypeState.gd:232, sau `source_unit_type_estimate_dps_state`, trước generated bridges) cho UnitType family — KHÔNG driver tick call site (tổng dps là read/estimate, không phải per-tick). Hàm nhận 1 tham số (`weapons_dps`, Array float — mỗi giá trị từ `source_weapon_dps_state`, N2534) và trả đúng 1 key `weapons_dps_sum`. Đây là consumer slice nối N2533 (estimateDps nhận `weapons_dps_sum` làm float param) với N2534 (Weapon.dps()): hàm này tính tổng, nhưng consumer gọi nó rồi truyền vào `source_unit_type_estimate_dps_state` vẫn là slice sau.

## Làm được lượt này (GREEN + gate xong)

- Công thức (UnitType.java:1136): `dpsEstimate = weapons.sumf(Weapon::dps);` — tổng bắt đầu 0.0, cộng từng dps; weapons rỗng → 0.0 (arc Seq.sumf bắt đầu từ 0). `weapons` là `public Seq<Weapon> weapons = new Seq<>();` (UnitType.java:288).
- Hàm KHÔNG gọi `Weapon.dps()` trực tiếp (tiền lệ param-driven N2528/N2529/N2533 — gọi trực tiếp sẽ ép 13 bullet param vào signature UnitType). Trả đúng 1 key `weapons_dps_sum` (tiền lệ N2526, mọi return key đều là symbol).
- DORMANT live hôm nay (nói thẳng): tổng dps là read/estimate, không caller nào đọc (N2533 vẫn nhận `weapons_dps_sum` làm float param; consumer gọi hàm tổng này rồi truyền vào `source_unit_type_estimate_dps_state` là slice sau; C11 HUD / stats display đọc `weapons_dps_sum` là slice sau) → live behavior KHÔNG đổi.
- Proof 8 keys semantic: matches:true, 11/11 true (8 semantic + registry_valid + one_headquarter_per_ssot + matches; đọc trực tiếp `C07UnitTypeWeaponsDpsSumProof.json`). 8 key: weapons_dps_sum_empty (rỗng → 0.0) / weapons_dps_sum_single (60.0 → 60.0) / weapons_dps_sum_two (30.0 + 60.0 → 90.0) / weapons_dps_sum_fractional (12.5 + 25.0 → 37.5) / weapons_dps_sum_with_zero (0.0 + 45.0 → 45.0) / weapons_dps_sum_many (4 × 60.0 → 240.0) / weapons_dps_sum_large (500.0 + 500.0 → 1000.0) / weapons_dps_sum_small_fractions (0.5 + 0.25 + 0.25 → 1.0).
- `register_c07_unit_type_weapons_dps_sum.py --verify`: 6/6. SSOT đo từ đĩa: 11732/1765/1698/3187 (symbols +1, Done +1, contracts +1, schemas +2); type slices 58, contracts 58 (+1/+1, N2536 vào type shard — java_source UnitType.java, tiền lệ N2533/N2534/N2535), comp 572/475 KHÔNG đổi. Deferred pool 505 (502 + 3: 1 ghi weapons_dps_sum DONE + 1 nợ Windows + 1 C11 HUD/stats display đọc `weapons_dps_sum` DEFERRED). Lưu ý: handoff N2535 ghi pool 503 nhưng MEMORY.md ghi 502 (+3) — 503 đếm trùng Weapon.drawOutline() đã đếm ở N2534 (+4); 502 là số đúng, 505 = 502 + 3. Ledger N2536 status done, java_source UnitType.java, godot_owner `SourceUnitTypeState.source_unit_type_weapons_dps_sum_state`.
- Commit slice gồm 12 file (7 sửa + 5 mới — xác minh từ đĩa, đúng mẫu N2535: 1 file game + 6 file SSOT + test + register + proof .gd + .tscn; audit report KHÔNG đổi nên không stage).

## Test xanh/đỏ

- Xanh: targeted 4/4 OK (22 subtests, 17.28s, xác minh lại bởi lượt đóng slice, godot-bin trên PATH, port 7777 free); register --verify 6/6; neighbours 327/327 SẠCH (NEIGHBOURS-EXIT 0 14:15:28Z, chain lượt 2 launch main thread 13:57:10Z); wiring 32 OK (WIRING-EXIT 0 14:17:32Z); gate Ran 6353 trong 1254.682s, failures=265 toàn Godot-absent (xem Đỏ); `git diff --check` SẠCH (chạy lượt đóng slice).
- Đỏ: targeted chạy lần đầu KHÔNG có godot trên PATH thì fail đúng 1 test reference-graph (`assertIsNotNone(godot)` → unexpectedly None) — đúng mẫu Godot-absent; chạy lại với godot-bin trên PATH thì 4/4 OK. Gate lượt duy nhất (log full-suite-n2536-gate.log, launch main thread 14:19:29Z, unittest PID 19978, log mtime 14:40:26Z) Ran 6353, failures=265, skipped=5, errors=0 — phân rã theo FAIL block: 265 FAIL block, TẤT CẢ `AssertionError: unexpectedly None` (265 lần xuất hiện, đúng 1 lần/block); 0 KeyError, 0 `return_schema_linkage`, 0 ERROR; +4 tests / +1 failure vs gate N2535, đúng mẫu — failure mới là reference-graph test của N2536 (test_reference_graph_and_actual_c07_unit_type_weapons_dps_sum), Godot-absent vì gate chạy không có godot trên PATH. Baseline hydration test_liquid_consumer_hydration là 1 FAIL block hằng số, không đổi.

## Blocker

- Không có blocker cho slice. Môi trường: javalang 0.13.0 + pytest 9.2.0 OK (không cần cài lại). Port 7777 free cả lượt. Không có VM restart trong lượt (restart gần nhất vẫn là #29 lúc 11:46:08Z, PID1 không đổi). Chain neighbours lượt 1 chết ~60-90s sau launch (flake đã biết, chain lượt 2 main thread sống tới EXIT 0); log partial lượt 1 không còn trên đĩa lúc đóng slice.

## Bước tiếp theo

- N2536 đóng xong lượt này: commit/push theo mẫu 5 commit của N2535 (slice + docs + GOAL + status + hashes), spec Done 1764→1765 + row N2536, GOAL §5 thêm nợ Windows cho C07UnitTypeWeaponsDpsSumProof.
- Slice tiếp theo (chưa scope): `Weapon.drawOutline()` (Weapon.java:196+, `//TODO copy-pasted code`, draw code — rendering nằm ngoài game, có thể DEFERRED như các draw slice trước). Sau đó tiếp tục theo thứ tự UnitType.java / Weapon.java; calculateHeat vẫn BLOCKED (live entity scan); findTarget BLOCKED; Turret live hasAmmo() computation vẫn DEFERRED; Turret liquid-module wiring BLOCKED cho driver tick của N2525; LaserTurret shouldConsume cần per-build bullets list.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-22-c07-unit-type-weapons-dps-sum-handoff.md.
