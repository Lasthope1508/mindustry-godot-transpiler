# Handoff — N2262 Turret rotate sync (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~15:09 +07, lượt cron 15:00) — slice `f97d8dc0`, docs `992f2194`, GOAL `54fa1453`, status `1fae1aaa` (pushed; origin/main advances with this status commit). Targeted 4/4 OK + proof matches:true 12/12 + register --verify 10/10 + SSOT 11620/1712/1646/3083 + neighbours 104 passed + wiring 32 OK + gate Ran 6141, failures=212 toàn Godot-absent (đã xác minh độc lập).

- N2261 DONE + PUSHED (origin/main 965c45c4, slice 4cebe133) — đã xác minh đầu lượt: git log 5 commit khớp, HEAD == origin/main == 965c45c4, worktree sạch ngoại trừ noise *.gd.uid (không stage). javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover đang chạy.

## Scope (đã khóa, xác minh từ đĩa)

- Slice rotate sync cho duo: driver C07 mới (`SourceTurretBuildState.source_turret_tick_buildings_state`, nhánh duo) chưa bao giờ sync building rotation — `rotation` của TurretBuild là float độ, còn `((Building)this).rotation` là int 0-3 shadowed (`transient int rotation;`, BuildingComp.java:69, default 0), và updateTile() sync nó mỗi tick (`if(rotate){ ((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4); }`, Turret.java:542-545), sau logicControlTime decay :534-536, trước heatReq :538-540 và turnToTarget :595-596. N2262 là tick live trên driver mới, KHÔNG làm lại path legacy (không có path legacy cho rotate sync).
- 1 pure function `source_turret_rotate_sync_state(rotation: float, rotate: bool, building_rotation: int) -> Dictionary` trong `SourceTurretBuildState.gd` (file turret chung — updateTile() là TurretBuild, không phải ItemTurret-only) + 1 driver tick trong nhánh duo, SAU tick logicControlTime N2261, TRƯỚC aim call (Java order :534-536 decay, :538-540 heatReq, :542-545 rotate sync, :595-596 turnToTarget, :601/:609 updateShooting).
- PIN Java: `if(rotate){` / `((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4);` (Turret.java:542-545); `rotate = true;` (Turret constructor :163, duo KHÔNG override — block duo Blocks.java:3257-3331 chỉ set `rotateSpeed = 10f;`); `transient int rotation;` (BuildingComp.java:69, default 0); arc `Mathf.round(float)` = `return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;` (Mathf.java:500-502, round half UP về +inf như Java Math.round, KHÔNG phải half away from zero); arc `Mathf.mod(float, float)` = `return ((f % n) + n) % n;` (Mathf.java:574-576, proper mod cho số âm).
- Pure function: rotate=false thì trả building_rotation nguyên vẹn (Java skip assignment); rotate=true thì `rounded = int(floor(rotation / 90.0 + 0.5))` (floor(x+0.5) = arc round half-up, precedent SourceBlockRequirementsState — KHÔNG dùng Godot `round()` vì nó half away from zero, sai cho -45/-135), rồi `((rounded % 4) + 4) % 4` (công thức arc mod). Trả 1 result symbol `building_rotation`.
- Driver tick: `var rotate_sync: Dictionary = source_turret_rotate_sync_state(float(frame.get("rotation", 90.0)), true, int(frame.get("building_rotation", 0)))` rồi stamp `frame["building_rotation"]`. Default rotation 90.0 = aim stamp default; default building_rotation 0 = Building field default (:69). Tick chạy TRƯỚC aim nên aim đọc rotation đã sync.
- 9 proof keys đã pin trong test: rotate_sync_zero_degrees, rotate_sync_ninety_degrees, rotate_sync_rounds_half_up, rotate_sync_wraps_at_360, rotate_sync_negative_wraps, rotate_sync_negative_half_rounds_up, rotate_sync_disabled_keeps_rotation, rotate_sync_stamped_to_frame, rotate_sync_duo_live.
- SSOT kỳ vọng sau GREEN: symbols +1, Done +1, contracts +1, schema +2 → 11620/1712/1646/3083 (schema đếm schema object: input + result = 2/slice, giống N2259-N2261); defense shard slices 190 → 191, contracts 189 → 190.
- Quyết định scope — heatReq fold :538-540 KHÔNG làm trong N2262: sync chỉ đọc frame rotation, không bao giờ đụng heat; fold chờ slice riêng (cần sideHeat + calculateHeat). Rotate sync cho def khác ngoài duo chưa wire (pure function nhận params, chỉ duo có driver tick).

## RED (lượt này, chạy + xác minh độc lập)

- `python3 -m unittest tests.test_c07_turret_rotate_sync` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260/N2261. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2262'` (ledger chưa có entry N2262); state test FAIL vì pure function `source_turret_rotate_sync_state` chưa có; proof test FAIL vì `C07TurretRotateSyncProof.tscn` chưa tồn tại (Godot exit 1, `Cannot open file 'res://tools/runtime_proofs/C07TurretRotateSyncProof.tscn'`).
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover đang chạy.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_rotate_sync.py` + handoff này (untracked). Không stage/commit gì ở bước RED.

## GREEN (lượt cron 14:30, đã chạy + đã xác minh)

- Pure function `source_turret_rotate_sync_state` (SourceTurretBuildState.gd, sau `source_turret_logic_control_time_state`) + driver tick trong nhánh duo SAU tick logicControlTime N2261, TRƯỚC aim call — đúng scope. Java lines đã xác minh lại từ đĩa trước khi viết: Turret.java:542-545 / :163 / Blocks.java:3257-3331 (duo không override rotate) / BuildingComp.java:69 / arc Mathf.java:500-502, 574-576.
- Register script `register_c07_turret_rotate_sync.py`: **--verify 10/10 exprs present**; đã chạy — SSOT **11620/1712/1646/3083** (symbols +1, Done +1, contracts +1, schema +2 đúng kỳ vọng); defense slices 191, contracts 190.
- Proof `C07TurretRotateSyncProof` (.gd + .tscn): targeted **Ran 4, OK (14.778s)**; JSON đã đọc trực tiếp: **matches:true, 9/9 semantic true + registry_valid + one_headquarter_per_ssot (12/12)**.
- Neighbours (26 module: 12 PointDefenseTurret + 3 ItemTurret + 10 turret slices warmup/recoil_heat/multi_recoil/multi_recoil_stamp/shoot_stamp/recoil_offset/charge/unit_sync/logic_control_time/rotate_sync + test_turret_live_loop, kỳ vọng 104 tests) — **XONG, đã xác minh độc lập lượt cron 14:45**: log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2262-neighbours.log` — **104 passed in 364.95s**, 0 FAILED/ERROR.
- Wiring (9 module live-loop, kỳ vọng Ran 32 OK) — **XONG, đã xác minh độc lập lượt cron 14:45**: log `n2262-wiring.log` — **Ran 32 tests, OK** (127.468s).
- Gate — **XONG, SẠCH (gate thay thế, PID 12010)**. Lượt cron 14:45 launch gate PID 11802 từ exec background thường — bị SIGTERM sau ~139s khi lượt chạy kết thúc (log chỉ còn 149 byte dots, không có GATE-EXIT). Gate thay thế đã được launch lại lúc ~14:48 +07 bằng `setsid nohup python3 -m unittest discover -s tests` (cùng lệnh chuẩn, KHÔNG godot-bin trong PATH), log `tools/mindustry_godot_transpiler/full-suite-n2262-gate.log`. **Xong ~15:07 +07: Ran 6141 tests in 1117.872s, FAILED (failures=212, skipped=5, errors=0)**. Xác minh độc lập lượt cron 15:00: 212 FAIL header = 212 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, 0 AssertionError loại khác — toàn Godot-absent. So với gate N2261 (Ran 6137, failures=211): +4 tests / +1 failure đúng bằng 4 test mới của slice; +1 failure là test reference-graph của chính N2262 (Godot-absent trong môi trường gate, cùng mẫu N2256–N2261); 3 test còn lại của slice (registration, input evidence, state) không nằm trong FAIL list → pass trong gate. Slice commit `f97d8dc0`, push origin main `965c45c4..f97d8dc0`. BÀI HỌC: gate launch từ exec background thường chết khi lượt cron kết thúc — phải dùng `setsid nohup ... &` để detach.
- `git diff --check` — **OK lượt cron 14:45** (sạch). javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover đang chạy trước khi launch.
- Không cần fix harness: targeted chạy lần đầu đã 4/4 OK (proof seed frame rotation 270.0 trực tiếp trước tick; không đụng game). Key `rotate_sync_negative_half_rounds_up` (-45 → 0) pin đúng arc round half-up, khác Godot `round()` half away from zero.

## Tiếp theo: N2263 (sau N2262)

- HeatReq fold :538-540 (`if(heatRequirement > 0){ heatReq = calculateHeat(sideHeat); }`) — cần pin `heatRequirement` + `sideHeat` của Turret + duo có override không, và `calculateHeat` (Turret.java, cần đọc body).

## Deferred (không đổi)

- control() setters arm logicControlTime = 120 (:384/:394, LAccess shoot/shootp + targetPos/targetPosition).
- HeatReq fold :538-540 (cần sideHeat + calculateHeat).
- Unit maxHealth/health re-sync từ tile() (cần live tile_health — frame chưa có key health; không có damage model cho turret building).
- Unit world position từ set(tile) (cần quyết định representation world-position; frame làm việc theo cell).
- Counter queuedBullets cross-tick + delayed bullets (Time.run) cho turret firstShotDelay > 0.
- effects/sound, findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
