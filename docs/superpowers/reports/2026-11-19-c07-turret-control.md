# Report — N2264 Turret control() setters (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~17:0x +07, lượt cron 17:00) — slice `64c41a11`, docs `aa47fa9e`, GOAL `a5d7a924`, status sẽ ghi sau. Targeted 4/4 + proof matches:true 13/13 + register --verify 27/27 + gate Ran 6149, failures=214 toàn Godot-absent (đã xác minh độc lập).

- N2263 DONE + PUSHED (origin/main b1e981fc, slice 7a5bbc88) — đã xác minh đầu lượt cron 17:00: git log 5 commit khớp, HEAD == origin/main == b1e981fc, worktree chỉ còn diff N2264 + noise *.gd.uid (không stage).

## Slice (scope đã khóa)

- 1 pure function `source_turret_control_state(control_type, p1, p2, p3, unit_is_player, unit_is_null, logic_control_time, logic_shooting, target_pos, target_is_posc, tilesize)` (11 params, 4 keys: logic_control_time, logic_shooting, target_pos, target_position_deferred) trong `SourceTurretBuildState.gd:533`, KHÔNG driver tick (event-driven, tiền lệ N2248).
- Java: `TurretBuild.control()` 2 overload (Turret.java:381-402): double overload :382-386 (`if(type == LAccess.shoot && !unit.isPlayer()){` / `targetPos.set(World.unconv((float)p1), World.unconv((float)p2));` / `logicControlTime = logicControlCooldown;` / `logicShooting = !Mathf.zero(p3);`) và Object overload :393-400 (`if(type == LAccess.shootp && (unit == null || !unit.isPlayer())){` / `logicControlTime = logicControlCooldown;` / `logicShooting = !Mathf.zero(p2);` / `if(p1 instanceof Posc pos){` / `targetPosition(pos);`). Cả hai đều gọi super.control sau đó — BuildingComp.control chỉ xử lý enabled/config (BuildingComp.java:2150-2161), no-op với shoot/shootp, chờ slice riêng.
- PIN Java: `public final static float logicControlCooldown = 60 * 2;` (Turret.java:38 → 120); `public float curRecoil, heat, logicControlTime = -1;` (:284); `public boolean logicShooting = false;` (:287); `public Vec2 targetPos = new Vec2();` (:289); `World.unconv` (World.java:170-172, `coord * tilesize`); `tilesize = 8` (Vars.java:135); `Mathf.zero` (arc Mathf.java:522-524, `|value| <= FLOAT_ROUNDING_ERROR`, 1e-6, :10); LAccess `shoot("x", "y", "shoot"),` / `shootp(true, "unit", "shoot"),` (LAccess.java:81-82).
- Pure function: shoot + non-player → target_pos = (p1*tilesize, p2*tilesize), timer = 120.0, logic_shooting = |p3| > 1e-6; shootp + (null hoặc non-player) → timer = 120.0, logic_shooting = |p2| > 1e-6, target_is_posc → target_position_deferred = true, target_pos giữ nguyên; type khác hoặc unit là player → trả mọi input nguyên vẹn, deferred false.
- Quyết định scope — targetPosition(pos) (:398, :453-471: hasAmmo/peekAmmo + Predict.intercept, accurateDelay/moveWhileCharging offset, predictTarget gating) KHÔNG làm trong N2264 (cần live ammo + prediction — own slice); shootp chỉ báo target_position_deferred. Super.control enabled/config (BuildingComp.java:2150-2161) chờ slice riêng. Control cho def khác ngoài duo chưa wire (pure function nhận params, không có driver tick vì chưa có logic executor).

## RED

- `python3 -m unittest tests.test_c07_turret_control` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260-N2263. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2264'` (ledger chưa có entry N2264); state test FAIL vì pure function `source_turret_control_state` chưa có; proof test FAIL vì `C07TurretControlProof.tscn` chưa tồn tại (Godot exit 1, `Cannot open file 'res://tools/runtime_proofs/C07TurretControlProof.tscn'`).

## GREEN (lượt cron 16:15; neighbours/wiring/gate lượt cron 17:00)

- Pure function + register script + proof `C07TurretControlProof` đã có; SSOT đúng kỳ vọng 11626/1714/1648/3087, defense 193/192; `git diff --check` OK.
- Targeted chạy lại lượt 16:21: **4 passed, 40 subtests, 16.16s**.
- Proof JSON `C07TurretControlProof.json` (đọc trực tiếp lượt 16:21): **matches:true, 13/13 true** (10 keys control + `registry_valid` + `one_headquarter_per_ssot`). Hiệu chỉnh: lượt 16:15 ghi "12/12" là SAI đếm — JSON có 13 key bool, tất cả true.
- Register `--verify`: **27/27 exprs present**.
- Không cần fix harness: targeted chạy lần đầu đã 4/4 OK (proof chỉ gọi direct pure-function; key control_shoot_flag_zero_epsilon pin p3 0.0000005 → false, 0.00001 → true đúng FLOAT_ROUNDING_ERROR 1e-6).
- Neighbours 28 module — **XANH, đã xác minh độc lập lượt cron 17:00: 112 passed in 388.69s** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2264-neighbours.log`).
- Wiring 9 module live-loop — **XANH, đã xác minh độc lập lượt cron 17:00: Ran 32 tests, OK (124.833s)** (log `n2264-wiring.log`).
- Gate (log `tools/mindustry_godot_transpiler/full-suite-n2264-gate.log`, chuỗi detached `n2264-chain-main.sh` PID 8903 relaunch từ main thread sau khi PID 8639 chết, launch 09:23:27Z, xong 09:50:36Z): **Ran 6149 trong 1112.693s, FAILED (failures=214, skipped=5, errors=0)** — sạch như kỳ vọng. Xác minh độc lập lượt cron 17:00: 214 FAIL = 214 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. So với gate N2263 (Ran 6145, failures=213): +4 tests / +1 failure đúng bằng 4 test mới của slice; +1 failure là test reference-graph của chính N2264 (Godot-absent trong môi trường gate, cùng mẫu N2256–N2263); 3 test còn lại của slice không nằm trong FAIL list → pass trong gate.
- javalang 0.13.0 + pytest 9.2.0 OK; port 7777 trống lúc kiểm tra lượt 16:45.

## Tiếp theo: N2265

- N2265 candidate — efficiency fold :676 (`efficiency *= Math.min(Math.max(heatReq / heatRequirement, cheating() ? 1f : 0f), maxHeatEfficiency);`, cần heatReq live từ N2263 + cheating helper N2099) — deferred lâu thứ hai sau control() setters (nay đã xong).
