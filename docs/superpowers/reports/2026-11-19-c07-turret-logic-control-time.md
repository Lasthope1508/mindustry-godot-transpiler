# Report — N2261 Turret logicControlTime decay (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~14:2x +07, lượt cron 14:15) — slice `4cebe133`, docs `ea480790`, GOAL `ce60f3e7`, status TBD (pushed; origin/main advances with this status commit). Targeted 4/4 + proof matches:true 11/11 + register --verify 9/9 + gate Ran 6137, failures=211 toàn Godot-absent (đã xác minh độc lập).

- N2260 DONE + PUSHED (origin/main 458bf37c, slice 6e5acc29) — đã xác minh đầu lượt: git log 5 commit gần nhất khớp, HEAD == origin/main == 458bf37c, worktree sạch ngoại trừ diff N2261 + noise *.gd.uid (không stage).

## Slice (scope đã khóa)

- 1 pure function `source_turret_logic_control_time_state(logic_control_time: float, delta: float) -> Dictionary` trong `SourceTurretBuildState.gd:441` + 1 driver tick nhánh duo, SAU tick recoilOffset N2258, TRƯỚC aim call (Java order :534-536 sau recoilOffset :532, trước turnToTarget :595-596).
- Java: `if(logicControlTime > 0){ logicControlTime -= Time.delta; }` (Turret.java:534-536); field `public float curRecoil, heat, logicControlTime = -1;` (:284); reader `logicControlled()` = `return logicControlTime > 0;` (:445-447); setters `logicControlTime = logicControlCooldown;` (:384/:394, trong control(LAccess.shoot...) và control(LAccess.shootp...)); `public final static float logicControlCooldown = 60 * 2;` (:38) = 120 ticks.
- Pure function trả 1 result symbol: `logic_control_time` — guard `> 0.0` thì trừ delta, không thì giữ nguyên; KHÔNG clamp — timer 0.001 với delta 1/60 về âm (-0.0156...), đúng Java, tick sau guard giữ nguyên.
- Driver tick (SourceTurretBuildState.gd:708-709): `source_turret_logic_control_time_state(float(frame.get("logic_control_time", -1.0)), seconds)` rồi stamp `frame["logic_control_time"]`. Default -1.0 = field default (:284). Tick chạy TRƯỚC aim nên isShooting gate (:492, đọc logicControlled()) thấy timer tươi.
- Quyết định scope — control() setters (:384/:394, arm timer = 120) KHÔNG làm trong N2261: decay chỉ đọc frame value, không bao giờ arm; setters chờ slice riêng (cần LAccess shoot/shootp + targetPos/targetPosition). Rotate sync :542-545 là N2262. HeatReq fold :538-540 chờ slice riêng (cần sideHeat + calculateHeat).

## RED (lượt cron 13:30)

- `python3 -m unittest tests.test_c07_turret_logic_control_time`: **Ran 4, FAILED (failures=2, errors=2)** — registration + input-evidence ERROR (ledger N2261 chưa tồn tại → KeyError N2261), state test FAIL vì pure function chưa có, proof test FAIL vì `C07TurretLogicControlTimeProof.tscn` chưa tồn tại. Đỏ đúng kỳ vọng, đúng mẫu RED của N2259/N2260.

## GREEN (lượt cron 13:45–13:58 — code đã có trên đĩa; lượt 13:58 xác minh độc lập; gate lượt 14:15)

- Pure function + driver tick + register script + proof `C07TurretLogicControlTimeProof` đã có; SSOT đúng kỳ vọng 11619/1711/1645/3081, defense 190/189; `git diff --check` OK.
- Targeted chạy lại: **Ran 4, OK (14.32s, 24 subtests)**.
- Proof JSON `C07TurretLogicControlTimeProof.json` (đọc trực tiếp lượt 13:58): **matches:true, 11/11 true** (8 keys logicControlTime decay + `registry_valid` + `one_headquarter_per_ssot`).
- Register `--verify`: **9/9 exprs present**.
- Không cần fix harness: targeted chạy lần đầu đã 4/4 OK (proof arm timer 120.0 trực tiếp lên frame trước tick; không đụng game).
- Neighbours 25 module — **XANH, đã xác minh độc lập lượt cron 13:58: 100 passed, 347.19s, exit 0** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2261-neighbours.log`).
- Wiring 9 module live-loop — **XANH, đã xác minh độc lập lượt cron 13:58: Ran 32 tests, OK, 122.511s, exit 0** (log `n2261-wiring.log`).
- Gate (log `tools/mindustry_godot_transpiler/full-suite-n2261-gate.log`, PID 6293, launch ~13:59 +07 lượt cron 13:58, xong ~14:18 +07): **Ran 6137 trong 1105.144s, FAILED (failures=211, skipped=5, errors=0)** — sạch như kỳ vọng. Xác minh độc lập lượt 14:15: 211 FAIL = 211 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. So với gate N2260 (Ran 6133, failures=210): +4 tests / +1 failure đúng bằng 4 test mới của slice; +1 failure là test reference-graph của chính N2261 (Godot-absent trong môi trường gate, cùng mẫu N2256–N2260). Lượt 14:15 KHÔNG launch gate mới (đã có discover PID 6293 đang chạy — guard ps); chỉ chờ nó xong rồi xác minh.
- javalang 0.13.0 + pytest 9.2.0 OK; port 7777 trống lúc launch gate.

## Tiếp theo: N2262

- N2262 candidate — Rotate sync :542-545 (`if(rotate){ ((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4); }`) — cần pin `rotate` default của Turret + duo có override không, và key frame `building_rotation` (chưa có).
