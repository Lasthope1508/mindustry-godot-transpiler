# Report — N2266 Turret targetPosition(pos) call (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~18:5x +07, lượt cron 18:45) — slice `a421f48a`, docs `357eca9b`, GOAL `94288cc6`. Targeted 4/4 + proof matches:true 12/12 + register --verify 36/36 + gate Ran 6157, failures=216 toàn Godot-absent (đã xác minh độc lập).

- N2265 DONE + PUSHED (origin/main c8a5ba83, slice 92a9a639) — đã xác minh đầu lượt cron 18:15: git log 5 commit khớp, HEAD == origin/main == c8a5ba83, worktree sạch ngoại trừ noise *.gd.uid (không stage) + các full-suite-*.log cũ chưa track (không stage).

## Slice (scope đã khóa)

- 1 pure function `source_turret_target_position_control_state(has_ammo, pos, pos_is_hitboxc, delta_x, delta_y, accurate_delay, move_while_charging, first_shot_delay, time_delta, predict_target, bullet_speed, turret_x, turret_y, target_pos)` (14 params, 1 key: target_pos) trong `SourceTurretBuildState.gd:627` + preload `source_predict_state` (`SourceTurretBuildState.gd:4`). KHÔNG driver tick — control() là event-driven (tiền lệ N2264/N2248): logic executor chưa có trong driver, pure function gọi direct trong proof, chờ executor slice wire arm :398; frame không có Posc coords nên không tick nào resolve được target_position_deferred.
- Java: `TurretBuild.targetPosition(Posc pos)` (Turret.java:453-471), method mà control() shootp overload gọi (`targetPosition(pos);`, :398, N2264 đã defer): `if(!hasAmmo() || pos == null) return;` (:454); `var offset = Tmp.v1.setZero();` (:456); `if(accurateDelay && !moveWhileCharging && pos instanceof Hitboxc h){ offset.set(h.deltaX(), h.deltaY()).scl(shoot.firstShotDelay / Time.delta); }` (:460-462); `if(predictTarget && bullet.speed >= 0.01f){ targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed)); }else{ targetPos.set(pos); }` (:464-468); `if(targetPos.isZero()){ targetPos.set(pos); }` (:470-472).
- Intercept là Position overload (Predict.java: `public static Vec2 intercept(Position src, Position dst, float offsetx, float offsety, float v){`): displacement per-frame của target (Hitboxc deltaX/deltaY) là velocity, turret building không phải Hitboxc nên không trừ shooter velocity, float overload chia displacement cho Time.delta rồi giải quadratic lấy root dương nhỏ nhất, không có root thì trả current position.
- PIN duo: `accurateDelay = true` (Turret.java:78), `moveWhileCharging = true` (:80) → offset branch OFF cho duo; `predictTarget = true` (:105); copper `new BasicBulletType(2.5f, 9)` (Blocks.java:3260, speed 2.5, damage 9) → gate `bullet.speed >= 0.01f` on, intercept chạy; `shoot = new ShootAlternate(3.5f);` (Blocks.java:3299) với `public float firstShotDelay = 0;` (ShootPattern.java:11) → offset duo = 0 cả khi branch on. `hasAmmo()` (:698-...: ammo.size > 0 và peek entry ≥ ammoPerShot hoặc cheating, có canConsume) / `peekAmmo()` (:693-695: null khi ammo rỗng, không thì ammo.peek().type()).
- 9 proof keys: tgt_pos_no_ammo_keeps, tgt_pos_null_pos_keeps, tgt_pos_no_predict_uses_pos, tgt_pos_slow_bullet_uses_pos, tgt_pos_intercept_leads, tgt_pos_zero_intercept_falls_back, tgt_pos_accurate_delay_offset, tgt_pos_duo_offset_zero, tgt_pos_duo_live. Intercept leads: turret (0,0), pos (100,0) moving +2/tick, copper 2.5 → a=-2.25, b=400, c=10000, disc=250000, t=200 → (500,0). Offset: FSD 30 + MWC false → offset (60,0) → intercept từ (160,0), t=320 → (800,0); MWC true + FSD 30 → vẫn (500,0). Zero fallback: pos (0,0) → intercept (0,0) → fallback về pos.
- N2122 `source_turret_target_position_state` (combat state) đã làm intercept branch cho live aim path với game/target dicts — slice này là C07 control-path pure function với scalar frame-level.

## RED (lượt cron 18:15)

- `python3 register_c07_turret_target_position.py --verify`: **36/36 exprs present**.
- `python3 -m unittest tests.test_c07_turret_target_position` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260-N2265. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2266'` (ledger chưa có entry N2266); state test FAIL vì pure function `source_turret_target_position_control_state` chưa có; proof test FAIL vì `C07TurretTargetPositionControlProof.tscn` chưa tồn tại.
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover đang chạy.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_target_position.py` + register `tools/mindustry_godot_transpiler/register_c07_turret_target_position.py`. Không stage/commit gì ở bước RED.

## GREEN (lượt cron 18:15; neighbours/wiring/gate + xác minh độc lập lượt cron 18:45)

- Pure function + register script + proof `C07TurretTargetPositionControlProof` đã có; SSOT đúng kỳ vọng 11628/1716/1650/3091 (xác minh từ đĩa lượt 18:45: symbols 11628, ledger slices 1716, contracts 1650, schemas 3091, defense slices 195 / contracts 194); `git diff --check` OK.
- Targeted chạy lại lượt 18:45: **Ran 4, OK (16.502s)**, port 7777 trống trước proof.
- Proof JSON `C07TurretTargetPositionControlProof.json` (đọc trực tiếp lượt 18:45): **matches:true, 12/12 true** (9 keys tgt_pos + `registry_valid` + `one_headquarter_per_ssot`).
- Register `--verify` chạy lại lượt 18:45: **36/36 exprs present**.
- Neighbours 30 module — **XANH, đã xác minh độc lập lượt cron 18:45: 120 passed in 410.67s** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2266-neighbours.log`).
- Wiring 9 module live-loop — **XANH, đã xác minh độc lập lượt cron 18:45: Ran 32 tests, OK (122.576s)** (log `n2266-wiring.log`).
- Gate (log `tools/mindustry_godot_transpiler/full-suite-n2266-gate.log`, chuỗi `n2266-chain-main.sh` PID 8488 launch từ main thread, GATE-START 11:30:02Z, GATE-EXIT 1 11:48:59Z): **Ran 6157 trong 1134.937s, FAILED (failures=216, skipped=5, errors=0)** — sạch như kỳ vọng. Xác minh độc lập lượt cron 18:45: 216 FAIL = 216 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. So với gate N2265 (Ran 6153, failures=215): +4 tests / +1 failure đúng bằng 4 test mới của slice; +1 failure là test reference-graph của chính N2266 (Godot-absent trong môi trường gate, cùng mẫu N2256–N2265); 3 test còn lại của slice không nằm trong FAIL list → pass trong gate.
- javalang 0.13.0 + pytest 9.2.0 OK; port 7777 trống lúc kiểm tra lượt 18:45.

## Tiếp theo: N2267

- N2267 candidate — BuildingComp super.control() enabled/config cases (BuildingComp.java:2150-2161), deferred còn lại sau targetPosition: control() setters chỉ model shoot/shootp, các LAccess khác (enabled/config) chờ slice riêng — own slice, theo đúng quy trình RED → GREEN → neighbours/wiring/gate → proof → report/handoff/spec → push. Hoặc calculateHeat live proximity scan nếu unblock được (vẫn BLOCKED — live entity scan).
