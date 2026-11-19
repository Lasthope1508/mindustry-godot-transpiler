# Handoff — N2258 Turret recoilOffset draw (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~10:45 +07, lượt cron 10:45) — slice commit TBD, docs TBD, GOAL TBD, status TBD. Targeted 4/4 + proof matches:true 11/11 + register --verify 10/10 + gate-2 Ran 6125, failures=208 toàn Godot-absent (đã xác minh độc lập).

- N2257 DONE + PUSHED (origin/main b02d14db, slice 2f244b54) — đã xác minh đầu lượt: git log 5 commit khớp, working tree sạch ngoại trừ noise *.gd.uid (không stage).

## Scope (đã khóa, xác minh từ đĩa)

- Slice recoilOffset draw cho duo: driver C07 mới (`SourceTurretBuildState.source_turret_tick_buildings_state`, nhánh duo) chưa bao giờ stamp `frame["recoil_offset"]` — công thức đã có một lần trên path legacy (N742, `PortGame.source_turret_recoil_offset`, MCP đã chứng minh recoil 0.5 / rotation 0 / curRecoil 1 → Vector2(-0.5, 0.0)), và `SourceTurretSimulationState.simulate_turrets` (:231/:263) vẫn gọi path cũ đó, nhưng nhánh duo driver mới (N2250–N2257) không có tick nào cho offset — sprite duo không kick-back live trên frame driver mới. N2258 là tick live trên driver mới, KHÔNG làm lại N742.
- 1 pure function `source_turret_recoil_offset_state(rotation: float, cur_recoil: float, recoil_pow: float, recoil: float) -> Dictionary` trong `SourceTurretBuildState.gd` (file turret chung — updateTile() là TurretBuild, không phải ItemTurret-only), đặt sau `source_turret_multi_recoil_stamp_state` + 1 driver tick trong nhánh duo, SAU tick multi-recoil decay N2256, TRƯỚC lời gọi aim/shoot.
- PIN Java: `recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);` (Turret.java:532); field `public Vec2 recoilOffset = new Vec2();` (:280, `/** Turret sprite offset, based on recoil. Updated every frame. */`); `public float recoilPow = 1.8f;` (:146, `/** power curve applied to visual recoil */`); `public float recoil = 1f;` (:140, `/** Visual amount by which the turret recoils back per shot. */`); `public float curRecoil, heat, logicControlTime = -1;` (:284); duo override `recoil = 0.5f;` (Blocks.java:3315, trong block duo 3257-3330); DrawTurret đọc offset ở mọi lệnh vẽ (DrawTurret.java:83/94/101/110/124/129/133/140).
- Thứ tự Java trong updateTile (:490-615) đã pin: :502-515 warmup → :519 decay curRecoil → :520-525 multi-recoil decay → :526 heat → :527 charge → :529-531 unit sync → **:532 recoilOffset** → :595-596 turnToTarget (`rotation = Angles.moveToward(...)`, :666) → :601/:609 updateShooting → :733 shoot gate → bullet() :806-811 stamp curRecoil=1. Nên tick port đặt sau decay, trước aim: offset dùng rotation của tick TRƯỚC (frame["rotation"], default 90.0 như aim stamp) và cur_recoil ĐÃ DECAY tick này — và lag phát bắn 1 tick (tick bắn offset vẫn dùng curRecoil pre-shot, tick sau mới kick).
- Pure function: trns (x = cos(rotation°) * mag, y = sin(rotation°) * mag, mag = -pow(cur_recoil, recoil_pow) * recoil), trả `{"recoil_offset": {"x": offset_x, "y": offset_y}}` — dict, quy ước frame JSON-friendly như frame["target_pos"] của aim N2250. 1 result symbol.
- Driver tick: `var recoil_offset: Dictionary = source_turret_recoil_offset_state(float(frame.get("rotation", 90.0)), float(frame.get("cur_recoil", 0.0)), 1.8, 0.5)` rồi `frame["recoil_offset"] = recoil_offset.get("recoil_offset", {"x": 0.0, "y": 0.0})`.
- 8 proof keys đã pin trong test: recoil_offset_zero_when_no_recoil, recoil_offset_full_kick_at_rotation_0, recoil_offset_full_kick_at_rotation_90, recoil_offset_pow_curve (curRecoil 0.5 → -pow(0.5,1.8)*0.5 ≈ -0.1436), recoil_offset_uses_decayed_recoil, recoil_offset_uses_previous_rotation, recoil_offset_stamped_to_frame, recoil_offset_lags_shot_by_one_tick.
- SSOT kỳ vọng sau GREEN: symbols +1, Done +1, contracts +1, schema +2 → 11611/1708/1642/3075; defense shard slices 186 → 187, contracts 185 → 186.

## RED (lượt này, đã chạy)

- `python3 -m unittest tests.test_c07_turret_recoil_offset` (PATH có ~/workspace/godot-bin): Ran 4, FAILED (failures=2, errors=2) — registration + input-evidence ERROR (ledger N2258 chưa tồn tại → KeyError N2258), state test FAIL vì pure function chưa có, proof test FAIL vì `C07TurretRecoilOffsetProof.tscn` chưa tồn tại (Godot exit 1, `Cannot open file 'res://tools/runtime_proofs/C07TurretRecoilOffsetProof.tscn'`). Đỏ đúng kỳ vọng, đúng mẫu RED của N2257.
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; uptime 1:39 (không restart gần đây); không có unittest discover đang chạy.

## GREEN (lượt cron 09:15 — đã làm)

- [x] Pure function + driver tick theo scope trên: `source_turret_recoil_offset_state` (SourceTurretBuildState.gd, sau `source_turret_multi_recoil_stamp_state`) + tick duo sau decay N2256, trước aim. `pow`/`cos`/`sin`/`deg_to_rad` là global GDScript, không cần preload mới.
- [x] Register script `register_c07_turret_recoil_offset.py` (owner `SourceTurretBuildState.source_turret_recoil_offset_state`, 1 symbol `source_turret_recoil_offset_state_result.recoil_offset`, runtime_proof `/root/C07TurretRecoilOffsetProof`); --verify **10/10 exprs present**; đã chạy register (SSOT 11611/1708/1642/3075; defense slices 187, contracts 186 — đúng kỳ vọng).
- [x] Proof `C07TurretRecoilOffsetProof` (.gd + .tscn) với 8 keys; JSON `matches:true`, 8/8 semantic true + registry_valid + one_headquarter_per_ssot.
- [x] Targeted 4/4 OK (15.5s, lượt đầu xanh sạch — kể cả proof test).
- [x] Neighbours + wiring — ĐÃ XÁC MINH XANH lượt cron 09:45: neighbours 22 module **88 passed, 988 subtests** (log goal hidden_files/n2258-neighbours-main.log); wiring 9 module **9/9 OK, 0 FAIL/ERROR** (log n2258-wiring-main.log).
- [x] Gate-1 (PID 2764, launch 09:33:37 +07, log `tools/mindustry_godot_transpiler/full-suite-n2258-gate.log`) XONG 09:54 +07: **Ran 6125 trong 1223.670s, FAILED (failures=217, skipped=5)** — KHÔNG sạch như kỳ vọng (~208). Xác minh độc lập: 217 FAIL header = 208 × "unexpectedly None" (Godot-absent, đúng baseline N2257 207 + 1 test proof mới) + **9 lỗi THẬT, cùng 1 gốc**: `return_schema_linkage: contract SourceTurretBuildState.source_turret_recoil_offset_state: return key not in source_turret_recoil_offset_result: recoil_offset` (8 test power slice + 1 catalog validator `1 != 0`). 0 KeyError, 0 ERROR. NGUYÊN NHÂN: validator `_contract_result_schema_name` thử `source_turret_recoil_offset_result` (schema legacy N742) TRƯỚC `source_turret_recoil_offset_state_result`, mà schema legacy không có key `recoil_offset` (chỉ có `offset`). N2254–N2257 không va vì không có schema legacy trùng tên.
- [x] FIX (lượt cron 10:00): thêm key `recoil_offset` vào schema legacy `source_turret_recoil_offset_result` dạng alias (`alias_of: source_turret_recoil_offset_state_result.recoil_offset`, status generated, type Dictionary) — đúng pattern alias sẵn có trong schema đó (curRecoil/formula/recoil/rotation/turret). Sửa trong `register_c07_turret_recoil_offset.py` (upsert merge, giữ nguyên mọi entry N742) + ghi chú (6) vào docstring; chạy lại register: --verify 10/10, schema count vẫn 3075, không symbol/contract mới.
- [x] Verify targeted sau fix: **Ran 13, OK** (147.1s) — 4 test N2258 + 8 test power slice lỗi trước đó + 1 catalog validator baseline. Neighbours + wiring đã xác minh độc lập từ log: neighbours 88 passed / 988 subtests, wiring 9/9 OK.
- [x] Gate-2 (full suite sau fix) — XONG ~10:32 +07: PID 6737 `python3 -m unittest discover -s tests`, launch ~10:14 +07 từ MAIN THREAD (gate-2 của worker PID 6185, launch 10:08, đã chết theo session — đúng bài học: gate CHỈ launch từ main thread), log `tools/mindustry_godot_transpiler/full-suite-n2258-gate2.log`. **Ran 6125 trong 1104.005s, FAILED (failures=208, skipped=5)** — sạch như kỳ vọng. Xác minh độc lập: 208 FAIL header = 208 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. So với gate-1: −9 failures (đúng 9 lỗi linkage đã fix). So với gate N2257 (Ran 6121, failures=207): +4 tests / +1 failure đúng bằng 4 test mới của slice.
- [x] Report/handoff/spec/GOAL hoàn thiện → commit + push (KHÔNG stage *.gd.uid / logs / project.godot) — gate-2 đã xanh.
- Môi trường: pytest 9.2.0 + javalang đều bị mất lúc ~09:2x (có thể VM restart — uptime sẽ kiểm tra lại khi neighbours xong), đã cài lại: requirements.txt (javalang 0.13.0) + pytest 9.2.0 riêng. Port 7777 trống, không discover đang chạy lúc launch neighbours.

## Tiếp theo: N2259 charge advance :527 + queuedBullets

- Charge advance :527 (cần queuedBullets + firstShotDelay > 0) — đi cùng slice queuedBullets; duo firstShotDelay 0 nên charge luôn 0 với duo.

## Deferred (không đổi)

- Charge advance :527 (cần queuedBullets + firstShotDelay > 0) — đi cùng slice queuedBullets; duo firstShotDelay 0 nên charge luôn 0 với duo.
- effects/sound, queuedBullets (shotDelay > 0), findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
