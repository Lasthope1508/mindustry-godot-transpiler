# Handoff — N2264 Turret control() setters (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~17:0x +07, lượt cron 17:00) — slice `64c41a11`, docs `aa47fa9e`, GOAL `a5d7a924`, status sẽ ghi sau. Targeted 4/4 OK + proof matches:true 13/13 + register --verify 27/27 + SSOT 11626/1714/1648/3087 + neighbours 112 passed + wiring 32 OK + gate Ran 6149, failures=214 toàn Godot-absent (đã xác minh độc lập).

- N2263 DONE + PUSHED (origin/main b1e981fc, slice 7a5bbc88) — đã xác minh đầu lượt: git log 5 commit khớp, HEAD == origin/main == b1e981fc, worktree sạch ngoại trừ noise *.gd.uid (không stage). javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover đang chạy; không có chain đang chạy.

## Scope (đã khóa, xác minh từ đĩa)

- Slice control() setters cho duo: driver C07 mới chưa bao giờ arm logicControlTime từ logic — tick decay N2261 chỉ đọc frame value, không arm. TurretBuild.control() có 2 overload (Turret.java:381-402): double overload :382-386 (`if(type == LAccess.shoot && !unit.isPlayer()){` / `targetPos.set(World.unconv((float)p1), World.unconv((float)p2));` / `logicControlTime = logicControlCooldown;` / `logicShooting = !Mathf.zero(p3);`) và Object overload :393-400 (`if(type == LAccess.shootp && (unit == null || !unit.isPlayer())){` / `logicControlTime = logicControlCooldown;` / `logicShooting = !Mathf.zero(p2);` / `if(p1 instanceof Posc pos){` / `targetPosition(pos);`). Cả hai đều gọi super.control sau đó — BuildingComp.control chỉ xử lý enabled/config (BuildingComp.java:2150-2161), no-op với shoot/shootp, chờ slice riêng.
- 1 pure function `source_turret_control_state(control_type, p1, p2, p3, unit_is_player, unit_is_null, logic_control_time, logic_shooting, target_pos, target_is_posc, tilesize)` (11 params, 4 keys: logic_control_time, logic_shooting, target_pos, target_position_deferred) trong `SourceTurretBuildState.gd` (sau `source_turret_heat_req_state`). KHÔNG có driver tick: control() là event-driven (logic executor gọi), driver chưa có logic executor — tiền lệ N2248.
- PIN Java: `public final static float logicControlCooldown = 60 * 2;` (Turret.java:38 → 120); `public float curRecoil, heat, logicControlTime = -1;` (:284); `public boolean logicShooting = false;` (:287); `public Vec2 targetPos = new Vec2();` (:289); `public static float unconv(float coord){` / `return coord * tilesize;` (World.java:170-172); `public static final int tilesize = 8;` (Vars.java:135); `public static boolean zero(float value){` / `return Math.abs(value) <= FLOAT_ROUNDING_ERROR;` (arc Mathf.java:522-524) với `public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits` (:10); LAccess `shoot("x", "y", "shoot"),` / `shootp(true, "unit", "shoot"),` (LAccess.java:81-82).
- Pure function: shoot + non-player → target_pos = (p1*tilesize, p2*tilesize), timer = 120.0, logic_shooting = |p3| > 1e-6; shootp + (null hoặc non-player) → timer = 120.0, logic_shooting = |p2| > 1e-6, target_is_posc → target_position_deferred = true, target_pos giữ nguyên; type khác hoặc unit là player → trả mọi input nguyên vẹn, deferred false.
- 10 proof keys đã pin trong test: control_shoot_arms_timer, control_shoot_sets_target_pos, control_shoot_sets_logic_shooting, control_shoot_flag_zero_epsilon, control_shoot_blocked_when_player, control_shootp_arms_timer, control_shootp_sets_logic_shooting, control_shootp_defers_target_position, control_shootp_blocked_when_player, control_other_type_noop.
- SSOT sau GREEN: symbols +4, Done +1, contracts +1, schema +2 → 11626/1714/1647→1648/3087 (xác minh từ đĩa); defense slices 192 → 193, contracts 191 → 192.
- Quyết định scope — targetPosition(pos) (:398, :453-471: hasAmmo/peekAmmo + Predict.intercept, accurateDelay/moveWhileCharging offset, predictTarget gating) KHÔNG làm trong N2264 (cần live ammo + prediction — own slice); shootp chỉ báo target_position_deferred. Super.control enabled/config (BuildingComp.java:2150-2161) chờ slice riêng. Control cho def khác ngoài duo chưa wire (pure function nhận params, không có driver tick vì chưa có logic executor).

## RED (lượt này, chạy + xác minh độc lập)

- `python3 -m unittest tests.test_c07_turret_control` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260-N2263. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2264'` (ledger chưa có entry N2264); state test FAIL vì pure function `source_turret_control_state` chưa có; proof test FAIL vì `C07TurretControlProof.tscn` chưa tồn tại (Godot exit 1, `Cannot open file 'res://tools/runtime_proofs/C07TurretControlProof.tscn'`).
- Register --verify: **27/27 exprs present** (12 exact + 11 input + 4 output java_expr).
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover đang chạy.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_control.py` + register `tools/mindustry_godot_transpiler/register_c07_turret_control.py`. Không stage/commit gì ở bước RED.

## GREEN (lượt này, đã chạy + đã xác minh)

- Pure function `source_turret_control_state` (SourceTurretBuildState.gd, sau `source_turret_heat_req_state`) + KHÔNG driver tick (event-driven, tiền lệ N2248) — đúng scope. Java lines đã xác minh lại từ đĩa trước khi viết: Turret.java:38/:284/:287/:289/:382-386/:393-400/:453-454 / World.java:170-172 / Vars.java:135 / LAccess.java:81-82 / arc Mathf.java:10/:522-524 / BuildingComp.java:2150-2161.
- Register script `register_c07_turret_control.py`: **--verify 27/27 exprs present**; đã chạy — SSOT **11626/1714/1648/3087** (symbols +4, Done +1, contracts +1, schema +2 đúng kỳ vọng); defense slices 193, contracts 192 (shard rebuild tự động).
- Proof `C07TurretControlProof` (.gd + .tscn): targeted **Ran 4, OK (15.546s)**; chạy lại lượt 16:21 **4 passed, 40 subtests, 16.16s**; JSON đã đọc trực tiếp từ Godot headless: **matches:true, 13/13 true** (10 semantic + `registry_valid` + `one_headquarter_per_ssot`). (Hiệu chỉnh: lượt 16:15 ghi "12/12" là SAI đếm — JSON có 13 key bool, tất cả true.)
- Không cần fix harness: targeted chạy lần đầu đã 4/4 OK (proof chỉ gọi direct pure-function; key control_shoot_flag_zero_epsilon pin p3 0.0000005 → false, 0.00001 → true đúng FLOAT_ROUNDING_ERROR 1e-6).
- `git diff --check` — **OK lượt này** (sạch).
- Chuỗi detached đã launch lượt này (script `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2264-chain-main.sh`, PID 8639, `setsid nohup ... &`, start 2026-11-19T09:21:02Z): neighbours (pytest 28 module — 27 module cũ + test_c07_turret_control.py, kỳ vọng 112 tests) → wiring (unittest 9 module, kỳ vọng 32 tests) → gate (`python3 -m unittest discover -s tests`, KHÔNG godot-bin trong PATH, log `tools/mindustry_godot_transpiler/full-suite-n2264-gate.log`, kỳ vọng Ran 6149, failures=214 toàn Godot-absent). Tiến độ trong `n2264-chain.log` + `n2264-neighbours.log` / `n2264-wiring.log`. LƯU Ý lượt sau: KHÔNG launch thêm gate khi chuỗi còn chạy — check `ps aux | grep n2264-chain` + chain log trước.

## Gate (DONE — đã xác minh độc lập lượt cron 17:00)

- Chuỗi detached n2264-chain-main.sh: lần launch đầu PID 8639 chết sau ~1 phút (neighbours log chỉ 460 byte, dừng ~11% — y hệt mẫu N2263); main thread relaunch PID 8903 (start 2026-11-19T09:23:27Z). Chain log: NEIGHBOURS-START 09:21:02Z + 09:23:27Z, NEIGHBOURS-EXIT 0 09:29:56Z; WIRING-START 09:29:56Z, WIRING-EXIT 0 09:32:01Z; GATE-START 09:32:01Z, GATE-EXIT 1 09:50:36Z (exit 1 là kỳ vọng vì failures Godot-absent).
- Neighbours 28 module — **XANH, đã xác minh độc lập: 112 passed in 388.69s** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2264-neighbours.log`).
- Wiring 9 module live-loop — **XANH, đã xác minh độc lập: Ran 32 tests, OK (124.833s)** (log `n2264-wiring.log`).
- Gate (log `tools/mindustry_godot_transpiler/full-suite-n2264-gate.log`, xong 09:50:36Z): **Ran 6149 trong 1112.693s, FAILED (failures=214, skipped=5, errors=0)** — sạch như kỳ vọng. Xác minh độc lập lượt cron 17:00: 214 FAIL header = 214 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. So với gate N2263 (Ran 6145, failures=213): +4 tests / +1 failure đúng bằng 4 test mới của slice; +1 failure là test reference-graph của chính N2264 (`test_reference_graph_and_actual_c07_turret_control`, Godot-absent trong môi trường gate, cùng mẫu N2256–N2263); 3 test còn lại của slice không nằm trong FAIL list → pass trong gate.
- javalang 0.13.0 + pytest 9.2.0 OK (không cài lại lượt này); port 7777 trống lúc kiểm tra lượt 16:45 (lượt 16:30 báo bận theo worker nhưng main thread kiểm tra lại thì FREE — Godot agent khác đã thoát).

## Tiếp theo: N2265 (sau khi N2264 push)

- N2265 candidate — efficiency fold :676 (`efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`, cần heatReq live từ N2263 + cheating helper N2099) — deferred lâu thứ hai sau control() setters (nay đã xong).

## Deferred (không đổi, trừ control() setters đã xong)

- targetPosition(pos) call (Turret.java:398, :453-471) — chờ slice riêng (hasAmmo/peekAmmo + Predict.intercept).
- BuildingComp super.control() enabled/config cases (BuildingComp.java:2150-2161) — chờ slice riêng.
- Efficiency fold :676 (cần heatReq live — đã có từ N2263 — + cheating helper N2099).
- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Unit maxHealth/health re-sync từ tile() (cần live tile_health — frame chưa có key health; không có damage model cho turret building).
- Unit world position từ set(tile) (cần quyết định representation world-position; frame làm việc theo cell).
- Counter queuedBullets cross-tick + delayed bullets (Time.run) cho turret firstShotDelay > 0.
- effects/sound, findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
