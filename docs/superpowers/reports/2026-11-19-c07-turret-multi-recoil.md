# Report — N2256 Turret multi-recoil decay (C07, duo) [GREEN — gate xong, chờ commit + push]

## Status: GREEN (2026-11-19 ~07:00 +07, lượt cron 07:00) — slice `0a6a5494`; targeted 4/4, proof matches:true, register --verify 13/13, SSOT 11609/1706/1640/3071. Neighbours 79 passed + 931 subtests (1 fail là flake port-7777, chạy lại riêng xanh 4/4; không do N2256) + wiring 9/9 OK. Gate N2256 xong (log `tools/mindustry_godot_transpiler/full-suite-n2256-gate.log`): Ran 6117 in 1215.285s, failures=206, skipped=5, errors=0 — all 206 verified Godot-absent (205 × `AssertionError: unexpectedly None` + 1 hydration variant; riêng test N2256 trong gate cũng chỉ fail `unexpectedly None`, 3 test còn lại của slice pass trong gate). Chưa push.

- N2255 DONE + PUSHED (origin/main 6b6719d8) — đã xác minh đầu lượt.

## Sửa sai quan trọng: duo recoils = 2, không phải -1

- N2254/N2255 hoãn multi-recoil vì cho rằng duo recoils = -1 (chỉ trích class default Turret.java:142). Kiểm chứng ba nguồn lượt này: `recoils = 2;` ở Blocks.java:3301 trong block duo 3257–3330; port catalog entry duo có `"recoils": 2`; DrawTurret đọc `tb.curRecoils[part.recoilIndex]` (DrawTurret.java:104/115) cho hai barrel part recoilIndex 0/1 của duo. Vòng decay :520-525 và stamp :807-809 đều áp dụng cho duo.

## Slice (scope đã khóa)

- 1 pure function `source_turret_multi_recoil_state(cur_recoils: Array, recoils: int, recoil_time: float, delta: float) -> Dictionary` trong `SourceTurretBuildState.gd` + 1 driver tick nhánh duo, ngay sau tick decay N2254 (Java :519 rồi :520-525).
- Java: `if(recoils > 0){` / `if(curRecoils == null) curRecoils = new float[recoils];` / `curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);` (:520-525); field `public @Nullable float[] curRecoils;` (:285); duo recoils 2, recoilTime 20 (reload), step delta/20, không qua 0.
- Pure function trả mảng mới `{"cur_recoils": decayed}` (không mutate input; key vắng init zeros); driver đọc `frame["cur_recoils"]` (default []) rồi stamp lại.

## RED (lượt này)

- `python3 -m unittest tests.test_c07_turret_multi_recoil`: Ran 4, FAILED (failures=2, errors=2) — registration + input-evidence KeyError ledger N2256 chưa tồn tại, state test fail vì pure function chưa có, proof test fail vì `C07TurretMultiRecoilProof.tscn` chưa tồn tại.
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; uptime 38 phút.

## GREEN (lượt 06:30 — xác minh độc lập; code đã có trên đĩa từ sau RED)

- Pure function `source_turret_multi_recoil_state` + 1 driver tick duo (sau tick decay N2254) + sửa 2 comment sai về recoils đã có trong diff; register script + proof `C07TurretMultiRecoilProof` đã có; SSOT đã cập nhật đúng kỳ vọng 11609/1706/1640/3071, defense 185/184; `git diff --check` OK.
- Targeted: lần 1 `Ran 4, FAILED (failures=1)` — chỉ proof test fail vì port-7777 flake (`ERROR: [MCP Runtime] Failed to start server on port 7777: 22`, process neighbours của agent khác đang giữ port), proof JSON vẫn `matches:true` 11/11 keys. Chạy lại isolated: OK → targeted **4/4**. Register `--verify`: **13/13 exprs present**.
- Neighbours + wiring: ĐANG CHẠY bởi PID 8983 (agent khác / main thread, khởi ~23:31 UTC) — không chạy trùng. Gate chưa chạy (chỉ chạy từ main thread). Chưa commit/push.

## Tiếp theo (lượt sau)

- Gate N2256 xong, sạch ngoại trừ Godot → docs/spec/GOAL → commit + push.
- Sau đó N2257: multi-recoil stamp (:807-809) cho duo.

## Lượt 07:00 (gate xong, xác minh độc lập, không chạy test trùng)

- Gate N2256 xong 23:53 UTC (PID 9249 đã kết thúc, không còn chạy): **Ran 6117 in 1215.285s, failures=206, skipped=5, errors=0** — so với gate N2255 (Ran 6113, failures=205): +4 tests (đúng 4 test mới của N2256), +1 failure = test proof N2256 fail `AssertionError: unexpectedly None` (Godot-absent trong môi trường gate, giống mọi test proof khác trong gate); 3 test còn lại của N2256 pass trong gate. Đếm trong log: 206 FAIL header = 205 × `AssertionError: unexpectedly None` + 1 hydration variant (`unexpectedly None : Godot required for hydration proof`), 0 KeyError, 0 ERROR.
- Targeted chạy lại lượt này (Godot trên PATH, port 7777 trống): **Ran 4, OK (16.47s)** — xác nhận 4/4 trước commit.
- javalang 0.13.0 + pytest 9.2.0 OK; port 7777 trống; uptime 1:39, không restart.
