# Handoff — N2261 Turret logicControlTime decay (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~14:2x +07, lượt cron 14:15) — slice commit 4cebe133, docs ea480790, GOAL ce60f3e7, status TBD. Targeted 4/4 + proof matches:true 11/11 + register --verify 9/9 + gate Ran 6137, failures=211 toàn Godot-absent (đã xác minh độc lập).

- N2260 DONE + PUSHED (origin/main 458bf37c, slice 6e5acc29) — đã xác minh đầu lượt: git log 5 commit khớp, HEAD == origin/main == 458bf37c, worktree sạch ngoại trừ noise *.gd.uid (không stage). VM restart ~13:22 đã wipe javalang + pytest; worker lượt 13:15 cài lại 0.13.0/9.2.0, lượt này xác minh import OK.

## Scope (đã khóa, xác minh từ đĩa)

- Slice logicControlTime decay cho duo: driver C07 mới (`SourceTurretBuildState.source_turret_tick_buildings_state`, nhánh duo) chưa bao giờ decay timer logic-control — `logicControlTime` là field của TurretBuild (`public float curRecoil, heat, logicControlTime = -1;`, Turret.java:284), và updateTile() decay nó mỗi tick (`if(logicControlTime > 0){ logicControlTime -= Time.delta; }`, Turret.java:534-536), sau recoilOffset :532, trước heatReq :538-540 và rotate sync :542-545. N2261 là tick live trên driver mới, KHÔNG làm lại path legacy (không có path legacy cho logicControlTime decay).
- 1 pure function `source_turret_logic_control_time_state(logic_control_time: float, delta: float) -> Dictionary` trong `SourceTurretBuildState.gd` (file turret chung — updateTile() là TurretBuild, không phải ItemTurret-only) + 1 driver tick trong nhánh duo, SAU tick recoilOffset N2258, TRƯỚC aim call (Java order :532 offset, :534-536 decay, :595-596 turnToTarget, :601/:609 updateShooting).
- PIN Java: `if(logicControlTime > 0){` / `logicControlTime -= Time.delta;` (Turret.java:534-536); `public float curRecoil, heat, logicControlTime = -1;` (:284); `logicControlled()` = `return logicControlTime > 0;` (:445-447); setters `logicControlTime = logicControlCooldown;` (:384/:394, trong control(LAccess.shoot...) và control(LAccess.shootp...)); `public final static float logicControlCooldown = 60 * 2;` (:38) = 120 ticks. Thứ tự Java trong updateTile (:490-545) đã pin: :502-515 warmup → :519 decay curRecoil → :520-525 multi-recoil decay → :526 heat → :527 charge → :529-531 unit sync → :532 recoilOffset → **:534-536 logicControlTime decay** → :538-540 heatReq → :542-545 rotate sync → :595-596 turnToTarget → :601/:609 updateShooting → :733 shoot gate.
- Pure function: guard `logic_control_time > 0.0` thì trừ delta, không thì giữ nguyên; KHÔNG clamp — timer 0.001 với delta 1/60 về âm (-0.0156...), đúng Java, tick sau guard giữ nguyên. Trả 1 result symbol `logic_control_time`. `logicControlled()` đọc `> 0` trên giá trị đã decay — proof key 5-6 pin quan hệ này qua giá trị trả về, không cần pure function riêng (reader là method khác, có thể thành slice riêng sau nếu cần).
- Driver tick: `var logic_control_time_state: Dictionary = source_turret_logic_control_time_state(float(frame.get("logic_control_time", -1.0)), seconds)` rồi stamp `frame["logic_control_time"]`. Default -1.0 = field default (:284). Tick chạy TRƯỚC aim nên isShooting gate (:492, đọc logicControlled()) thấy timer tươi.
- 8 proof keys đã pin trong test: logic_control_time_decays_when_positive, logic_control_time_unchanged_when_negative, logic_control_time_unchanged_when_zero, logic_control_time_can_go_negative, logic_controlled_true_while_positive, logic_controlled_false_when_expired, logic_control_time_stamped_to_frame, logic_control_time_duo_live.
- SSOT kỳ vọng sau GREEN: symbols +1, Done +1, contracts +1, schema +2 → 11619/1711/1645/3081 (schema đếm schema object: input + result = 2/slice, giống N2259/N2260); defense shard slices 189 → 190, contracts 188 → 189.
- Quyết định scope — control() setters (:384/:394, arm timer = 120) KHÔNG làm trong N2261: decay chỉ đọc frame value, không bao giờ arm; setters chờ slice riêng (cần LAccess shoot/shootp + targetPos/targetPosition). Rotate sync :542-545 là N2262. HeatReq fold :538-540 chờ slice riêng (cần sideHeat + calculateHeat).

## RED (lượt này, chạy + xác minh độc lập)

- `python3 -m unittest tests.test_c07_turret_logic_control_time` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2259/N2260. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2261'` (ledger chưa có entry N2261); state test FAIL vì pure function `source_turret_logic_control_time_state` chưa có; proof test FAIL vì `C07TurretLogicControlTimeProof.tscn` chưa tồn tại (Godot exit 1, `Cannot open file 'res://tools/runtime_proofs/C07TurretLogicControlTimeProof.tscn'`).
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; không có unittest discover đang chạy.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_logic_control_time.py` + handoff này (untracked). Không stage/commit gì ở bước RED.

## GREEN (lượt cron 13:45, đã chạy + đã xác minh)

- Pure function `source_turret_logic_control_time_state` (SourceTurretBuildState.gd, sau `source_turret_unit_sync_state`) + driver tick trong nhánh duo SAU tick recoilOffset N2258, TRƯỚC aim call — đúng scope. Java lines đã xác minh lại từ đĩa trước khi viết: Turret.java:534-536 / :284 / :38 / :384/:394 / :445-447.
- Register script `register_c07_turret_logic_control_time.py`: **--verify 9/9 exprs present**; đã chạy — SSOT **11619/1711/1645/3081** (symbols +1, Done +1, contracts +1, schema +2 đúng kỳ vọng); defense slices 190, contracts 189.
- Proof `C07TurretLogicControlTimeProof` (.gd + .tscn): targeted **Ran 4, OK (15.674s)**; JSON đã đọc trực tiếp: **matches:true, 8/8 semantic true + registry_valid + one_headquarter_per_ssot**.
- Neighbours (25 module: 12 PointDefenseTurret + 3 ItemTurret + 9 turret slices warmup/recoil_heat/multi_recoil/multi_recoil_stamp/shoot_stamp/recoil_offset/charge/unit_sync/logic_control_time + test_turret_live_loop, kỳ vọng 100 tests) — **XANH: 100 passed trong 347.19s, exit 0** (log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2261-neighbours.log`). Wiring (9 module live-loop) — **XANH: Ran 32, OK trong 122.511s, exit 0** (log `n2261-wiring.log`). `git diff --check` OK.
- Không cần fix harness: targeted chạy lần đầu đã 4/4 OK (proof arm timer 120.0 trực tiếp lên frame trước tick; không đụng game).

## GREEN (gate xong — lượt cron 14:15, đã xác minh độc lập)

- [x] Gate (log full-suite-n2261-gate.log, PID 6293, launch ~13:59 +07 lượt cron 13:58, xong ~14:18 +07): **Ran 6137 trong 1105.144s, FAILED (failures=211, skipped=5, errors=0)** — sạch như kỳ vọng. Xác minh độc lập: 211 FAIL = 211 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. So với gate N2260 (Ran 6133, failures=210): +4 tests / +1 failure đúng bằng 4 test mới của slice; +1 failure là chính test reference-graph của N2261 (`test_reference_graph_and_actual_c07_turret_logic_control_time`, `shutil.which('godot')` → None trong môi trường gate — cùng mẫu Godot-absent như mọi slice N2256–N2260, proof đã xanh riêng ở targeted). Lượt 14:15 KHÔNG launch gate mới (đã có discover PID 6293 đang chạy — guard ps); chỉ chờ nó xong rồi xác minh.
- [x] Report/handoff/spec/GOAL hoàn thiện → commit + push (KHÔNG stage *.gd.uid / logs / project.godot / proof .json) — gate đã xanh.

## Tiếp theo: N2262 (sau N2261)

- Rotate sync :542-545 (`if(rotate){ ((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4); }`) — cần pin `rotate` default của Turret + duo có override không, và key frame `building_rotation` (chưa có).

## Deferred (không đổi)

- control() setters arm logicControlTime = 120 (:384/:394, LAccess shoot/shootp + targetPos/targetPosition).
- HeatReq fold :538-540 (cần sideHeat + calculateHeat).
- Unit maxHealth/health re-sync từ tile() (cần live tile_health — frame chưa có key health; không có damage model cho turret building).
- Unit world position từ set(tile) (cần quyết định representation world-position; frame làm việc theo cell).
- Counter queuedBullets cross-tick + delayed bullets (Time.run) cho turret firstShotDelay > 0.
- effects/sound, findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
