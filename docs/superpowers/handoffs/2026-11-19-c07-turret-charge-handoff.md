# Handoff — N2259 Turret charge advance (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~12:20 +07, lượt cron 12:15) — slice `e90d1466`, docs `c7bbdd7c`, GOAL `a7839a2c`, status `cff28223` (pushed; origin/main advances with this status commit). Targeted 4/4 + proof matches:true 11/11 + register --verify 10/10 + gate Ran 6129, failures=209 toàn Godot-absent (đã xác minh độc lập).

- N2258 DONE + PUSHED (origin/main e9dfee4e, slice 0ba552b7) — đã xác minh đầu lượt: git log 5 commit khớp, HEAD == origin/main == e9dfee4e, worktree sạch ngoại trừ noise *.gd.uid (không stage).

## Scope (đã khóa, xác minh từ đĩa)

- Slice charge advance cho duo: driver C07 mới (`SourceTurretBuildState.source_turret_tick_buildings_state`, nhánh duo) chưa bao giờ stamp `frame["charge"]` / `frame["charging"]` — warmup tick N2253 đã đọc `frame.get("charging", false)` và aim call đã truyền nó, nhưng giá trị đó luôn là default false vì chưa có tick nào stamp; shoot gate Java `:733` cũng đọc `!charging()`. N2259 là tick live trên driver mới, KHÔNG làm lại path legacy (không có path legacy cho charge).
- 1 pure function `source_turret_charge_state(charge: float, queued_bullets: int, first_shot_delay: float, delta: float) -> Dictionary` trong `SourceTurretBuildState.gd` (file turret chung — updateTile() là TurretBuild, không phải ItemTurret-only), đặt sau `source_turret_recoil_offset_state` + 1 driver tick trong nhánh duo, SAU tick multi-recoil decay N2256, TRƯỚC tick recoilOffset N2258.
- PIN Java: `charge = charging() ? Mathf.approachDelta(charge, 1, 1 / shoot.firstShotDelay) : 0;` (Turret.java:527); `charging()` = `return queuedBullets > 0 && shoot.firstShotDelay > 0;` (:715-717); field `public float shootWarmup, charge, warmupHold = 0f;` (:286); `public int queuedBullets = 0;` (:293); `public float firstShotDelay = 0;` (ShootPattern.java:11, `/** delay in ticks before first shot */`); duo `shoot = new ShootAlternate(3.5f);` (Blocks.java:3299, trong block duo 3257-3330 — ShootAlternate chỉ set spread, firstShotDelay giữ 0); approachDelta arc `Mathf.java:420-422` (`return approach(from, to, Time.delta * speed);`) với approach `:415-417` (`return from + Mathf.clamp(to - from, -speed, speed);`).
- Thứ tự Java trong updateTile (:490-532) đã pin: :502-515 warmup → :519 decay curRecoil → :520-525 multi-recoil decay → :526 heat → **:527 charge** → :532 recoilOffset → :595-596 turnToTarget → :601/:609 updateShooting → :733 shoot gate (`if(reloadCounter >= reload && !charging() && shootWarmup >= minWarmup)`).
- Pure function: `charging = queued_bullets > 0 and first_shot_delay > 0` (tính trong hàm, không nhận bool ngoài — khác warmup N2253 nhận `charging` làm param vì warmupTarget cần nó trước khi charge tick tồn tại); nếu charging thì `charge = approach(charge, 1, delta / first_shot_delay)` (clamp, không vượt 1), nếu không thì `charge = 0` (reset outright, không phải decay); `first_shot_delay <= 0` → charging false → 0, không bao giờ chia cho 0. Trả `{"charge": charge, "charging": charging}` — 2 result symbol.
- Driver tick: `var charge_state: Dictionary = source_turret_charge_state(float(frame.get("charge", 0.0)), int(frame.get("queued_bullets", 0)), 0.0, seconds)` rồi `frame["charge"] = charge_state.get("charge", 0.0)` + `frame["charging"] = charge_state.get("charging", false)`. Tick này chạy TRƯỚC aim call nên aim đọc được charging tươi (đúng thứ tự Java :527 trước :601/:609).
- 8 proof keys đã pin trong test: charge_zero_when_not_charging, charge_zero_when_first_shot_delay_zero, charge_advances_toward_one, charge_clamps_at_one, charge_uses_previous_charge, charge_stamped_to_frame, charging_flag_matches_gate, charge_duo_live_zero.
- SSOT kỳ vọng sau GREEN: symbols +2, Done +1, contracts +1, schema +2 → 11613/1709/1643/3077; defense shard slices 187 → 188, contracts 186 → 187.

## queuedBullets — quyết định scope (đã xác minh, không đoán)

- Với duo, `queuedBullets` = 0 tại mọi tick boundary — chứng minh: `ShootAlternate.shoot` truyền delay = `firstShotDelay + shotDelay * i` (ShootAlternate.java:32); duo firstShotDelay = 0 (ShootPattern.java:11, không override) và shotDelay = 0 (:13, không override) nên mọi delay = 0; `shoot()` chỉ defer `bullet()` qua `Time.run(delay, ...)` khi `delay > 0f` (Turret.java:770-777), delay 0 thì `bullet()` chạy đồng bộ trong `shoot()`, `queuedBullets++` rồi `--` net 0 trước khi tick kết thúc; và charge :527 chạy TRƯỚC shoot gate :733 nên luôn đọc 0 với duo. Vì vậy `int(frame.get("queued_bullets", 0))` là live-correct cho duo, không cần tick counter riêng trong slice này.
- Counter queuedBullets cross-tick cho turret có firstShotDelay > 0 (bullet bị defer qua Time.run, queue tồn tại qua nhiều tick) vẫn DEFERRED — cần mô hình delayed bullet mà chưa driver tick nào làm; không đoán trong N2259.

## RED (lượt này, đã chạy + đã xác minh độc lập)

- `python3 -m unittest tests.test_c07_turret_charge` (PATH có ~/workspace/godot-bin, chạy từ `tools/mindustry_godot_transpiler/`): **Ran 4, FAILED (failures=2, errors=2)** — đúng kỳ vọng, đúng mẫu RED của N2258. 2 ERROR: registration + input-evidence, cả hai `KeyError: 'N2259'` (ledger chưa có entry N2259); state test FAIL vì pure function `source_turret_charge_state` chưa có; proof test FAIL vì `C07TurretChargeProof.tscn` chưa tồn tại (Godot exit 1, `Cannot open file 'res://tools/runtime_proofs/C07TurretChargeProof.tscn'`).
- javalang 0.13.0 importable; port 7777 trống; không có unittest discover đang chạy.
- Chỉ 2 file mới, chưa commit: test `tools/mindustry_godot_transpiler/tests/test_c07_turret_charge.py` + handoff này (untracked). Không stage/commit gì ở bước RED.

## GREEN (lượt cron 11:15, đã chạy + đã xác minh độc lập)

- Pure function `source_turret_charge_state` (SourceTurretBuildState.gd, sau `source_turret_recoil_offset_state`) + driver tick trong nhánh duo SAU tick multi-recoil decay N2256, TRƯỚC tick recoilOffset N2258 — đúng scope. Java lines đã xác minh lại từ đĩa trước khi viết: Turret.java:527 / :715-717 / :286 / :293, ShootPattern.java:11, Blocks.java:3299.
- Register script `register_c07_turret_charge.py`: **--verify 10/10 exprs present**; đã chạy — SSOT **11613/1709/1643/3077** (đúng kỳ vọng handoff: symbols +2, Done +1, contracts +1, schema +2); defense slices 188, contracts 187. Không có schema legacy `source_turret_charge_result` nên validator rơi thẳng về `source_turret_charge_state_result`, không cần alias như N2258.
- Proof `C07TurretChargeProof` (.gd + .tscn): targeted **Ran 4, OK (16.255s)**; JSON đã đọc trực tiếp: **matches:true, 8/8 semantic true + registry_valid + one_headquarter_per_ssot**.
- **VM restart ~11:24 +07 giữa lượt** (uptime 1 phút lúc kiểm tra pytest): javalang + pytest đều bị wipe — đã cài lại javalang 0.13.0 (requirements.txt) + pytest 9.2.0 riêng. Mọi GREEN trên đã xong + xác minh TRƯỚC restart, file trên đĩa nguyên vẹn.
- Neighbours (23 module: 12 PointDefenseTurret + 3 ItemTurret + 7 turret slices warmup/recoil_heat/multi_recoil/multi_recoil_stamp/shoot_stamp/recoil_offset/charge + test_turret_live_loop, kỳ vọng 92 tests) — ĐANG CHẠY nền, log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2259-neighbours-main.log`; port 7777 trống lúc launch, không discover đang chạy.

## GREEN (lượt cron 11:45 — neighbours + wiring + proof-fix tương tác charging)

- **Tương tác charging (hồi quy do tick N2259, đã sửa ở harness, không đụng game):** neighbours main2 (launch 11:32) fail 17/92 — tất cả đều chứa "Failed to start server on port 7777" (fail bắt đầu từ module thứ 7, có tiến trình khác giữ port giữa batch), KHÔNG phải regression thật. Nhưng neighbours-main3 chạy lại (xem dưới) vẫn fail 1 module duy nhất: `test_c07_item_turret_aim_shoot`, key `no_shoot_when_charging_or_warmup_low: False`. Nguyên nhân thật: tick charge N2259 stamp `frame["charging"] = false` mỗi tick (duo firstShotDelay 0) TRƯỚC tick aim/shoot, ghi đè `frames[7]["charging"] = true` mà proof cũ inject trực tiếp vào frame — H bắn như D, reload reset về 0 thay vì giữ 20. Fix của worker lượt 11:30 CHỈ là comment (diff proof chỉ 8+/4− toàn comment, dòng inject còn nguyên). Main thread đã sửa thật (harness-only): bỏ injection `frames[7]["charging"] = true`, H bắn như D; nửa charging của gate chứng minh bằng direct pure-function call `source_item_turret_aim_shoot_state(..., shoot_warmup=1.0, charging=true, minWarmup=0.0, ...)` — mirror nửa warmup-low có sẵn. Đã xác minh: aim_shoot chạy riêng **4 passed, 111 subtests, 16.68s**, proof JSON 11 key matches:true.
- **Neighbours (23 module, chạy lại lần 3 từ main thread, PID 4408, launch ~11:48, log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2259-neighbours-main3.log`): 92 passed, 1012 subtests passed trong 319.17s (0:05:19)** — XANH toàn bộ, gồm cả aim_shoot sau fix.
- **Wiring (9 module live-loop, log `n2259-wiring-main.log`): 9/9 OK** — factory_live_loop 4, power_graph_live_update_binding 3, battery_power_status_binding 3, battery_placement_binding 3, adjacent_factory_live_loop 4, unit_factory_live_loop 4, turret_live_loop 4, continuous_liquid_turret_live_loop 3, power_graph_consumer_cheating 4; javalang OK, port 7777 trống lúc launch.
- `git diff --check` OK; HEAD vẫn e9dfee4e (N2258); N2259 chưa commit/push.

## GREEN (chưa làm)

- [x] Pure function + driver tick theo scope trên.
- [x] Register script `register_c07_turret_charge.py` (owner `SourceTurretBuildState.source_turret_charge_state`, 2 symbol `source_turret_charge_state_result.charge` / `.charging`, runtime_proof `/root/C07TurretChargeProof`); --verify 10/10; đã chạy register (SSOT 11613/1709/1643/3077; defense slices 188, contracts 187 — đúng kỳ vọng).
- [x] Proof `C07TurretChargeProof` (.gd + .tscn) với 8 keys; JSON `matches:true`, 8/8 semantic true + registry_valid + one_headquarter_per_ssot.
- [x] Targeted 4/4 OK.
- [x] Neighbours + wiring xanh (92 passed / 1012 subtests; wiring 9/9 OK).
- [x] Gate (log `tools/mindustry_godot_transpiler/full-suite-n2259-gate.log`, PID 5528 main thread, launch ~11:58 +07, xong ~12:16 +07) Ran 6129 trong 1097.511s, FAILED (failures=209, skipped=5) — sạch như kỳ vọng. Xác minh độc lập: 209 FAIL header = 209 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. So với gate-2 N2258 (Ran 6125, failures=208): +4 tests / +1 failure đúng bằng 4 test mới của slice.
- [x] Report/handoff/spec/GOAL hoàn thiện → commit + push (KHÔNG stage *.gd.uid / logs / project.godot) — gate đã xanh.

## Tiếp theo: N2260 (sau N2259)

- Unit sync :529-531 (`unit.tile(this); unit.rotation(rotation); unit.team(team);`) hoặc shoot gate live :733 — quyết định khi N2259 xong, theo backlog C07.

## Deferred (không đổi)

- Counter queuedBullets cross-tick + delayed bullets (Time.run) cho turret firstShotDelay > 0.
- effects/sound, findTarget (BLOCKED — live entity scan), các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
