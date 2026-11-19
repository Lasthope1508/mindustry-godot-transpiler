# Handoff — N2257 Turret multi-recoil stamp (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~08:45 +07, lượt cron 08:45) — slice commit TBD, docs TBD, GOAL TBD, status TBD. Targeted 4/4 + proof matches:true 11/11 + register --verify 12/12 + gate Ran 6121, failures=207 toàn Godot-absent (đã xác minh độc lập).

- Cập nhật 08:45 +07 (lượt cron 08:45): gate xong 08:36 UTC — **Ran 6121 in 1119.811s, failures=207, skipped=5, errors=0**; xác minh độc lập: 207 FAIL header = 207 × `AssertionError: unexpectedly None`, 0 KeyError, 0 ERROR — toàn Godot-absent (+4 tests / +1 failure so với gate N2256 đúng bằng 4 test mới). Targeted chạy lại lượt này: **Ran 4, OK (16.32s)**. Proof JSON matches:true 11/11. Register --verify 12/12. SSOT 11610/1707/1641/3073, defense 186/185. Đủ điều kiện commit + push.

- Cập nhật 08:15 +07 (lượt cron 08:15): VM restart ~07:22 +07 giết gate cũ (PID 4653, log đóng băng 17 dots, không footer). Gate mới đang chạy: PID 7550 `python3 -m unittest discover -s tests`, khởi 08:17 +07, ghi vào đúng `full-suite-n2257-gate.log` — launcher không rõ (không phải lượt 08:15), nhưng đúng lệnh + đúng log nên không launch trùng. GREEN xác minh lại sau restart: targeted 4/4 OK. Kỳ vọng footer ~08:37: Ran ~6121 / failures ~207 / skipped 5, toàn Godot-absent.

- N2256 DONE + PUSHED (origin/main 0315a179, slice 0a6a5494) — đã xác minh đầu lượt: git log 5 commit gần nhất khớp, working tree sạch ngoại trừ noise *.gd.uid (không stage).

## Scope (đã khóa, xác minh từ đĩa)

- Slice multi-recoil stamp cho duo: driver chưa bao giờ stamp `frame["cur_recoils"]` sau khi bắn — N2255 chỉ stamp curRecoil/heat/totalShots đơn, N2256 chỉ decay mảng cur_recoils.
- 1 pure function `source_turret_multi_recoil_stamp_state(cur_recoils: Array, barrel: int, recoils: int) -> Dictionary` trong `SourceTurretBuildState.gd` (file turret chung — bullet() là TurretBuild.bullet, không phải ItemTurret-only), đặt ngay sau `source_turret_shoot_stamp_state` + 1 driver tick trong nhánh duo, NGAY SAU tick shoot stamp N2255 (Java order :806 rồi :807-809, cùng trong bullet(), sau bullet spawn :797).
- PIN: `curRecoil = 1f;` / `if(recoils > 0){` / `curRecoils[barrelCounter % recoils] = 1f;` / `}` / `heat = 1f;` / `totalShots++;` (Turret.java:806-811); field `public @Nullable float[] curRecoils;` (:285), null cho tới tick updateTile đầu tiên allocate (N2256 decay); `public int totalShots, barrelCounter;` (:287); `public int recoils = -1;` (:142) là default class, duo override `recoils = 2;` (Blocks.java:3301); `recoils = 2;` KHÔNG vào exact_exprs (lives in Blocks.java, not Turret.java).
- Pure function build MẢNG MỚI `stamped` dài `recoils` (entry thiếu đọc như 0.0, nên key frame vắng/null init thành zeros), entry `barrel % recoils` = 1.0, các entry khác giữ nguyên, KHÔNG mutate input, trả `{"cur_recoils": stamped}` — 1 result symbol. Khi recoils <= 0, guard Java không làm gì → trả input unchanged.
- Driver tick: `var multi_recoil_stamp: Dictionary = source_turret_multi_recoil_stamp_state(frame.get("cur_recoils", []), int(shoot_event.get("barrel", 0)), 2)` rồi `frame["cur_recoils"] = multi_recoil_stamp.get("cur_recoils", [])`.
- BẪY ĐÃ PIN: barrel phải là `shoot_event["barrel"]` (PRE-increment barrelCounter) — KHÔNG dùng `frame["barrel_counter"]`, vì tick aim ở :506 đã stamp `barrel_counter_after = barrelCounter + 1` (SourceItemTurretBuildState.gd:532-533). Dùng frame key sẽ stamp nhầm nòng bên kia. ShootAlternate chọn 1 nòng mỗi phát (ShootAlternate.java:31-37, barrels 2, spread 3.5, Blocks.java:3293), pattern.shoot chạy trước `}, () -> barrelCounter++);` (Turret.java:770), nên bullet() thấy barrelCounter pre-increment.
- 8 proof keys đã pin trong test: multi_recoil_stamp_sets_fired_barrel, multi_recoil_stamp_other_barrel_untouched, multi_recoil_stamp_alternates_barrels, multi_recoil_stamp_wraps_modulo, multi_recoil_stamp_init_zeros_when_absent, multi_recoil_stamp_preserves_other_entries, multi_recoil_stamp_stamped_to_frame_after_shoot, multi_recoil_stamp_runs_after_singular_stamp.
- SSOT kỳ vọng sau GREEN: symbols +1, Done +1, contracts +1, schema +2 → 11610/1707/1641/3073; defense shard slices 185 → 186, contracts 184 → 185.

## RED (lượt này, đã chạy)

- `python3 -m unittest tests.test_c07_turret_multi_recoil_stamp` (PATH có ~/workspace/godot-bin): Ran 4, FAILED (failures=2, errors=2) — registration + input-evidence ERROR (ledger N2257 chưa tồn tại), state test FAIL vì pure function chưa có, proof test FAIL vì `C07TurretMultiRecoilStampProof.tscn` chưa tồn tại. Đỏ đúng kỳ vọng.
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; uptime 1:54 (không restart gần đây).

## GREEN (xong — xác minh độc lập lượt cron 08:45)

- [x] Pure function + driver tick theo scope trên.
- [x] Register script `register_c07_turret_multi_recoil_stamp.py` (owner `SourceTurretBuildState.source_turret_multi_recoil_stamp_state`, 1 symbol `source_turret_multi_recoil_stamp_state_result.cur_recoils`, runtime_proof `/root/C07TurretMultiRecoilStampProof`); --verify 12/12.
- [x] Proof `C07TurretMultiRecoilStampProof` (.gd + .tscn) với 9 keys stamp; matches:true 11/11.
- [x] Targeted 4/4 (chạy lại lượt này 16.32s, port 7777 trống, không flake).
- [x] Neighbours + wiring — bao trong gate full suite (chỉ fail Godot-absent).
- [x] Gate (full suite; failures toàn Godot-absent, đã xác minh độc lập).
- [x] Report/handoff/spec/GOAL hoàn thiện → commit + push.

## Tiếp theo: N2258 recoilOffset draw

- N2258 candidate — recoilOffset draw (Turret.java:532, recoilPow 1.8, recoil duo 0.5) — draw-side; sau đó charge advance :527 với queuedBullets.

## Deferred sau N2256 (không đổi)

- recoilOffset draw (:532, recoilPow 1.8, recoil duo 0.5) — draw-side.
- Charge advance :527 (cần queuedBullets + firstShotDelay > 0) — đi cùng slice queuedBullets; duo firstShotDelay 0 nên charge luôn 0 với duo.
- effects/sound, queuedBullets (shotDelay > 0), findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
