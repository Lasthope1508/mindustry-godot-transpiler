# Report — N2258 Turret recoilOffset draw (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~10:45 +07, lượt cron 10:45) — slice `0ba552b7`, docs `b84e45ac`, GOAL `d8db48d3`, status TBD (pushed; origin/main advances with this status commit). Targeted 4/4 + proof matches:true 11/11 + register --verify 10/10 + gate-2 Ran 6125, failures=208 toàn Godot-absent (đã xác minh độc lập).

- N2257 DONE + PUSHED (origin/main b02d14db, slice 2f244b54) — đã xác minh đầu lượt: git log 5 commit gần nhất khớp, working tree chỉ có diff N2258 + noise *.gd.uid (không stage).

## Slice (scope đã khóa)

- 1 pure function `source_turret_recoil_offset_state(rotation: float, cur_recoil: float, recoil_pow: float, recoil: float) -> Dictionary` trong `SourceTurretBuildState.gd:342` + 1 driver tick nhánh duo, SAU tick multi-recoil decay N2256, TRƯỚC aim/shoot (Java order :532 sau decay :519-525, trước turnToTarget :595-596).
- Java: `recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);` (Turret.java:532); field `public Vec2 recoilOffset = new Vec2();` (:280); `public float recoilPow = 1.8f;` (:146); `public float recoil = 1f;` (:140); `public float curRecoil, heat, logicControlTime = -1;` (:284); duo override `recoil = 0.5f;` (Blocks.java:3315, block duo 3257-3330).
- Pure function trns (x = cos(rotation°) * mag, y = sin(rotation°) * mag, mag = -pow(cur_recoil, recoil_pow) * recoil), trả `{"recoil_offset": {"x": offset_x, "y": offset_y}}` — dict, quy ước frame JSON-friendly như frame["target_pos"] của aim N2250. 1 result symbol.
- Driver tick (SourceTurretBuildState.gd:572-573): `source_turret_recoil_offset_state(float(frame.get("rotation", 90.0)), float(frame.get("cur_recoil", 0.0)), 1.8, 0.5)` rồi stamp `frame["recoil_offset"]` — offset dùng rotation của tick TRƯỚC và cur_recoil ĐÃ DECAY tick này, lag phát bắn 1 tick (đúng Java).
- Công thức đã có một lần trên path legacy (N742, `PortGame.source_turret_recoil_offset`, MCP đã chứng minh recoil 0.5 / rotation 0 / curRecoil 1 → Vector2(-0.5, 0.0)); N2258 là tick live trên driver mới, KHÔNG làm lại N742.

## RED (lượt cron 09:00)

- `python3 -m unittest tests.test_c07_turret_recoil_offset`: Ran 4, FAILED (failures=2, errors=2) — registration + input-evidence ERROR (ledger N2258 chưa tồn tại), state test FAIL vì pure function chưa có, proof test FAIL vì `C07TurretRecoilOffsetProof.tscn` chưa tồn tại. Đỏ đúng kỳ vọng, đúng mẫu RED của N2257.

## GREEN (lượt cron 09:15 — code đã có trên đĩa; lượt này xác minh độc lập)

- Pure function + driver tick + register script + proof `C07TurretRecoilOffsetProof` đã có; SSOT đúng kỳ vọng 11611/1708/1642/3075, defense 187/186; `git diff --check` OK.
- Targeted chạy lại lượt 09:15 (Godot trên PATH, port 7777 trống): **Ran 4, OK (15.5s)** — xanh sạch ngay lượt đầu, kể cả proof test.
- Proof JSON `C07TurretRecoilOffsetProof.json`: **matches:true, 11/11 true** (8 keys offset — gồm cả `recoil_offset_pow_curve` (curRecoil 0.5 → ≈ -0.1436) và `recoil_offset_lags_shot_by_one_tick` — + `registry_valid` + `one_headquarter_per_ssot`).
- Register `--verify`: **10/10 exprs present**.
- Neighbours 22 module (log goal hidden_files/n2258-neighbours-main.log): **88 passed, 988 subtests** — xanh sạch ngay lượt đầu. Wiring 9 module (log n2258-wiring-main.log): **9/9 OK, 0 FAIL/ERROR**.
- Gate-1 (log `tools/mindustry_godot_transpiler/full-suite-n2258-gate.log`, PID 2764, khởi 09:33:37 +07, xong 09:54): **Ran 6125 in 1223.670s, FAILED (failures=217, skipped=5)** — KHÔNG sạch như kỳ vọng (~208). Xác minh độc lập: 217 FAIL header = 208 × `AssertionError: unexpectedly None` (Godot-absent) + **9 lỗi THẬT cùng 1 gốc**: `return_schema_linkage: contract SourceTurretBuildState.source_turret_recoil_offset_state: return key not in source_turret_recoil_offset_result: recoil_offset` (8 test power slice + 1 catalog validator). 0 KeyError, 0 ERROR. NGUYÊN NHÂN: validator `_contract_result_schema_name` thử schema legacy N742 `source_turret_recoil_offset_result` TRƯỚC `source_turret_recoil_offset_state_result`, mà schema legacy không có key `recoil_offset` (chỉ có `offset`). N2254–N2257 không va vì không có schema legacy trùng tên.
- FIX (lượt cron 10:00): thêm key `recoil_offset` vào schema legacy `source_turret_recoil_offset_result` dạng alias (`alias_of: source_turret_recoil_offset_state_result.recoil_offset`, status generated, type Dictionary) — đúng pattern alias sẵn có trong schema đó; sửa trong `register_c07_turret_recoil_offset.py` (upsert merge, giữ nguyên mọi entry N742) + ghi chú (6) vào docstring; chạy lại register: --verify 10/10, schema count vẫn 3075, không symbol/contract mới.
- Verify sau fix: lượt cron 10:00 **Ran 13, OK (147.1s)** (4 test N2258 + 8 test power slice lỗi trước đó + 1 catalog validator); chạy lại độc lập lượt 10:1x trên 10 module liên quan: **20 passed, 33 subtests, 152.78s** — 9 test fail trước đây đều xanh.
- Gate-2 (log `tools/mindustry_godot_transpiler/full-suite-n2258-gate2.log`, PID 6737, main thread, khởi ~10:14 +07, xong ~10:32): **Ran 6125 in 1104.005s, FAILED (failures=208, skipped=5)** — sạch như kỳ vọng. Xác minh độc lập: 208 FAIL header = 208 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. So với gate-1: −9 failures (đúng 9 lỗi linkage đã fix). So với gate N2257 (Ran 6121, failures=207): +4 tests / +1 failure đúng bằng 4 test mới của slice (1 test proof fail Godot-absent trong môi trường gate, 3 test còn lại pass trong gate).
- javalang 0.13.0 + pytest 9.2.0 OK; port 7777 trống lúc launch gate-2; gate-2 của worker (PID 6185, launch 10:08) đã chết theo session — đúng bài học: gate CHỈ launch từ main thread.

## Tiếp theo: N2259

- N2259 candidate — charge advance (Turret.java:527, cần queuedBullets + firstShotDelay > 0) — đi cùng slice queuedBullets; duo firstShotDelay 0 nên charge luôn 0 với duo.
