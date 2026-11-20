# Handoff — N2279 Turret activationTimer decay (C07) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-20 ~11:2x +07 GREEN, gate xong 11:45 +07, push lượt cron 11:45) — N2278 đã DONE + PUSHED (7df37242). Slice commit 9bfee770, docs 23a02e7b, GOAL cf2f4b52, status TBD. Gate xác minh độc lập từ log full-suite-n2279-gate.log: Ran 6209 in 1177.217s, failures=229, skipped=5, errors=0 — 229 FAIL = 229 × `AssertionError: unexpectedly None`, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure so với gate N2278, đúng 4 test mới; +1 failure là test reference-graph của chính N2279, Godot-absent trong môi trường gate vì chain script reset PATH không gồm godot-bin). Targeted 4/4 (19 subtests, 15.02s re-run lượt 11:18, Godot trên PATH); register --verify 9/9; proof JSON matches:true 8/8 (5 semantic + matches + registry_valid + one_headquarter_per_ssot); SSOT đo từ đĩa 11656/1729/1663/3117; defense 206/205; neighbours 183 passed (594.13s); wiring 32 test: batch đầu 29/32 + 3 flake port-7777, re-run riêng 11/11 OK → thực chất 32/32.

## Scope (đã khóa, xác minh từ đĩa — xem hidden_files/n2279-scope.md)

- Slice: Turret activationTimer decay — `if(activationTimer > 0){ activationTimer -= Time.delta; return; }` (Turret.java:561-564), dòng cuối cùng chưa wire trong updateTile :490-615 của duo mà có live input (delta) và field default xác định.
- Field `public float activationTimer = 0;` (BaseTurret.java:115), set bằng activationTime trong `placed()` (`activationTimer = activationTime;`, :119-120). `public float activationTime = 0f;` (BaseTurret.java:27, class default).
- Duo KHÔNG override activationTime (grep Blocks.java duo block 3257-3331: không có hit) — và KHÔNG def turret nào trong Blocks.java set activationTime > 0 (grep toàn Blocks.java: 0 hit). Nên activation_timer của duo LUÔN là 0.0 và gate :561-564 không bao giờ fire cho duo — cùng precedent vacuous-guard như N2270 (heat fold, guard off) và N2263 (heatReq fold, guard off): tick vẫn stamp key để frame mirror TurretBuild fields.
- `status()` dùng cùng clause `activationTimer <= 0` (BaseTurret.java:144) — đó là nguồn của key thứ hai.
- Pure function: `source_turret_activation_timer_state(activation_timer: float, delta: float) -> Dictionary`, trả `{"activation_timer": ..., "activation_timer_elapsed": ...}` — `activation_timer = activation_timer - delta if activation_timer > 0.0 else activation_timer` (Java :561-562 verbatim, không clamp); `activation_timer_elapsed = activation_timer <= 0.0` — verdict của gate :561-564, đánh giá trên INPUT timer (Java return trước khi chạy phần còn lại khi input > 0, kể cả khi decay vượt qua 0 trong tick này). Tên key tránh clash với `isActive()` (:448-450). Placement: ngay SAU `source_turret_rotate_sync_state` (Java :542-545 rotate sync → :561-564 activation gate).
- Driver tick placement: trong duo branch, giữa rotate sync tick và aim call (đúng thứ tự Java :542-545 → :561-564 → :566+): `source_turret_activation_timer_state(float(frame.get("activation_timer", 0.0)), seconds)` + stamp cả hai key. Default 0.0 = field default (BaseTurret.java:115).
- Early-return skip của aim/shoot half KHÔNG wire trong slice này: gate không bao giờ fire cho duo (activationTime 0 cho mọi def); restructure khối aim (~70 dòng) cho một guard không bao giờ fire là churn. DEFER: "early-return skip khi activation_timer > 0 — vacuous cho mọi def hiện tại; cần def với activationTime > 0 mới quan sát được".
- Proof keys (5 semantic + registry_valid + one_headquarter_per_ssot + matches = 8): activation_timer_decays_when_positive (direct: 120.0, delta 1/60 → 120 - 1/60), activation_timer_unchanged_at_zero (direct: 0.0 → 0.0), activation_timer_elapsed_at_zero (direct: 0.0 → elapsed true), activation_timer_not_elapsed_when_positive (direct: 120.0 → elapsed false), activation_timer_stamped_to_frame (driver: frame default → key present, 0.0, elapsed true; set 120.0 + tick → ~119.983, elapsed false).
- New result-key symbols (2): `source_turret_activation_timer_state_result.activation_timer`, `source_turret_activation_timer_state_result.activation_timer_elapsed`. Expected SSOT sau GREEN: 11656/1729/1663/3117 (+2/+1/+1/+2); defense slices 205 → 206, contracts 204 → 205.
- Register script `register_c07_turret_activation_timer.py` mirror N2278, import DEFERRED từ `register_c07_turret_logic_controlled`. Test file `tests/test_c07_turret_activation_timer.py` mirror N2278 (4 tests). EXACT_EXPRS (5, đều verbatim trong upstream): `if(activationTimer > 0){`, `activationTimer -= Time.delta;`, `public float activationTimer = 0;`, `activationTimer = activationTime;`, `public float activationTime = 0f;` — hai expr sau nằm trong BaseTurret.java nên SLICE_SOURCES gồm cả Turret.java và BaseTurret.java; register --verify kỳ vọng 9/9 (5 exact + 2 input + 2 output).
- SSOT baseline (đo từ đĩa 2026-11-20 ~11:2x +07): symbols 11654, Done 1728, contracts 1662, schemas 3115; defense slices 205, contracts 204. Sau GREEN: 11656/1729/1663/3117; defense 206/205.
- NOT this slice: isActive() (`(target != null || wasShooting) && enabled && activationTimer <= 0`, :448-450) — ứng viên N2280: nay activation_timer đã được stamp nên clause cuối có live input; các clause còn lại (has_target/was_shooting/enabled) đều đã live trên frame. Chỉ LaserTurret tiêu thụ isActive() trong Java, duo không có consumer — stamp-only như N2274–N2276. Early-return skip khi activation_timer > 0 (xem trên). shootp live wiring (cần logic executor); calculateHeat (BLOCKED); findTarget (BLOCKED); các def ItemTurret khác ngoài duo (epic nhiều slice); controlled() (cần player unit); coolant/suppression/targets live list (BLOCKED).
- Deferred sau slice này: calculateHeat live proximity scan vẫn BLOCKED; shootp live wiring; findTarget BLOCKED; các def ItemTurret khác ngoài duo; live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture); `controlled()` live wiring (cần player unit); isActive() derivation (ứng viên N2280); activation early-return skip (vacuous cho mọi def hiện tại).

## GREEN (đã xong, lượt ~11:2x +07)

- Pure function `source_turret_activation_timer_state` trong SourceTurretBuildState.gd:618 (2 params, 2 keys) — ĐÃ CÓ sẵn uncommitted từ đầu lượt (scope đã khóa), main thread kiểm tra lại khớp scope rồi giữ nguyên, không viết lại.
- Driver tick trong `source_turret_tick_buildings_state` (:1585-1587): gọi pure function với `float(frame.get("activation_timer", 0.0))`, stamp frame["activation_timer"] và frame["activation_timer_elapsed"], giữa rotate sync tick và aim call.
- Proof C07TurretActivationTimerProof.gd + .tscn (5 keys trên). Proof JSON đọc trực tiếp: matches:true, 8/8 true (5 semantic + matches + registry_valid + one_headquarter_per_ssot), GREEN ~11:2x +07 (trong lần chạy targeted với Godot trên PATH).
- `python3 register_c07_turret_activation_timer.py --verify`: **9/9 exprs present**, exit 0. Register chạy xong (SSOT như trên).
- Targeted: `python3 -m pytest tests/test_c07_turret_activation_timer.py -q` (từ tools/mindustry_godot_transpiler, Godot trên PATH): **4 passed, 19 subtests passed in 15.02s** (re-run lượt 11:18).
- Neighbours: **183 passed in 594.13s** (log `hidden_files/n2279-neighbours.log`, 0 FAILED/ERROR).
- Wiring: batch đầu 29/32 (3 FAILED: battery_power_status, battery_placement, adjacent_factory) — cả 3 đã xác minh là flake port-7777 (proof matches:true, ERROR duy nhất `[MCP Runtime] Failed to start server on port 7777: 22`); re-run riêng 3 module **11/11 OK** (log `hidden_files/n2279-wiring-rerun.log`) → thực chất 32/32.
- Gate: Ran 6209 in 1177.217s, failures=229, skipped=5 — toàn Godot-absent (xác minh độc lập, xem Status); log `tools/mindustry_godot_transpiler/full-suite-n2279-gate.log` (chain log `hidden_files/n2279-chain.log`, GATE-START 04:25:56Z, GATE-EXIT 1 04:45:35Z; script `hidden_files/n2279-gate-only-main.sh`, main thread).
- `git diff --check` OK.
- File thay đổi (CHƯA commit): SourceTurretBuildState.gd (M), 6 SSOT JSON (M: registry, ledger, contracts, schema + defense_slices + defense_api_contracts), proof .gd/.tscn + register + test (mới). Proof .json không stage (theo quy tắc). Không stage *.gd.uid, gate/neighbours/wiring log, chain script.
- SSOT đo từ đĩa sau GREEN: symbols 11656 (+2), Done 1729 (+1), contracts 1663 (+1), schemas 3117 (+2) → 11656/1729/1663/3117; defense slices 206, contracts 205. Đúng kỳ vọng scope.

## Tiếp theo (sau khi gate xong)

1. Commit + push N2279 lượt cron 11:45 (slice + docs + GOAL + status + hashes, theo mẫu N2278) — gate đã xanh-theo-mẫu, wiring/targeted/neighbours đã xác minh lại độc lập.
2. Chọn slice tiếp theo từ deferred list: N2280 — ứng viên isActive() derivation (Turret.java:448-450); calculateHeat vẫn BLOCKED; shootp live wiring; findTarget vẫn BLOCKED; `controlled()` live wiring cần player unit; các def ItemTurret khác ngoài duo (epic riêng).

## Deferred (không đổi, trừ activation_timer nay đã live)

- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Turret control() shootp live wiring — logic executor chưa có trong driver.
- findTarget (BLOCKED); các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
- `controlled()` live wiring (needs a player unit).
- isActive() derivation — ứng viên N2280 (nay có live activation_timer).
- Activation early-return skip — vacuous cho mọi def hiện tại.
