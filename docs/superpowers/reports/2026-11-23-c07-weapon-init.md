# Báo cáo — N2544 Weapon.init() (C07) [DONE + PUSHED (slice 700cdf91, docs 074dca5b, GOAL ce4c11b8)]

Ngày: 2026-11-23 ~11:45 +07 (targeted re-run xác minh lượt đóng slice 16.90s; proof .json tái sinh 04:46:57Z bởi targeted re-run lượt đóng slice, nội dung không đổi), gate xong 04:39:35Z (11:39 +07).

## Trạng thái

- N2543 DONE + PUSHED (origin/main ca2ed506).
- N2544 DONE: port `Weapon.init()` (Weapon.java:561-566) — thành 1 pure function mới `source_weapon_init_state` (SourceWeaponsCoreState.gd:588 + delegate SourceWeaponsState.gd:203-204, Weapon.java:561-566) cho Weapon family — KHÔNG driver tick (init() là lifecycle hook lúc load content, không phải tick). Hàm nhận 2 tham số và trả đúng 1 key `continuous`.

## Làm được lượt này (GREEN + gate xong)

- Công thức (Weapon.java:561-566): `@CallSuper` / `public void init(){` / `if(alwaysContinuous){` / `continuous = true;` / `}` / `}`. Chỉ set khi `alwaysContinuous` true — khi false, `continuous` giữ nguyên KỂ CẢ khi đang true (proof key `keeps_continuous_true_when_not_always` bắt đúng chân này). `@CallSuper` là annotation, không port thành logic — chỉ ghi trong comment.
- DORMANT live hôm nay (nói thẳng): init() chưa có driver trong port, không caller nào đọc hàm mới → live behavior KHÔNG đổi.
- Proof 4 keys semantic: matches:true, 7/7 true (4 semantic + registry_valid + one_headquarter_per_ssot + matches; đọc trực tiếp `C07WeaponInitProof.json`, tái sinh 04:46:57Z bởi targeted re-run lượt đóng slice). 4 key: sets_continuous / keeps_continuous_true / keeps_continuous_false / keeps_continuous_true_when_not_always.
- `register_c07_weapon_init.py --verify`: 11/11 (8 exact exprs + 2 input + 1 output). SSOT đo từ đĩa: 11771/1773/1706/3203 (symbols +1, Done +1, contracts +1, schemas +2 so với lúc đóng N2543: 11770/1772/1705/3201); type slices 66, contracts 66 (+1/+1, N2544 vào type shard — java_source Weapon.java, tiền lệ N2533-N2543). Deferred pool 530 (527 + 3: 1 ghi Weapon.init() DONE + 1 nợ Windows + 1 remaining legs DEFERRED). Ledger N2544 status done, java_source `core/src/mindustry/type/Weapon.java`, godot_owner `SourceWeaponsCoreState.source_weapon_init_state`.
- Commit slice gồm 12 file (8 sửa + 4 mới — xác minh từ đĩa, đúng mẫu N2543: 2 file game + 6 file SSOT + test + register + proof .gd + .tscn; audit report KHÔNG đổi nên không stage; proof .json ignored, gate log không stage).

## Test xanh/đỏ

- Xanh: targeted 4/4 OK (18 subtests, 16.90s, xác minh lại bởi lượt đóng slice, godot-bin trên PATH, port 7777 free; lượt implement 16.21s); register --verify 11/11; neighbours 359/359 SẠCH (NEIGHBOURS-EXIT 0 04:11:01Z, 359 passed trong 1201.73s, 88 modules, gồm test_c07_weapon_init.py 4/4); wiring 32 OK (WIRING-EXIT 0 04:13:06Z, Ran 32 tests trong 124.265s); gate Ran 6385 trong 1323.982s, failures=273 toàn Godot-absent (xem Đỏ); `git diff --check` SẠCH (chạy lượt đóng slice, trước commit 1).
- Đỏ: gate chạy KHÔNG có godot trên PATH → reference-graph test của N2544 fail `assertIsNotNone(godot)` trong gate; chính test này PASS trong neighbours run và PASS 4/4 ở targeted re-run lượt đóng slice khi godot có trên PATH — đúng thiết kế (test resolve godot qua `shutil.which`), không phải lỗi slice. Chain neighbours lượt 4 sống tới EXIT (lượt 1–3 chết theo VM restart #35 ~03:37Z); gate main-thread launch 1 lượt duy nhất, sống tới EXIT (GATE-START 04:17:29Z, GATE-EXIT 1 04:39:35Z). Gate (log full-suite-n2544-gate.log) Ran 6385 trong 1323.982s, failures=273, skipped=5, errors=0 — phân rã theo FAIL block: 273 FAIL block, 272× `AssertionError: unexpectedly None` + 1× hydration `AssertionError: unexpectedly None : Godot required for hydration proof`; 0 KeyError, 0 `return_schema_linkage`, 0 ERROR; +4 tests / +1 failure vs gate N2543, đúng mẫu — diff FAIL list: failure mới duy nhất là reference-graph test của N2544, 0 failure cũ biến mất (không regression). Baseline hydration test_liquid_consumer_hydration là 1 FAIL block hằng số trong 273.

## Blocker

- Không có blocker cho slice. Môi trường: VM restart #35 ~03:37Z (boot 03:37, journalctl xác nhận); javalang 0.13.0 + pytest 9.2.0 còn nguyên sau restart (verify lượt này, import OK, không cần cài lại). Port 7777 free cả lượt.

## Bước tiếp theo

- N2544 đóng xong lượt này: commit/push theo mẫu 5 commit của N2537–N2543 (slice + docs + GOAL + status + hashes), spec Done 1772→1773 + row N2544, GOAL §5 thêm nợ Windows cho C07WeaponInitProof.
- Slice tiếp theo (chưa scope): N2545, ứng viên Weapon.update() remaining legs — cần scope riêng (shoot gate + shoot() :429-444 BLOCKED/live; auto-target :315-347 BLOCKED; continuous-laser :376-408 BLOCKED làm driver leg; flip() :544 cần kiểm ShootPattern.copy()/flip()); calculateHeat vẫn BLOCKED (live entity scan), findTarget BLOCKED.
- Chi tiết: xem handoff docs/superpowers/handoffs/2026-11-23-c07-weapon-init-handoff.md.
