# Handoff — N2278 Turret logicControlled() live derivation (C07) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-20 ~09:53 +07 GREEN, gate xong 10:37 +07, push lượt cron 10:45) — N2277 đã DONE + PUSHED (9391d5a1). Slice commit 7d2d024f, docs TBD, GOAL TBD, status TBD. Gate xác minh độc lập từ log full-suite-n2278-gate.log: Ran 6205 in 1200.625s, failures=228, skipped=5, errors=0 — 228 FAIL = 228 × `AssertionError: unexpectedly None`, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure so với gate N2277, đúng 4 test mới; +1 failure là test reference-graph của chính N2278, Godot-absent trong môi trường gate vì chain script reset PATH không gồm godot-bin). Targeted 8/8 (N2278 4/4 + N2251 4/4, 54 subtests, 29.62s re-run lượt 10:45, Godot trên PATH); register --verify 7/7; proof JSON matches:true 8/8 (5 semantic + matches + registry_valid + one_headquarter_per_ssot); SSOT đo từ đĩa 11654/1728/1662/3115; defense 205/204; neighbours 177 passed + 2 FAILED flake port-7777, re-run riêng lượt 10:45 8/8 (59 subtests, 34.15s, Godot trên PATH, 0 lỗi 7777); wiring 32/32 OK.

## Scope (đã khóa, xác minh từ đĩa — xem hidden_files/n2278-scope.md)

- Slice: Turret logicControlled() live derivation — `public boolean logicControlled(){ return logicControlTime > 0; }` (Turret.java:445-447), field `public float curRecoil, heat, logicControlTime = -1;` (:284, set to `logicControlCooldown` bởi control() setters :384/:394, N2264; decayed :534-536 bởi tick N2261).
- Consumers trong Java: validateTarget `return !Units.invalidateTarget(target, canHeal() ? Team.derelict : team, x, y) || controlled() || logicControlled();` (:631-633, N2251) và isShooting :492 (N2277).
- Bug: driver validate call đọc `bool(frame.get("logic_controlled", false))`, nhưng `frame["logic_controlled"]` KHÔNG được stamp ở đâu cả — luôn default false. Một duo logic-controlled (logic_control_time > 0) với target vốn invalid sẽ fail validation sai. Tick isShooting N2277 đã derive nó live inline (`float(frame.get("logic_control_time", -1.0)) > 0.0`); call validate được defer riêng thành slice này (handoff N2277).
- Pure function: `source_turret_logic_controlled_state(logic_control_time: float) -> Dictionary`, trả `{"logic_controlled": logic_control_time > 0.0}` — Java method nguyên văn, không bịa công thức. Placement: ngay TRƯỚC `source_turret_is_shooting_state` (:162), vì :492 isShooting tiêu thụ logicControlled().
- Driver tick placement: ngay TRƯỚC call validate (:1318-1319), trong duo branch: `var logic_controlled_state: Dictionary = source_turret_logic_controlled_state(float(frame.get("logic_control_time", -1.0)))` + `frame["logic_controlled"] = logic_controlled_state.get("logic_controlled", false)`. Đọc logic_control_time của tick TRƯỚC (tick decay N2261 chạy sau trong driver; thứ tự Java :491 validate trước :534-536 decay) — cùng precedent N2277 / N2265.
- Call validate KHÔNG đổi (vẫn đọc `bool(frame.get("logic_controlled", false))`, nay đã live) — nên test N2251 không cần đổi.
- Sửa fixture proof N2251 (in scope, cùng class với fix warmup của N2277): `C07ItemTurretValidateTargetProof.gd` frame 5 đặt `frames[5]["logic_controlled"] = true` — tick stamp mới sẽ ghi đè thành false (logic_control_time default -1.0). Đổi thành `frames[5]["logic_control_time"] = 120.0` (:138, + comment update). Phần direct-call của proof đó không đổi.
- New result-key symbol (không clash): `source_turret_logic_controlled_state_result.logic_controlled`.
- Proof keys (5 semantic + registry_valid + one_headquarter_per_ssot + matches = 8): logic_controlled_positive (trực tiếp: 120.0 → true), logic_controlled_zero (trực tiếp: 0.0 → false — Java `> 0`), logic_controlled_negative (trực tiếp: -1.0 → false, field default), logic_controlled_stamped_to_frame (driver: frame default sau một tick → key present, false; rồi logic_control_time 120.0 + tick → true), logic_controlled_driver_rescues_validate (driver: dead-Healthc target due east + logic_control_time 120.0 → target kept, has_target true, aim dest 90 — validate call thấy derivation live).
- SSOT baseline (đo từ đĩa 2026-11-20 ~09:53 +07): symbols 11653, Done 1727, contracts 1661, schemas 3113; defense slices 204, contracts 203. Sau GREEN kỳ vọng 11654/1728/1662/3115; defense 205/204.
- NOT this slice: `controlled()` live wiring (unit.isPlayer() — không có player unit trong port; vẫn default false); rewire tick isShooting N2277 để đọc key đã stamp (test của nó pin derivation inline; giá trị giống hệt — cùng expression, cùng logic_control_time tick trước, decay chạy sau); calculateHeat (BLOCKED — live entity scan); findTarget (BLOCKED); shootp live wiring; các def ItemTurret khác ngoài duo; các arg khác của call validate N2251 (target_same_team_effective / target_health_valid / target_unit_targetable vẫn frame-stamped với vacuous defaults).
- Deferred sau slice này: calculateHeat live proximity scan vẫn BLOCKED; shootp live wiring; findTarget BLOCKED; các def ItemTurret khác ngoài duo; live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture); `controlled()` live wiring (cần player unit).

## GREEN (đã xong, lượt ~09:53 +07)

- Pure function `source_turret_logic_controlled_state` trong SourceTurretBuildState.gd:162 (1 param, 1 key logic_controlled) — ĐÃ CÓ sẵn uncommitted từ đầu lượt (scope đã khóa), worker kiểm tra lại khớp scope rồi giữ nguyên, không viết lại.
- Driver tick trong `source_turret_tick_buildings_state` (:1318-1319): gọi pure function với `float(frame.get("logic_control_time", -1.0))`, stamp frame["logic_controlled"], ngay TRƯỚC call validate.
- Proof C07TurretLogicControlledProof.gd + .tscn (5 keys trên). Proof JSON đọc trực tiếp: matches:true, 8/8 true (5 semantic + matches + registry_valid + one_headquarter_per_ssot), GREEN ~09:53 +07 (trong lần chạy targeted với Godot trên PATH).
- `python3 register_c07_turret_logic_controlled.py --verify`: **7/7 exprs present**, exit 0. Register chạy xong (SSOT như trên).
- Targeted: `python3 -m pytest tests/test_c07_turret_logic_controlled.py tests/test_c07_item_turret_validate_target.py -q` (từ tools/mindustry_godot_transpiler, Godot trên PATH): **8 passed, 54 subtests passed in 29.62s** (re-run lượt 10:45; lần đầu lượt này chạy thiếu Godot trên PATH nên 2 test reference-graph fail — đúng mẫu Godot-absent, không phải regression; chạy lại với Godot trên PATH thì xanh).
- Neighbours: 177 passed + 2 FAILED (test_c07_point_defense_turret_should_consume_cooling + test_c07_point_defense_turret_spawn_team_stamp, 610.53s) — cả 2 đã xác minh là flake port-7777, KHÔNG phải regression: cả 2 proof đều in `"matches":true` với đủ semantic keys, ERROR duy nhất là `[MCP Runtime] Failed to start server on port 7777: 22`. Re-run riêng lượt 10:45 (port 7777 trống, Godot trên PATH): **8 passed, 59 subtests passed in 34.15s**, log `hidden_files/n2278-neighbours-rerun.log`, 0 lỗi 7777.
- Wiring: 32/32 OK (log `hidden_files/n2278-wiring.log` trong goals hidden_files).
- Gate: Ran 6205 in 1200.625s, failures=228, skipped=5 — toàn Godot-absent (xác minh độc lập, xem Status); log `tools/mindustry_godot_transpiler/full-suite-n2278-gate.log` (chain log `hidden_files/n2278-chain.log`, GATE-START 03:16:30Z rồi 03:17:37Z — lần chạy trọn vẹn là lần 2, GATE-EXIT 1 03:37:38Z; 03:17:37Z → 03:37:38Z ≈ 1201s khớp 1200.625s).
- `git diff --check` OK.
- File thay đổi (CHƯA commit): SourceTurretBuildState.gd (M), 6 SSOT JSON (M: registry, ledger, contracts, schema + defense_slices + defense_api_contracts), C07ItemTurretValidateTargetProof.gd (M, fixture frame 5), proof .gd/.tscn + register + test (mới). Proof .json không stage (theo quy tắc). Không stage *.gd.uid, gate/neighbours/wiring log, chain script.
- SSOT đo từ đĩa sau GREEN: symbols 11654 (+1), Done 1728 (+1), contracts 1662 (+1), schemas 3115 (+2) → 11654/1728/1662/3115; defense slices 205, contracts 204. Đúng kỳ vọng scope.

## Tiếp theo (sau khi neighbours re-run + wiring xong)

1. Commit + push N2278 lượt cron 10:45 (slice + docs + GOAL + status + hashes, theo mẫu N2277) — gate đã xanh-theo-mẫu, wiring/targeted/neighbours-re-run đã xác minh lại độc lập.
2. Chọn slice tiếp theo từ deferred list (calculateHeat vẫn BLOCKED; shootp live wiring; findTarget vẫn BLOCKED; `controlled()` live wiring cần player unit; các def ItemTurret khác ngoài duo).

## Deferred (không đổi, trừ validate call nay đọc logic_controlled live)

- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Turret control() shootp live wiring — logic executor chưa có trong driver.
- findTarget (BLOCKED); các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
- `controlled()` live wiring (needs a player unit).
