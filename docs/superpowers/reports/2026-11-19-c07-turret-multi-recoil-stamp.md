# Report — N2257 Turret multi-recoil stamp (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~08:45 +07, lượt cron 08:45) — slice commit TBD, docs TBD, GOAL TBD, status TBD. Targeted 4/4 + proof matches:true 11/11 + register --verify 12/12 + gate Ran 6121, failures=207 toàn Godot-absent (đã xác minh độc lập).

- N2256 DONE + PUSHED (origin/main 0315a179, slice 0a6a5494) — đã xác minh đầu lượt: git log 5 commit gần nhất khớp, working tree chỉ có diff N2257 + noise *.gd.uid (không stage).

## Slice (scope đã khóa)

- 1 pure function `source_turret_multi_recoil_stamp_state(cur_recoils: Array, barrel: int, recoils: int) -> Dictionary` trong `SourceTurretBuildState.gd:306` + 1 driver tick nhánh duo, NGAY SAU tick shoot stamp N2255 (Java order :806 rồi :807-809, cùng trong bullet(), sau bullet spawn :797).
- Java: `curRecoil = 1f;` / `if(recoils > 0){` / `curRecoils[barrelCounter % recoils] = 1f;` / `}` / `heat = 1f;` / `totalShots++;` (Turret.java:806-811); field :285 `public @Nullable float[] curRecoils;`, null tới tick updateTile đầu tiên allocate; :287 `public int totalShots, barrelCounter;`; duo `recoils = 2;` (Blocks.java:3301), KHÔNG vào exact_exprs.
- Pure function build MẢNG MỚI `stamped` dài `recoils` (entry thiếu đọc như 0.0, key vắng init zeros), entry `barrel % recoils` = 1.0, các entry khác giữ nguyên, KHÔNG mutate input, trả `{"cur_recoils": stamped}` — 1 result symbol. Khi recoils <= 0, guard Java không làm gì → trả input unchanged.
- Driver tick (SourceTurretBuildState.gd:600): `source_turret_multi_recoil_stamp_state(frame.get("cur_recoils", []), int(shoot_event.get("barrel", 0)), 2)` rồi stamp `frame["cur_recoils"]`.
- BẪY ĐÃ PIN (đã tránh): barrel lấy từ `shoot_event["barrel"]` (PRE-increment barrelCounter), KHÔNG dùng `frame["barrel_counter"]` vì tick aim đã stamp `barrel_counter_after = barrelCounter + 1`.

## RED (lượt cron 07:15)

- `python3 -m unittest tests.test_c07_turret_multi_recoil_stamp`: Ran 4, FAILED (failures=2, errors=2) — registration + input-evidence ERROR (ledger N2257 chưa tồn tại), state test FAIL vì pure function chưa có, proof test FAIL vì `C07TurretMultiRecoilStampProof.tscn` chưa tồn tại. Đỏ đúng kỳ vọng.

## GREEN (lượt cron 08:00 — code đã có trên đĩa; lượt này xác minh độc lập)

- Pure function + driver tick + register script + proof `C07TurretMultiRecoilStampProof` đã có; SSOT đúng kỳ vọng 11610/1707/1641/3073, defense 186/185; `git diff --check` OK.
- Targeted chạy lại lượt này (Godot trên PATH, port 7777 trống): **Ran 4, OK (16.32s)**.
- Proof JSON `C07TurretMultiRecoilStampProof.json`: **matches:true, 11/11 true** (9 keys stamp — gồm cả `multi_recoil_stamp_guard_returns_input_unchanged` — + `registry_valid` + `one_headquarter_per_ssot`).
- Register `--verify`: **12/12 exprs present**.
- Gate N2257 (log `tools/mindustry_godot_transpiler/full-suite-n2257-gate.log`, PID 7550, khởi 08:17, xong 08:36 UTC): **Ran 6121 in 1119.811s, failures=207, skipped=5, errors=0** — so với gate N2256 (Ran 6117, failures=206): +4 tests (đúng 4 test mới của N2257), +1 failure = test proof N2257 fail `AssertionError: unexpectedly None` (Godot-absent trong môi trường gate, giống mọi test proof khác trong gate); 3 test còn lại của N2257 pass trong gate. Đếm trong log: 207 FAIL header = 207 × `AssertionError: unexpectedly None`, 0 KeyError, 0 ERROR.
- javalang 0.13.0 + pytest 9.2.0 OK; port 7777 trống; không restart (gate cũ chết do VM restart ~07:22 đã được thay bằng gate mới 08:17).

## Tiếp theo: N2258

- N2258 candidate — recoilOffset draw (Turret.java:532, recoilPow 1.8, recoil duo 0.5) — draw-side; sau đó charge advance :527 với queuedBullets.
