# Handoff — N2283 Turret sense() LAccess dispatch (C07) [DONE + PUSHED]

## Status: DONE + PUSHED (slice 8fda2dce, docs e0f1b578, GOAL 05482487; cập nhật lượt cron 17:45 +07 — gate main-thread xong GATE-EXIT 1 10:38:33Z, Ran 6225 trong 1167.030s, failures=233, skipped=5; xác minh độc lập: 233 FAIL = 233 × unexpectedly None, 0 KeyError, 0 return_schema_linkage, 0 ERROR, toàn Godot-absent). Neighbours XONG 199 passed, exit 0, 09:54:13–10:05:04Z; wiring XONG 32 tests OK, exit 0, 10:05:04–10:07:08Z. N2282 đã DONE + PUSHED (a7b1a81c). Slice commit 8fda2dce, docs e0f1b578, GOAL 05482487, status 6953ddbb. Targeted 4/4 (80 subtests, re-run độc lập lượt cron 17:45 +07, 16.22s, Godot trên PATH); register --verify 35/35 (re-run độc lập lượt cron 17:45 +07, exit 0); proof JSON matches:true 13/13 (đọc trực tiếp từ đĩa, xác minh độc lập); SSOT đo từ đĩa 11662/1733/1667/3125; `git diff --check` OK.

- Slice: Turret `sense()` dispatch — `public double sense(LAccess sensor){ return switch(sensor){ case ammo -> totalAmmo; case ammoCapacity -> maxAmmo; case rotation -> rotation; case shootX -> World.conv(targetPos.x); case shootY -> World.conv(targetPos.y); case shooting -> isShooting ? 1 : 0; case progress -> progress(); default -> super.sense(sensor); }; }` (Turret.java:405-419). Pure function `source_turret_sense_state` (SourceTurretBuildState.gd:224), KHÔNG có driver tick (sense là logic read, tiền lệ N2206/N2208/N2223).
- Targeted re-run độc lập: **4 passed, 80 subtests passed in 14.06s** (Godot trên PATH, lượt này); register `--verify`: **35/35 exprs present** (27 exact + 5 input + 3 output, đúng kỳ vọng scope); proof JSON đọc trực tiếp từ đĩa: **matches:true, 13/13** (10 semantic + registry_valid + one_headquarter_per_ssot + matches).
- Neighbours XONG **199 passed** trong 650.15s, exit 0, 09:54:13–10:05:04Z (chain main-thread PID 3375, log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2283-neighbours.log`); wiring XONG **32 tests OK** trong 124.385s, exit 0, 10:05:04–10:07:08Z (log `n2283-wiring.log` cùng thư mục). Chain script ghi rõ "NO gate — gate is main-thread only".
- SSOT đo từ đĩa sau GREEN: symbols **11662** (+3), Done **1733** (+1), contracts **1667** (+1), schemas **3125** (+2) → 11662/1733/1667/3125; defense slices 210, contracts 209; N2283 đã vào ledger. Đúng kỳ vọng scope (`docs/superpowers/handoffs/hidden_files/n2283-scope.md`).
- `git diff --check`: SẠCH (lượt này). HEAD vẫn a7b1a81c (N2282 DONE + PUSHED); worktree giữ file N2283 chưa commit.
- Gate CHƯA chạy, CHƯA có script `n2283-gate-only-main.sh` — lượt này KHÔNG launch gate (quy tắc durable: worker-launch gate chết giữa chừng; chỉ main thread launch). Port 7777 free, ps sạch (không pytest/unittest/godot nào đang chạy). Kỳ vọng gate: Ran ~6225, failures ~233, skipped=5, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2282).

## Scope (đã khóa — xem docs/superpowers/handoffs/hidden_files/n2283-scope.md)

- 7 case Turret đều có input live hoặc catalog: ammo → totalAmmo (param live từ game dict `turret_total_ammo`, frame không có key); ammoCapacity → maxAmmo 30 (class default, duo không override, Blocks.java:3257-3331); rotation → frame["rotation"], absent → 90.0 (BaseTurret.java:114); shootX/Y → World.conv(targetPos) = coord/8 (World.java:165-166, Vars.java:135 tilesize 8), target_pos null ≡ (0,0); shooting → frame["is_shooting"] (N2277 tick); progress → frame["progress"] (N2282 tick, không recompute).
- Default → super.sense (BuildingComp.java:2093-2126, ~25 cases) — DEFERRED slice riêng; pure function trả `{"handled": false, "sense_value": null, "sense_value_is_nan": true}`.
- Pure function: `source_turret_sense_state(frame: Dictionary, sensor: String, total_ammo: int, max_ammo: int, tilesize: float) -> Dictionary`, trả wire shape N2206/N2208/N2223 `{"handled", "sense_value", "sense_value_is_nan"}`. Placement: ngay TRƯỚC `source_turret_progress_state` (mirror Java order sense :405-419 trước progress :425-427).
- Proof keys (10 semantic + registry_valid + one_headquarter_per_ssot + matches = 13): sense_ammo_live_total (7 → 7.0), sense_ammo_capacity_default (30 → 30.0), sense_rotation_default (absent → 90.0), sense_rotation_custom (135.0 → 135.0), sense_shoot_x_converted ({x:80,y:24} → 10.0), sense_shoot_y_converted (→ 3.0), sense_shooting_true (→ 1.0), sense_shooting_false (→ 0.0), sense_progress_live (0.5 → 0.5), sense_unhandled_sensor ("health" → handled false, null, is_nan true).
- New result-key symbols (3): `source_turret_sense_state_result.handled`, `.sense_value`, `.sense_value_is_nan`. Expected SSOT sau GREEN: 11662/1733/1667/3125; defense slices 209 → 210, contracts 208 → 209.
- Register script `register_c07_turret_sense.py` mirror N2223 (import DEFERRED từ `register_c07_turret_progress`). EXACT_EXPRS (27, verbatim — xem scope); SLICE_SOURCES (6): Turret.java, BaseTurret.java, core World.java, Vars.java, LAccess.java, BuildingComp.java. Inputs (5): frame, sensor, total_ammo, max_ammo, tilesize. Outputs (3): handled, sense_value, sense_value_is_nan. `--verify` kỳ vọng 35/35.
- SSOT baseline (đo từ đĩa trước GREEN): symbols 11659, Done 1732, contracts 1666, schemas 3123; defense slices 209, contracts 208.

## GREEN (đã xong, xác minh độc lập lượt cron 17:15 +07)

- Pure function `source_turret_sense_state` trong SourceTurretBuildState.gd:224 (5 params, 3 keys) — ngay TRƯỚC `source_turret_progress_state`.
- KHÔNG có driver tick (quyết định scope có căn cứ: sense là logic read; mọi input live đã được proof N2240/N2277/N2282 chứng minh trên frame; logic-processor dispatch hook là slice riêng sau).
- Proof C07TurretSenseProof.gd + .tscn. Proof JSON đọc trực tiếp từ đĩa: matches:true, 13/13 true (10 semantic + matches + registry_valid + one_headquarter_per_ssot). Lưu ý: worker lượt 17:00 ghi "13/13" là đếm tổng key — con số đúng là 10 semantic / 13 tổng.
- `python3 register_c07_turret_sense.py --verify`: **35/35 exprs present**, exit 0 (re-run độc lập lượt này).
- Targeted: `python3 -m pytest tests/test_c07_turret_sense.py -q` (từ tools/mindustry_godot_transpiler, Godot trên PATH): **4 passed, 80 subtests passed in 14.06s** (re-run độc lập lượt này).
- Neighbours: **199 passed** trong 650.15s (exit 0, 09:54:13–10:05:04Z; log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2283-neighbours.log`).
- Wiring: **32 tests OK** trong 124.385s (exit 0, 10:05:04–10:07:08Z; log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2283-wiring.log`).
- `git diff --check`: SẠCH (lượt này).
- File thay đổi (slice commit TBD): SourceTurretBuildState.gd (M, +89), 6 SSOT JSON (M: registry, ledger, contracts, schema + defense_slices + defense_api_contracts), proof .gd/.tscn + register + test (mới). Proof .json không stage (theo quy tắc). Không stage *.gd.uid, gate/neighbours/wiring log, chain script, các log cũ full-suite-n21xx/n22xx trong tools/mindustry_godot_transpiler/.
- SSOT đo từ đĩa sau GREEN: symbols 11662 (+3), Done 1733 (+1), contracts 1667 (+1), schemas 3125 (+2) → 11662/1733/1667/3125; defense slices 210, contracts 209. Đúng kỳ vọng scope.
- javalang 0.13.0 OK, pytest 9.2.0 OK (kiểm tra lượt này); port 7777 free; ps guard exec riêng: không có pytest/unittest/godot/gate nào đang chạy.

## Gate (xong — main thread, xác minh độc lập lượt cron 17:45 +07)

- Gate log `tools/mindustry_godot_transpiler/full-suite-n2283-gate.log`, chain log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2283-chain.log`, main-thread GATE-START 10:19:04Z, GATE-EXIT 1 10:38:33Z. Ran 6225 trong 1167.030s, failures=233, skipped=5 — xác minh độc lập từ summary cuối log: 233 FAIL = 233 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR, toàn Godot-absent (+4 tests / +1 failure đúng mẫu vs N2282, đúng 4 test mới của N2283; +1 failure là test reference-graph của N2283, Godot-absent trong môi trường gate vì chain script reset PATH không có godot-bin — lượt này xác minh trực tiếp: chạy không có Godot trên PATH thì test đó fail `unexpectedly None`, chạy lại với godot-bin trên PATH thì 4/4 xanh).
- Sau gate xanh theo mẫu: docs (report + handoff + spec, nhớ bump Done total 1732→1733 — lỗi cũ N2280/N2252/N2260/N2263/N2275) + GOAL §5 (nợ Windows) + status + hashes (5 commit mẫu N2280/N2281/N2282) → push origin main.

## Tiếp theo (sau khi gate xong — main thread)

1. Xác minh gate độc lập từ summary log, `git diff --check`, commit + push N2283 (5 commit theo mẫu N2280/N2281/N2282).
2. Chọn slice tiếp theo từ deferred list — ứng viên: super.sense() delegation (BuildingComp.sense :2093-2126, ~25 cases, N2283 để lại handled=false làm cầu nối); logic-processor dispatch hook (LExecutor sense → turret sense); senseObject() (BuildingComp.java:2128-2136). calculateHeat vẫn BLOCKED (live entity scan); findTarget vẫn BLOCKED; shootp live wiring; `controlled()` cần player unit; LaserTurret shouldConsume() cần bullets live list; validateTarget effective-team chờ findTarget slice.

## Deferred (không đổi, trừ sense() Turret nay đã live)

- super.sense() delegation (BuildingComp.sense, ~25 cases) — slice riêng sau; N2283 để lại handled=false.
- Logic-processor dispatch hook (LExecutor sense → turret sense) — slice riêng sau.
- senseObject() (BuildingComp.java:2128-2136) — slice riêng (tiền lệ N2223 tách senseObject ra sau).
- calculateHeat live proximity scan (BuildingComp.java:410-461) — BLOCKED, live entity scan.
- Turret control() shootp live wiring — logic executor chưa có trong driver.
- findTarget (BLOCKED); các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
- `controlled()` live wiring (needs a player unit).
- LaserTurret shouldConsume() consumer wiring — cần bullets live list; chênh một tick snapshot (Java updateConsumption trước updateTile).
- Activation early-return skip — vacuous cho mọi def hiện tại.
- validateTarget effective-team live wiring (`canHeal() ? Team.derelict : team`, Turret.java:632) — chờ findTarget slice; can_heal live sẽ feed nó.
- findTarget ally-tile acquisition (`if(target == null && canHeal()){...}`, Turret.java:660) — BLOCKED, live entity scan.
- sense() cho def khác duo (maxAmmo per-def) — caller khác, pure function đã param hóa.
