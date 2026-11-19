# Handoff — N2266 Turret targetPosition(pos) call (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~18:5x +07, lượt cron 18:45) — slice `a421f48a`, docs `357eca9b`, GOAL `94288cc6`, status `ac0475d8`. Targeted 4/4 + proof matches:true 12/12 + register --verify 36/36 + gate Ran 6157, failures=216 toàn Godot-absent (đã xác minh độc lập).

- N2265 DONE + PUSHED (origin/main c8a5ba83, slice 92a9a639) — đã xác minh đầu lượt: git log 5 commit khớp, HEAD == origin/main == c8a5ba83, worktree sạch ngoại trừ noise *.gd.uid (không stage) + các full-suite-*.log cũ chưa track (không stage). javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover / chain đang chạy.

## Scope (đã khóa, xác minh từ đĩa)

- Slice targetPosition(pos) call cho duo: `TurretBuild.targetPosition(Posc pos)` (Turret.java:453-471), method mà control() shootp overload gọi (`targetPosition(pos);`, :398, N2264 đã defer — shootp arm chỉ báo target_position_deferred):
  - `if(!hasAmmo() || pos == null) return;` (:454)
  - `var offset = Tmp.v1.setZero();` (:456)
  - `if(accurateDelay && !moveWhileCharging && pos instanceof Hitboxc h){ offset.set(h.deltaX(), h.deltaY()).scl(shoot.firstShotDelay / Time.delta); }` (:460-462)
  - `if(predictTarget && bullet.speed >= 0.01f){ targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed)); }else{ targetPos.set(pos); }` (:464-468)
  - `if(targetPos.isZero()){ targetPos.set(pos); }` (:470-472)
- Intercept là Position overload (Predict.java: `public static Vec2 intercept(Position src, Position dst, float offsetx, float offsety, float v){`): displacement per-frame của target (Hitboxc deltaX/deltaY) là velocity, turret building không phải Hitboxc nên không trừ shooter velocity, float overload chia displacement cho Time.delta (`dstvx /= Time.delta;`) rồi giải quadratic lấy root dương nhỏ nhất, không có root thì trả current position. Float overload: `public static Vec2 intercept(float srcx, float srcy, float dstx, float dsty, float dstvx, float dstvy, float v){` (Predict.java).
- PIN duo: `accurateDelay = true` (Turret.java:78), `moveWhileCharging = true` (:80) → offset branch OFF cho duo; `predictTarget = true` (:105); copper `new BasicBulletType(2.5f, 9)` (Blocks.java:3260, speed 2.5, damage 9) → gate `bullet.speed >= 0.01f` on, intercept chạy; `shoot = new ShootAlternate(3.5f);` (Blocks.java:3299) với `public float firstShotDelay = 0;` (ShootPattern.java:11) → offset duo = 0 cả khi branch on. `hasAmmo()` (:698-...: ammo.size > 0 và peek entry ≥ ammoPerShot hoặc cheating, có canConsume) / `peekAmmo()` (:693-695: null khi ammo rỗng, không thì ammo.peek().type()).
- 1 pure function `source_turret_target_position_control_state(has_ammo, pos, pos_is_hitboxc, delta_x, delta_y, accurate_delay, move_while_charging, first_shot_delay, time_delta, predict_target, bullet_speed, turret_x, turret_y, target_pos)` (14 params, 1 key: target_pos) trong `SourceTurretBuildState.gd` (sau `source_turret_efficiency_multiplier_state`, + preload `source_predict_state` như SourceTurretCombatState). KHÔNG driver tick — control() là event-driven (tiền lệ N2264/N2248): logic executor chưa có trong driver, pure function gọi direct trong proof, chờ executor slice wire arm :398; frame không có Posc coords nên không tick nào resolve được target_position_deferred. N2122 `source_turret_target_position_state` (combat state) đã làm intercept branch cho live aim path với game/target dicts — slice này là C07 control-path pure function với scalar frame-level.
- 9 proof keys đã pin trong test: tgt_pos_no_ammo_keeps, tgt_pos_null_pos_keeps, tgt_pos_no_predict_uses_pos, tgt_pos_slow_bullet_uses_pos, tgt_pos_intercept_leads, tgt_pos_zero_intercept_falls_back, tgt_pos_accurate_delay_offset, tgt_pos_duo_offset_zero, tgt_pos_duo_live. Intercept leads: turret (0,0), pos (100,0) moving +2/tick, copper 2.5 → a=-2.25, b=400, c=10000, disc=250000, t=200 → (500,0). Offset: FSD 30 + MWC false → offset (60,0) → intercept từ (160,0), t=320 → (800,0); MWC true + FSD 30 → vẫn (500,0). Zero fallback: pos (0,0) → intercept (0,0) → fallback về pos.
- SSOT kỳ vọng sau GREEN: symbols +1, Done +1, contracts +1, schema +2 → 11628/1716/1650/3091; defense slices 194 → 195, contracts 193 → 194.

## RED (lượt này, chạy + xác minh độc lập)

- `python3 register_c07_turret_target_position.py --verify`: **36/36 exprs present**.
- `python3 -m unittest tests.test_c07_turret_target_position` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260-N2265. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2266'` (ledger chưa có entry N2266); state test FAIL vì pure function `source_turret_target_position_control_state` chưa có; proof test FAIL vì `C07TurretTargetPositionControlProof.tscn` chưa tồn tại.
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover đang chạy.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_target_position.py` + register `tools/mindustry_godot_transpiler/register_c07_turret_target_position.py`. Không stage/commit gì ở bước RED.

## GREEN (lượt này, chạy + xác minh độc lập)

- Viết pure function `source_turret_target_position_control_state` (SourceTurretBuildState.gd, sau `source_turret_efficiency_multiplier_state`, 14 params, 1 key target_pos) + preload `source_predict_state`.
- Viết proof `C07TurretTargetPositionControlProof` (.gd + .tscn, mirror `C07TurretEfficiencyMultiplierProof`, 9 keys).
- `python3 register_c07_turret_target_position.py`: SSOT 11628/1716/1650/3091 (đúng kỳ vọng); `--verify` 36/36.
- Targeted `python3 -m unittest tests.test_c07_turret_target_position`: **Ran 4, OK** (15.535s, proof matches:true, 9 semantic / 12 tổng). Port 7777 trống trước proof. Proof JSON đọc trực tiếp: matches:true, 12/12 true.
- `git diff --check` OK.
- Chain neighbours (30 modules incl. N2266) → wiring (9 modules, 32 tests) → full gate đã launch từ main thread (PID 8488, setsid nohup `n2266-chain-main.sh`): `hidden_files/n2266-chain.log`, `n2266-neighbours.log`, `n2266-wiring.log`, `tools/mindustry_godot_transpiler/full-suite-n2266-gate.log`. Ps guard trước launch: không có unittest discover / chain nào đang chạy. Launch exec báo output-drain timeout (tiến trình nền giữ stdout mở) nhưng chain đã chạy: ps thấy PID 8488 bash chain + PID 8490 pytest neighbours + Godot proof — đúng mẫu launch N2265, KHÔNG kill.
- File thay đổi (chưa commit): SourceTurretBuildState.gd (M), 6 SSOT JSON (M: registry, ledger, contracts, schema + defense_slices + defense_api_contracts shards), test + register + proof .gd/.tscn + handoff này (mới, chưa track). Không stage/commit gì ở bước GREEN.

## VERIFY CHAIN (xong lượt cron 18:45 — xác minh độc lập)

- Gate xong: chain log GATE-EXIT 1 11:48:59Z; không còn unittest discover đang chạy. Gate Ran 6157 trong 1134.937s, failures=216, skipped=5, errors=0 — xác minh độc lập: 216 FAIL = 216 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure so với gate N2265, đúng 4 test mới; +1 failure là test reference-graph của chính N2266).
- Targeted chạy lại: Ran 4, OK (16.502s); proof JSON đọc trực tiếp: matches:true, 12/12 true; register --verify 36/36; SSOT từ đĩa 11628/1716/1650/3091, defense slices 195 / contracts 194; neighbours log 120 passed in 410.67s; wiring log Ran 32, OK (122.576s); `git diff --check` OK.
- Slice commit `a421f48a` (11 files). Còn lại: docs commit (report + handoff này + spec) → GOAL commit → status commit → hashes commit → push lên origin main (fork). KHÔNG push trước khi gate xác minh xong — đã xác minh xong.

## Tiếp theo: N2267 (sau khi N2266 push)

- N2267 candidate — BuildingComp super.control() enabled/config cases (BuildingComp.java:2150-2161), deferred còn lại sau targetPosition: control() setters chỉ model shoot/shootp, các LAccess khác (enabled/config) chờ slice riêng — own slice, theo đúng quy trình RED → GREEN → neighbours/wiring/gate → proof → report/handoff/spec → push. Hoặc calculateHeat live proximity scan nếu unblock được (vẫn BLOCKED — live entity scan).

## Deferred (không đổi, trừ targetPosition đang làm)

- BuildingComp super.control() enabled/config cases (BuildingComp.java:2150-2161) — chờ slice riêng.
- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Efficiency fold cho def khác ngoài duo (afflict 20f / malign 144f là PowerTurret, consumption branch riêng).
- Turret control() shootp live wiring — logic executor chưa có trong driver, không driver tick nào resolve target_position_deferred; pure function N2266 chờ executor slice gọi từ arm :398.
- Unit maxHealth/health re-sync từ tile() (cần live tile_health — frame chưa có key health; không có damage model cho turret building).
- Unit world position từ set(tile) (cần quyết định representation world-position; frame làm việc theo cell).
- Counter queuedBullets cross-tick + delayed bullets (Time.run) cho turret firstShotDelay > 0.
- effects/sound, findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
