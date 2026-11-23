# Báo cáo — N2543 Weapon.update() leg 4 (C07) [DONE + PUSHED (slice 364af040, docs b5a01fa3, GOAL abac5890, status 4c54504e)]

Ngày: 2026-11-23 ~10:00 +07 (targeted re-run xác minh lượt đóng slice 18.31s; proof .json tái sinh 03:04:35Z bởi targeted re-run lượt đóng slice, nội dung không đổi), gate xong 02:55:34Z (09:55 +07), slice commit 364af040.

## Trạng thái

- N2542 DONE + PUSHED (origin/main d7dadcf1).
- N2543 DONE (slice 364af040): port `Weapon.update()` leg 4 — side-flip (Weapon.java:418-423) — thành 1 pure function mới `source_weapon_update_side_flip_state` (SourceWeaponsCoreState.gd:528 + delegate SourceWeaponsState.gd:200-201, Weapon.java:418-423) cho Weapon family — KHÔNG driver tick (update() chưa có driver trong port). Hàm nhận 9 tham số và trả đúng 3 key `mount_side, other_side_side, was_flipped`.

## Làm được lượt này (GREEN + gate xong)

- Công thức (Weapon.java:418-423): `//flip weapon shoot side for alternating weapons` / `boolean wasFlipped = mount.side;` / `if(otherSide >= 0 && alternate && mount.side == flipSprite && otherSide < unit.mounts.length && mount.reload <= reload / 2f && lastReload > reload / 2f){` / `unit.mounts[otherSide].side = !unit.mounts[otherSide].side;` / `mount.side = !mount.side;` / `}`. Guard là AND 6 chân đúng thứ tự Java; khi guard pass, cả hai side (mount này + mount đối diện) đều đảo; khi guard fail, cả hai giữ nguyên.
- Bẫy giữ đúng: so sánh reload là `<=` (bằng đúng nửa thì flip) nhưng lastReload là `>` strict (bằng đúng nửa thì KHÔNG flip) — proof key `no_flip_last_reload_at_half` bắt đúng chân này; `was_flipped` = `mount.side` TRƯỚC flip, trả nguyên vẹn cả khi guard fail — shoot gate :435 (`(!alternate || wasFlipped == flipSprite)`) sẽ đọc nó ở slice sau; `last_reload` là frame input riêng (reload TRƯỚC decay :294), vì leg 1 N2540 chỉ trả reload SAU decay; `other_mount_side` là param riêng vì hàm pure không đọc live mounts array (tiền lệ N2540).
- DORMANT live hôm nay (nói thẳng): update() chưa có driver trong port, không caller nào đọc hàm mới → live behavior KHÔNG đổi.
- Proof 7 keys semantic: matches:true, 10/10 true (7 semantic + registry_valid + one_headquarter_per_ssot + matches; đọc trực tiếp `C07WeaponUpdateSideFlipProof.json`, tái sinh 03:04:35Z bởi targeted re-run lượt đóng slice). 7 key: flip / no_flip_reload_not_crossed / no_flip_last_reload_at_half / no_flip_side_mismatch / no_flip_other_side_negative / no_flip_other_side_out_of_range / no_flip_alternate_false — mỗi key assert đủ bộ ba (mount_side, other_side_side, was_flipped).
- `register_c07_weapon_update_side_flip.py --verify`: 23/23 (11 exact exprs + 9 input + 3 output). SSOT đo từ đĩa: 11770/1772/1705/3201 (symbols +3, Done +1, contracts +1, schemas +2 so với lúc đóng N2542: 11767/1771/1704/3199); type slices 65, contracts 65 (+1/+1, N2543 vào type shard — java_source Weapon.java, tiền lệ N2533-N2542). Deferred pool 527 (524 + 3: 1 ghi Weapon.update() leg 4 DONE + 1 nợ Windows + 1 remaining legs DEFERRED). Ledger N2543 status done, java_source `core/src/mindustry/type/Weapon.java`, godot_owner `SourceWeaponsCoreState.source_weapon_update_side_flip_state`.
- Commit slice gồm 12 file (8 sửa + 4 mới — xác minh từ đĩa, đúng mẫu N2542: 2 file game + 6 file SSOT + test + register + proof .gd + .tscn; audit report KHÔNG đổi nên không stage).

## Test xanh/đỏ

- Xanh: targeted 4/4 OK (31 subtests, 18.31s, xác minh lại bởi lượt đóng slice, godot-bin trên PATH, port 7777 free); register --verify 23/23; neighbours 355/355 SẠCH (NEIGHBOURS-EXIT 0 02:31:48Z, 355 passed trong 1207.25s, gồm test_c07_weapon_update_side_flip.py 4/4); wiring 32 OK (WIRING-EXIT 0 02:33:53Z, Ran 32 tests trong 125.116s); gate Ran 6381 trong 1270.366s, failures=272 toàn Godot-absent (xem Đỏ); `git diff --check` SẠCH (chạy lượt đóng slice, trước commit 1).
- Đỏ: gate chạy KHÔNG có godot trên PATH → reference-graph test của N2543 fail `assertIsNotNone(godot)` trong gate; chính test này PASS trong neighbours run và PASS 4/4 ở targeted re-run lượt đóng slice khi godot có trên PATH — đúng thiết kế (test resolve godot qua `shutil.which`), không phải lỗi slice. Chain gate 1 lượt duy nhất, sống tới EXIT (không chết worker-launch, không VM restart lượt này). Gate (log full-suite-n2543-gate.log) Ran 6381 trong 1270.366s, failures=272, skipped=5, errors=0 — phân rã theo FAIL block: 272 FAIL block, TẤT CẢ `AssertionError: unexpectedly None`; 0 KeyError, 0 `return_schema_linkage`, 0 ERROR; +4 tests / +1 failure vs gate N2542, đúng mẫu — failure mới duy nhất trong diff FAIL list là reference-graph test của N2543 (Godot-absent vì gate chạy không có godot trên PATH, đúng thiết kế chain). Baseline hydration test_liquid_consumer_hydration là 1 FAIL block hằng số trong 272.

## Blocker

- Không có blocker cho slice. Môi trường: javalang 0.13.0 + pytest 9.2.0 còn nguyên (verify lượt này, import OK). Port 7777 free cả lượt. Không VM restart lượt này.

## Bước tiếp theo

- N2543 đóng xong lượt này: commit/push theo mẫu 5 commit của N2537/N2538/N2539/N2540/N2541/N2542 (slice 364af040 + docs + GOAL + status + hashes), spec Done 1771→1772 + row N2543, GOAL §5 thêm nợ Windows cho C07WeaponUpdateSideFlipProof.
- Slice tiếp theo (chưa scope): N2544, ứng viên Weapon.init() :562 (trivial, `if(alwaysContinuous){ continuous = true; }`, micro-slice — DEFERRED entry đã ghi trong register N2543) hoặc shoot gate + shoot() :429-444 (BLOCKED/live — shoot() spawn bullet thật, :459+; velLen cần unit.isRemote/deltaLen live); calculateHeat vẫn BLOCKED (live entity scan), findTarget BLOCKED; Turret live hasAmmo() computation vẫn DEFERRED; Turret liquid-module wiring BLOCKED cho driver tick của N2525; LaserTurret shouldConsume cần per-build bullets list.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-23-c07-weapon-update-side-flip-handoff.md.
