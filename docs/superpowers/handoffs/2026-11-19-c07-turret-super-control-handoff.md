# Handoff — N2267 BuildingComp super.control() enabled/config (C07, duo) [GREEN, gate đã xác minh, chờ commit/push]

## Status: DONE + PUSHED (2026-11-19 ~20:0x +07, lượt cron 20:00) — slice `5295a7ec`, docs `53986237`, GOAL `936a663e`. Targeted 4/4 + proof matches:true 12/12 + register --verify 22/22 + gate Ran 6161, failures=217 toàn Godot-absent (đã xác minh độc lập).

## RELAUNCH #2 (lượt cron 19:30 +07, xác minh độc lập)

- Chain relaunch #1 (PID 15011) CHẾT cùng VM restart: uptime chỉ 6 phút lúc 12:30Z (boot ~12:24Z), neighbours log dừng ở 87% (test_c07_turret_heat_req.py, 2 dots rồi cắt). Không OOM (dmesg không kiểm tra lần này — restart là nguyên nhân rõ ràng), worktree nguyên vẹn (git status: đúng các file N2267 chưa commit, handoff còn nguyên).
- VM restart xóa javalang + pytest như mọi lần — đã cài lại: javalang 0.13.0 + pytest 9.2.0 (requirements.txt + pytest riêng), import OK.
- GREEN xác minh lại sau restart: targeted `python3 -m unittest tests.test_c07_turret_super_control` **Ran 4, OK** (18.603s), register `--verify` 22/22. Port 7777 trống, không có unittest/pytest nào chạy trước launch (ps guard riêng).
- Relaunch #2 12:31:13Z bằng `setsid bash n2267-chain-main.sh` (exec background, PID 2679 launcher → chain bash PID 2680, PPID 1, PGID/SID 2680, pytest neighbours PID 2683). Xác minh độc lập: chain.log có NEIGHBOURS-START 12:31:13Z, neighbours log đã chạy module 1 (12:31:21Z) — chain SỐNG.
- Kỳ vọng: neighbours (~7p) → wiring (~2p) → gate (~19p), xong ~20:00 +07. Kỳ vọng gate Ran 6161, failures=217 toàn Godot-absent.
- Lượt sau: xác minh độc lập gate log rồi mới report/handoff/spec + commit + push N2267 (5 commit theo mẫu N2266). KHÔNG push trước khi gate xác minh xong.

## RELAUNCH (lượt cron 19:15 +07, xác minh độc lập)

- Chain đầu PID 13370 CHẾT: neighbours log dừng 12:06:50Z (~33s sau start, module 3, ~6%) — đúng mẫu N2266 (worker chain chết ~1 phút dù handoff báo launch từ main thread). Không OOM (dmesg sạch), không VM restart (uptime 1:53, boot ~17:22 +07), javalang 0.13.0 + pytest 9.2.0 còn nguyên, port 7777 trống.
- GREEN xác minh lại trước relaunch: targeted `python3 -m unittest tests.test_c07_turret_super_control` **Ran 4, OK** (16.066s), register `--verify` 22/22.
- Relaunch 12:17:25Z bằng `setsid bash n2267-chain-main.sh` (exec background, trả về sau 6ms, PID 15011). Xác minh độc lập sau 60s (exec riêng): PID 15011 PPID 1, PGID/SID 15011, pytest 15013 đang chạy (CPU 5.8%), neighbours log đã tới 12% (vượt điểm chết 6%), mtime 12:18:26 — chain SỐNG.
- Kỳ vọng: neighbours (~7p) → wiring (~2p) → gate (~19p), xong ~19:45 +07. Kỳ vọng gate Ran 6161, failures=217 toàn Godot-absent.
- Lượt sau: xác minh độc lập gate log rồi mới report/handoff/spec + commit + push N2267 (5 commit theo mẫu N2266). KHÔNG push trước khi gate xác minh xong.

- N2266 DONE + PUSHED (origin/main 2adf8849, slice a421f48a) — đã xác minh đầu lượt: git log 5 commit khớp, HEAD == origin/main == 2adf8849, worktree sạch ngoại trừ noise *.gd.uid (không stage) + các full-suite-*.log cũ chưa track (không stage). javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover / chain đang chạy (ps guard riêng trước launch).

## Scope (đã khóa, xác minh từ đĩa)

- Slice BuildingComp super.control() enabled/config cho duo: TurretBuild.control() kết thúc cả hai overload bằng `super.control(type, p1, p2, p3, p4);` (Turret.java:388/:402), nên các case BuildingComp chạy cho mọi lệnh logic control mà turret không tự xử lý.
  - Double overload (BuildingComp.java:2150-2155): `public void control(LAccess type, double p1, double p2, double p3, double p4){` / `if(type == LAccess.enabled){` / `enabled = !Mathf.zero((float)p1);` — field `transient boolean enabled = true;` (:77), flag mà shouldConsume / efficiency folds đọc (frame["enabled"], default true).
  - Object overload (:2157-2162): `public void control(LAccess type, Object p1, double p2, double p3, double p4){` / `//don't execute configure instructions that copy logic building configures; this can cause extreme lag` / `if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){` / `//change config only if it's new` / `configured(null, p1);`
  - LAccess: `enabled("to"), //"to" is standard for single parameter access` (LAccess.java:80), `config(true, "to"),` (:83) — enabled đi double overload, config đi Object overload. Mathf.zero: `return Math.abs(value) <= FLOAT_ROUNDING_ERROR;` (arc Mathf.java:522-524) với `public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits` (:10) → p1 0.0000005 đọc zero (disable), p1 0.00001 đọc non-zero (enable).
  - `logicConfigurable`: `public boolean logicConfigurable = false;` (Block.java:270), chỉ thành true ở init() (:1463-1466) khi có configuration key là UnlockableContent — duo KHÔNG đăng ký configuration nào (không có `config(` trong ItemTurret.java, Turret.java, ReloadTurret.java, BaseTurret.java), nên guard config không bao giờ chạy cho duo, configured() không bao giờ được gọi.
- 1 pure function `source_turret_super_control_state(control_type, p1, enabled, logic_configurable, p1_is_logic_build)` (5 params, 2 keys: enabled, config_applied) trong `SourceTurretBuildState.gd` (sau `source_turret_target_position_control_state`, trước `source_turret_tick_buildings_state`). "enabled" → enabled = !zero(p1); "config" → config_applied = logic_configurable && !p1_is_logic_build; type khác → giữ nguyên cả hai. KHÔNG driver tick — control() event-driven (tiền lệ N2248/N2264/N2266), logic executor chưa có trong driver, proof gọi direct.
- 9 proof keys đã pin trong test: super_enabled_disables, super_enabled_enables, super_enabled_flag_zero_epsilon, super_enabled_flag_nonzero, super_enabled_other_type_noop, super_config_applies_when_configurable, super_config_blocked_when_not_configurable, super_config_blocked_when_logic_build, super_duo_live. Duo live: duo đã place (cell 28,21, seed position như N2211) với pins enabled default true + logicConfigurable false → enabled call p1=0 → false, config call → config_applied false.
- SSOT sau GREEN (đo từ đĩa): symbols 11630 (+2), Done 1717 (+1, ledger slices 1717 all done), contracts 1651 (+1), schemas 3093 (+2) → 11630/1717/1651/3093. Shard: comp_slices 556, comp_api_contracts 460 (slice này đi shard comp vì java_source là BuildingComp.java, KHÔNG đi defense shard — defense vẫn 195/194).

## RED (lượt này, chạy + xác minh độc lập)

- `python3 register_c07_turret_super_control.py --verify`: **22/22 exprs present**.
- `python3 -m unittest tests.test_c07_turret_super_control` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2260-N2266. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2267'` (ledger chưa có entry N2267); state test FAIL vì pure function `source_turret_super_control_state` chưa có; proof test FAIL vì `C07TurretSuperControlProof.tscn` chưa tồn tại.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_super_control.py` + register `tools/mindustry_godot_transpiler/register_c07_turret_super_control.py`. Không stage/commit gì ở bước RED.

## GREEN (lượt này, chạy + xác minh độc lập)

- Viết pure function `source_turret_super_control_state` (SourceTurretBuildState.gd, sau `source_turret_target_position_control_state`, 5 params, 2 keys enabled/config_applied).
- Viết proof `C07TurretSuperControlProof` (.gd + .tscn, mirror `C07TurretTargetPositionControlProof`, 9 keys).
- `python3 register_c07_turret_super_control.py`: SSOT 11630/1717/1651/3093 (đúng kỳ vọng +2/+1/+1/+2); `--verify` 22/22.
- Targeted `python3 -m unittest tests.test_c07_turret_super_control`: **Ran 4, OK** (14.826s, proof matches:true, 9 semantic / 12 tổng). Port 7777 trống trước proof. Proof JSON đọc trực tiếp: matches:true, 12/12 true. LƯU Ý: lần chạy GREEN đầu tiên FAIL 1 (state test: chuỗi `enabled("to"), //"to" is standard...` bị ngắt dòng trong comment GDScript nên assertIn không thấy) — sửa bằng cách gộp thành 1 dòng comment, chạy lại 4/4 OK. Bài học: mọi chuỗi assertIn phải nằm nguyên trên 1 dòng trong file .gd.
- `git diff --check` OK.
- Chain neighbours (31 modules incl. N2267) → wiring (9 modules, 32 tests) → full gate đã launch từ main thread (PID 13370, setsid nohup `n2267-chain-main.sh`): `hidden_files/n2267-chain.log`, `n2267-neighbours.log`, `n2267-wiring.log`, `tools/mindustry_godot_transpiler/full-suite-n2267-gate.log`. Ps guard trước launch: không có unittest discover / chain nào đang chạy. Launch exec báo output-drain timeout (tiến trình nền giữ stdout mở) nhưng chain đã chạy: ps thấy PID 13370 bash chain + PID 13372 pytest neighbours + Godot proof — đúng mẫu launch N2265/N2266, KHÔNG kill.
- File thay đổi (chưa commit): SourceTurretBuildState.gd (M), 7 SSOT JSON (M: registry, ledger, contracts, schema + comp_slices + comp_api_contracts shards + audit report), test + register + proof .gd/.tscn + handoff này (mới, chưa track). Không stage/commit gì ở bước GREEN.

## VERIFY CHAIN (lượt cron 20:00 +07, xác minh độc lập — GATE XONG)

- Chain relaunch #2 (setsid 12:31:13Z, chain bash PID 2680, PPID 1) sống tới cuối: NEIGHBOURS-EXIT 0 12:39:22Z → WIRING-EXIT 0 12:41:26Z → GATE-START 12:41:26Z → GATE-EXIT 1 13:00:12Z (log `hidden_files/n2267-chain.log`).
- Neighbours 31 module: **124 passed in 430.63s** (`n2267-neighbours.log`). Wiring 9 module: **Ran 32 tests, OK (123.677s)** (`n2267-wiring.log`).
- Gate (log `tools/mindustry_godot_transpiler/full-suite-n2267-gate.log`): **Ran 6161 trong 1124.604s, FAILED (failures=217, skipped=5, errors=0)**. Xác minh độc lập: 217 FAIL = 217 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. +4 tests / +1 failure so với gate N2266 (Ran 6157, failures=216), đúng 4 test mới; +1 failure là test reference-graph của chính N2267.
- Targeted chạy lại lượt 20:00: **Ran 4, OK (16.934s)**. Register `--verify` chạy lại: **22/22**. Proof JSON đọc trực tiếp: **matches:true, 12/12 true**. SSOT đo từ đĩa: 11630/1717/1651/3093, comp 556/460. `git diff --check` OK. Port 7777 trống.
- Lượt này: report/handoff/spec + commit + push N2267 (5 commit theo mẫu N2266: slice + docs + GOAL + status + hashes). KHÔNG push trước khi gate xác minh xong — đã xác minh xong.

## Tiếp theo: N2268 (sau khi N2267 push)

- N2268 candidate — BuildingComp configured() dispatch effect (BuildingComp.java:1414-1432): `configured(null, p1)` handler dispatch theo type (Item/Block/Liquid/UnitType → block.configurations handler; Building → copy config đệ quy) — own slice, theo đúng quy trình RED → GREEN → neighbours/wiring/gate → proof → report/handoff/spec → push. Hoặc calculateHeat live proximity scan nếu unblock được (vẫn BLOCKED — live entity scan).

## Deferred (không đổi, trừ super.control đang làm)

- BuildingComp configured() dispatch effect (BuildingComp.java:1414-1432) — chờ slice riêng (N2267 chỉ báo config_applied, chưa model dispatch; duo không có configurations nên không ảnh hưởng duo).
- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Efficiency fold cho def khác ngoài duo (afflict 20f / malign 144f là PowerTurret, consumption branch riêng).
- Turret control() shootp live wiring — logic executor chưa có trong driver, không driver tick nào resolve target_position_deferred; pure function N2266 chờ executor slice gọi từ arm :398.
- Unit maxHealth/health re-sync từ tile() (cần live tile_health — frame chưa có key health; không có damage model cho turret building).
- Unit world position từ set(tile) (cần quyết định representation world-position; frame làm việc theo cell).
- Counter queuedBullets cross-tick + delayed bullets (Time.run) cho turret firstShotDelay > 0.
- effects/sound, findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
