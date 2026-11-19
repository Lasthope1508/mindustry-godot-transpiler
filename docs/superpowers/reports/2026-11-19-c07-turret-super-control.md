# Report — N2267 BuildingComp super.control() enabled/config (C07, duo) [GREEN, gate đã xác minh, chờ commit/push]

## Status: DONE + PUSHED (2026-11-19 ~20:0x +07, lượt cron 20:00) — slice `5295a7ec`, docs `53986237`, GOAL `936a663e`. Targeted 4/4 + proof matches:true 12/12 + register --verify 22/22 + gate Ran 6161, failures=217 toàn Godot-absent (đã xác minh độc lập).

- N2266 DONE + PUSHED (origin/main 2adf8849, slice a421f48a) — đã xác minh đầu lượt cron 19:15: git log 5 commit khớp, HEAD == origin/main == 2adf8849, worktree sạch ngoại trừ noise *.gd.uid (không stage) + các full-suite-*.log cũ chưa track (không stage).

## Slice (scope đã khóa)

- 1 pure function `source_turret_super_control_state(control_type, p1, enabled, logic_configurable, p1_is_logic_build)` (5 params, 2 keys: enabled, config_applied) trong `SourceTurretBuildState.gd` (sau `source_turret_target_position_control_state`, trước `source_turret_tick_buildings_state`). "enabled" → enabled = !zero(p1); "config" → config_applied = logic_configurable && !p1_is_logic_build; type khác → giữ nguyên cả hai. KHÔNG driver tick — control() event-driven (tiền lệ N2248/N2264/N2266), logic executor chưa có trong driver, proof gọi direct.
- Java: `TurretBuild.control()` kết thúc cả hai overload bằng `super.control(type, p1, p2, p3, p4);` (Turret.java:388/:402), nên các case BuildingComp chạy cho mọi lệnh logic control mà turret không tự xử lý. Double overload (BuildingComp.java:2150-2155): `public void control(LAccess type, double p1, double p2, double p3, double p4){` / `if(type == LAccess.enabled){` / `enabled = !Mathf.zero((float)p1);` — field `transient boolean enabled = true;` (:77), flag mà shouldConsume / efficiency folds đọc (frame["enabled"], default true). Object overload (:2157-2162): `public void control(LAccess type, Object p1, double p2, double p3, double p4){` / `//don't execute configure instructions that copy logic building configures; this can cause extreme lag` / `if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){` / `//change config only if it's new` / `configured(null, p1);`
- LAccess: `enabled("to"), //"to" is standard for single parameter access` (LAccess.java:80), `config(true, "to"),` (:83) — enabled đi double overload, config đi Object overload. Mathf.zero: `return Math.abs(value) <= FLOAT_ROUNDING_ERROR;` (arc Mathf.java:522-524) với `public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits` (:10) → p1 0.0000005 đọc zero (disable), p1 0.00001 đọc non-zero (enable).
- `logicConfigurable`: `public boolean logicConfigurable = false;` (Block.java:270), chỉ thành true ở init() (:1463-1466) khi có configuration key là UnlockableContent — duo KHÔNG đăng ký configuration nào (không có `config(` trong ItemTurret.java, Turret.java, ReloadTurret.java, BaseTurret.java), nên guard config không bao giờ chạy cho duo, configured() không bao giờ được gọi.
- 9 proof keys: super_enabled_disables, super_enabled_enables, super_enabled_flag_zero_epsilon, super_enabled_flag_nonzero, super_enabled_other_type_noop, super_config_applies_when_configurable, super_config_blocked_when_not_configurable, super_config_blocked_when_logic_build, super_duo_live. Duo live: duo đã place (cell 28,21, seed position như N2211) với pins enabled default true + logicConfigurable false → enabled call p1=0 → false, config call → config_applied false.
- SSOT sau GREEN (đo từ đĩa): symbols 11630 (+2), Done 1717 (+1, ledger slices 1717 all done), contracts 1651 (+1), schemas 3093 (+2) → 11630/1717/1651/3093. Shard: comp_slices 556, comp_api_contracts 460 (slice này đi shard comp vì java_source là BuildingComp.java, KHÔNG đi defense shard — defense vẫn 195/194).

## RED (lượt cron 19:15)

- `python3 register_c07_turret_super_control.py --verify`: **22/22 exprs present**.
- `python3 -m unittest tests.test_c07_turret_super_control` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260-N2266. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2267'` (ledger chưa có entry N2267); state test FAIL vì pure function `source_turret_super_control_state` chưa có; proof test FAIL vì `C07TurretSuperControlProof.tscn` chưa tồn tại.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_super_control.py` + register `tools/mindustry_godot_transpiler/register_c07_turret_super_control.py`. Không stage/commit gì ở bước RED.

## GREEN (lượt cron 19:15; neighbours/wiring/gate + xác minh độc lập lượt cron 20:00)

- Pure function + register script + proof `C07TurretSuperControlProof` đã có; SSOT đúng kỳ vọng 11630/1717/1651/3093 (xác minh từ đĩa lượt 20:00: registry symbols 11630, ledger slices 1717, contracts 1651, schemas 3093, comp_slices 556 / comp_api_contracts 460); `git diff --check` OK.
- Targeted chạy lại lượt 20:00: **Ran 4, OK (16.934s)**, port 7777 trống trước proof.
- Proof JSON `C07TurretSuperControlProof.json` (đọc trực tiếp lượt 20:00): **matches:true, 12/12 true** (9 keys super_* + `registry_valid` + `one_headquarter_per_ssot`).
- Register `--verify` chạy lại lượt 20:00: **22/22 exprs present**.
- Chain chết 2 lần trước khi xong (xem handoff): chain đầu PID 13370 chết ở neighbours ~6%; relaunch #1 PID 15011 chết cùng VM restart (uptime 6 phút lúc 12:30Z, neighbours dừng 87%); relaunch #2 setsid 12:31:13Z (chain bash PID 2680, PPID 1) sống tới cuối.
- Neighbours 31 module — **XANH, đã xác minh độc lập lượt cron 20:00: 124 passed in 430.63s** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2267-neighbours.log`).
- Wiring 9 module live-loop — **XANH, đã xác minh độc lập lượt cron 20:00: Ran 32 tests, OK (123.677s)** (log `n2267-wiring.log`).
- Gate (log `tools/mindustry_godot_transpiler/full-suite-n2267-gate.log`, chuỗi `n2267-chain-main.sh` relaunch #2, GATE-START 12:41:26Z, GATE-EXIT 1 13:00:12Z): **Ran 6161 trong 1124.604s, FAILED (failures=217, skipped=5, errors=0)** — sạch như kỳ vọng. Xác minh độc lập lượt cron 20:00: 217 FAIL = 217 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. So với gate N2266 (Ran 6157, failures=216): +4 tests / +1 failure đúng bằng 4 test mới của slice; +1 failure là test reference-graph của chính N2267 (Godot-absent trong môi trường gate, cùng mẫu N2256–N2266); 3 test còn lại của slice không nằm trong FAIL list → pass trong gate.
- javalang 0.13.0 + pytest 9.2.0 OK (cài lại sau VM restart lượt 19:30); port 7777 trống lúc kiểm tra lượt 20:00.

## Tiếp theo: N2268

- N2268 candidate — BuildingComp configured() dispatch effect (BuildingComp.java:1414-1432): `configured(null, p1)` handler dispatch theo type (Item/Block/Liquid/UnitType → block.configurations handler; Building → copy config đệ quy) — own slice, theo đúng quy trình RED → GREEN → neighbours/wiring/gate → proof → report/handoff/spec → push. Hoặc calculateHeat live proximity scan nếu unblock được (vẫn BLOCKED — live entity scan).
