# Report — N2262 Turret rotate sync (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~15:09 +07, lượt cron 15:00) — slice `f97d8dc0`, docs `992f2194`, GOAL `54fa1453`, status sẽ ghi sau. Targeted 4/4 + proof matches:true 12/12 + register --verify 10/10 + gate Ran 6141, failures=212 toàn Godot-absent (đã xác minh độc lập).

- N2261 DONE + PUSHED (origin/main 965c45c4, slice 4cebe133) — đã xác minh đầu lượt cron 15:00: git log 5 commit khớp, HEAD == origin/main == 965c45c4, worktree chỉ còn diff N2262 + noise *.gd.uid (không stage).

## Slice (scope đã khóa)

- 1 pure function `source_turret_rotate_sync_state(rotation: float, rotate: bool, building_rotation: int) -> Dictionary` trong `SourceTurretBuildState.gd:465` + 1 driver tick nhánh duo, SAU tick logicControlTime N2261, TRƯỚC aim call (Java order :534-536 decay, :538-540 heatReq, :542-545 rotate sync, :595-596 turnToTarget, :601/:609 updateShooting).
- Java: `if(rotate){ ((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4); }` (Turret.java:542-545); `rotate = true;` (Turret constructor :163, duo KHÔNG override — block duo Blocks.java:3257-3331 chỉ set `rotateSpeed = 10f;`); `transient int rotation;` (BuildingComp.java:69, default 0); arc `Mathf.round(float)` = round half UP về +inf như Java Math.round, KHÔNG phải half away from zero (Mathf.java:500-502); arc `Mathf.mod(float, float)` = proper mod cho số âm (Mathf.java:574-576).
- Pure function trả 1 result symbol `building_rotation`: rotate=false thì trả building_rotation nguyên vẹn (Java skip assignment); rotate=true thì `rounded = int(floor(rotation / 90.0 + 0.5))` (floor(x+0.5) = arc round half-up — KHÔNG dùng Godot `round()` vì nó half away from zero, sai cho -45/-135), rồi `((rounded % 4) + 4) % 4` (công thức arc mod).
- Driver tick (SourceTurretBuildState.gd:756): `source_turret_rotate_sync_state(float(frame.get("rotation", 90.0)), true, int(frame.get("building_rotation", 0)))` rồi stamp `frame["building_rotation"]`. Default rotation 90.0 = aim stamp default; default building_rotation 0 = Building field default (:69). Tick chạy TRƯỚC aim nên aim đọc rotation đã sync.
- Quyết định scope — heatReq fold :538-540 KHÔNG làm trong N2262: sync chỉ đọc frame rotation, không bao giờ đụng heat; fold chờ slice riêng (cần sideHeat + calculateHeat). Rotate sync cho def khác ngoài duo chưa wire (pure function nhận params, chỉ duo có driver tick).

## RED

- `python3 -m unittest tests.test_c07_turret_rotate_sync` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260/N2261. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2262'` (ledger chưa có entry N2262); state test FAIL vì pure function chưa có; proof test FAIL vì `C07TurretRotateSyncProof.tscn` chưa tồn tại (Godot exit 1).

## GREEN (lượt cron 14:30; gate lượt cron 15:00)

- Pure function + driver tick + register script + proof `C07TurretRotateSyncProof` đã có; SSOT đúng kỳ vọng 11620/1712/1646/3083, defense 191/190; `git diff --check` OK.
- Targeted chạy lại: **Ran 4, OK (14.778s)**.
- Proof JSON `C07TurretRotateSyncProof.json` (đọc trực tiếp lượt cron 15:00): **matches:true, 12/12 true** (9 keys rotate sync + `registry_valid` + `one_headquarter_per_ssot`).
- Register `--verify`: **10/10 exprs present**.
- Không cần fix harness: targeted chạy lần đầu đã 4/4 OK (proof seed frame rotation 270.0 trực tiếp trước tick; không đụng game). Key `rotate_sync_negative_half_rounds_up` (-45 → 0) pin đúng arc round half-up, khác Godot `round()` half away from zero.
- Neighbours 26 module — **XANH, đã xác minh độc lập lượt cron 14:45: 104 passed in 364.95s** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2262-neighbours.log`).
- Wiring 9 module live-loop — **XANH, đã xác minh độc lập lượt cron 14:45: Ran 32 tests, OK (127.468s)** (log `n2262-wiring.log`).
- Gate (log `tools/mindustry_godot_transpiler/full-suite-n2262-gate.log`, gate thay thế PID 12010, launch ~14:48 +07 lượt cron 14:45, xong ~15:07 +07): **Ran 6141 trong 1117.872s, FAILED (failures=212, skipped=5, errors=0)** — sạch như kỳ vọng. Xác minh độc lập lượt cron 15:00: 212 FAIL = 212 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, 0 AssertionError loại khác — toàn Godot-absent. So với gate N2261 (Ran 6137, failures=211): +4 tests / +1 failure đúng bằng 4 test mới của slice; +1 failure là test reference-graph của chính N2262 (Godot-absent trong môi trường gate, cùng mẫu N2256–N2261); 3 test còn lại của slice không nằm trong FAIL list → pass trong gate. Gate đầu (PID 11802) bị SIGTERM sau ~139s vì launch từ exec background thường — gate thay thế dùng `setsid nohup ... &` để detach (BÀI HỌC: gate launch từ exec background thường chết khi lượt cron kết thúc).
- javalang 0.13.0 + pytest 9.2.0 OK; port 7777 trống lúc launch gate.

## Tiếp theo: N2263

- N2263 candidate — HeatReq fold :538-540 (`if(heatRequirement > 0){ heatReq = calculateHeat(sideHeat); }`) — cần pin `heatRequirement` + `sideHeat` của Turret + duo có override không, và `calculateHeat` (Turret.java, cần đọc body).
