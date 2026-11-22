# Báo cáo — N2539 Weapon.range() (C07) [DONE + PUSHED]

Ngày: 2026-11-23 ~03:15 +07 (targeted re-run xác minh lượt đóng slice 17.16s; proof xanh lượt implement ~01:45 +07, đọc trực tiếp proof .json — tái sinh 20:18Z bởi targeted re-run lượt đóng slice, nội dung không đổi), gate xong 20:07:43Z (03:07 +07), slice commit 19b5a529.

## Trạng thái

- N2538 DONE + PUSHED (origin/main 0cc82b4c).
- N2539 DONE + PUSHED (slice 19b5a529, docs TBD, GOAL TBD, status TBD): port `Weapon.range()` thành 1 pure function mới `source_weapon_range_state` (SourceWeaponsCoreState.gd:263 + delegate SourceWeaponsState.gd:188-189, Weapon.java:288-290) cho Weapon family — KHÔNG driver tick (catalog read). Hàm nhận 1 tham số (`bullet_range`) và trả đúng 1 key `range`.

## Làm được lượt này (GREEN + gate xong)

- Công thức (Weapon.java:288-290): `public float range(){ return bullet.range; }`. `bullet` là weapon bullet type (`public BulletType bullet = Bullets.placeholder;`, Weapon.java:33); `bullet.range` là BulletType range field (`public float range = 0f;`, BulletType.java:161), computed bởi calculateRange() ở init (BulletType.java:854) và afterPatch (BulletType.java:402). calculateRange() (BulletType.java:433-439) ĐÃ port từ trước (SourceBulletTypeInitRangeState.gd: `if(rangeOverride > 0) return rangeOverride;` / spawnUnit leg / despawnUnit leg / drag fallback `Math.max(Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag, maxRange)`) — slice này KHÔNG port lại calculateRange, chỉ lấy catalog `bullet.range` làm 1 input param (tiền lệ N2533: dps() lấy `bullet_estimate_dps` làm float param) và trả nguyên vẹn 1 key `{"range": bullet_range}`.
- Placeholder post-init range = 150.0 (đã xác minh: Bullets.placeholder là BasicBulletType(2.5f, 9, "ohno") với lifetime 60f; BulletType defaults drag 0f (:49), maxRange -1f (:153), lifetime 40f (:33), speed 1f (:37) — calculateRange: drag 0 → speed * lifetime = 2.5 * 60 = 150, max(150, -1) = 150).
- DORMANT live hôm nay (nói thẳng): range() là catalog read, không caller nào đọc (UnitType.init range/maxRange và Weapon.update shootLength là consumer slice sau) → live behavior KHÔNG đổi.
- Proof 4 keys semantic: matches:true, 7/7 true (4 semantic + registry_valid + one_headquarter_per_ssot + matches; đọc trực tiếp `C07WeaponRangeProof.json`, tái sinh 20:18Z bởi targeted re-run lượt đóng slice). 4 key: range_zero (0.0 → 0.0, field default) / range_placeholder (150.0 → 150.0) / range_fractional (37.5 → 37.5) / range_large (1000.0 → 1000.0).
- `register_c07_weapon_range.py --verify`: 4/4 (2 exact exprs + 1 input + 1 output). SSOT đo từ đĩa: 11751/1768/1701/3193 (symbols +1, Done +1, contracts +1, schemas +2); type slices 61, contracts 61 (+1/+1, N2539 vào type shard — java_source Weapon.java, tiền lệ N2533-N2538), comp 572/475 KHÔNG đổi. Deferred pool 515 (512 + 3: 1 ghi Weapon.range() DONE + 1 nợ Windows + 1 consumers DEFERRED). Ledger N2539 status done, java_source `core/src/mindustry/type/Weapon.java`, godot_owner `SourceWeaponsCoreState.source_weapon_range_state`.
- Commit slice gồm 12 file (8 sửa + 4 mới — xác minh từ đĩa, đúng mẫu N2538: 2 file game + 6 file SSOT + test + register + proof .gd + .tscn; audit report KHÔNG đổi nên không stage).

## Test xanh/đỏ

- Xanh: targeted 4/4 OK (12 subtests, 17.16s, xác minh lại bởi lượt đóng slice, godot-bin trên PATH, port 7777 free; lượt implement 28.868s); register --verify 4/4; neighbours 339/339 SẠCH (NEIGHBOURS-EXIT 0 19:36:25Z, 339 passed trong 1152.55s, gồm test_c07_weapon_range.py 4/4); wiring 32 OK (WIRING-EXIT 0 19:38:28Z, Ran 32 tests trong 123.514s); gate Ran 6365 trong 1295.771s, failures=268 toàn Godot-absent (xem Đỏ); `git diff --check` SẠCH (chạy lượt đóng slice, trước commit 1).
- Đỏ: chain lượt 1 (NEIGHBOURS-START 18:52:45Z) CHẾT do VM restart #31 ~02:08 +07 — chain.log có RELAUNCH nhưng KHÔNG có NEIGHBOURS-EXIT lượt 1, chết ~40% neighbours; restart này XÓA javalang + pytest — đã cài lại javalang 0.13.0 + pytest 9.2.0 theo RULE trước khi relaunch. Chain lượt 2 relaunch main thread 19:17:12Z, survival-check ~100s sau launch còn sống — qua cửa 60s (lesson N2523). Gate (log full-suite-n2539-gate.log, launch main thread 19:46:06Z, GATE-EXIT 1 20:07:43Z) Ran 6365 trong 1295.771s, failures=268, skipped=5, errors=0 — phân rã theo FAIL block: 268 FAIL block, TẤT CẢ `AssertionError: unexpectedly None` (268 lần xuất hiện, đúng 1 lần/block); 0 KeyError, 0 `return_schema_linkage`, 0 ERROR; +4 tests / +1 failure vs gate N2538, đúng mẫu — failure mới là reference-graph test của N2539 (test_reference_graph_and_actual_c07_weapon_range), Godot-absent vì gate chạy không có godot trên PATH. Baseline hydration test_liquid_consumer_hydration là 1 FAIL block hằng số trong 268 (assertion `unexpectedly None : Godot required for hydration proof`), không đổi.

## Blocker

- Không có blocker cho slice. Môi trường: javalang 0.13.0 + pytest 9.2.0 đã cài lại sau restart #31 (RULE). Port 7777 free cả lượt. VM restart #31 giết chain lượt 1 (~02:08 +07); không restart mới trong lượt đóng slice.

## Bước tiếp theo

- N2539 đóng xong lượt này: commit/push theo mẫu 5 commit của N2537/N2538 (slice 19b5a529 + docs + GOAL + status + hashes), spec Done 1767→1768 + row N2539, GOAL §5 thêm nợ Windows cho C07WeaponRangeProof.
- Slice tiếp theo (chưa scope): tiếp tục theo thứ tự Weapon.java / UnitType.java — Weapon.update() (Weapon.java:292) là tick method lớn, cần scope riêng (gồm retarget/findTarget BLOCKED, shootLength dùng range() — N2539 vừa xong, checkTarget, predict); calculateHeat vẫn BLOCKED (live entity scan), findTarget BLOCKED; Turret live hasAmmo() computation vẫn DEFERRED; Turret liquid-module wiring BLOCKED cho driver tick của N2525; LaserTurret shouldConsume cần per-build bullets list.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-23-c07-weapon-range-handoff.md.
