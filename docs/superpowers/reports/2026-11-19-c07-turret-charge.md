# Report — N2259 Turret charge advance (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~12:20 +07, lượt cron 12:15) — slice `e90d1466`, docs `c7bbdd7c`, GOAL `a7839a2c`, status `cff28223` (pushed; origin/main advances with this status commit). Targeted 4/4 + proof matches:true 11/11 + register --verify 10/10 + gate Ran 6129, failures=209 toàn Godot-absent (đã xác minh độc lập).

- N2258 DONE + PUSHED (origin/main e9dfee4e, slice 0ba552b7) — đã xác minh đầu lượt: git log 5 commit gần nhất khớp, working tree chỉ có diff N2259 + noise *.gd.uid (không stage).

## Slice (scope đã khóa)

- 1 pure function `source_turret_charge_state(charge: float, queued_bullets: int, first_shot_delay: float, delta: float) -> Dictionary` trong `SourceTurretBuildState.gd:374` + 1 driver tick nhánh duo, SAU tick multi-recoil decay N2256, TRƯỚC tick recoilOffset N2258 (Java order :527 sau heat :526, trước unit sync :529-531 và recoilOffset :532).
- Java: `charge = charging() ? Mathf.approachDelta(charge, 1, 1 / shoot.firstShotDelay) : 0;` (Turret.java:527); `charging()` = `queuedBullets > 0 && shoot.firstShotDelay > 0` (:715-717); field `public float shootWarmup, charge, warmupHold = 0f;` (:286); `public int queuedBullets = 0;` (:293); `public float firstShotDelay = 0;` (ShootPattern.java:11); duo `shoot = new ShootAlternate(3.5f);` (Blocks.java:3299, trong block duo 3257-3330 — ShootAlternate chỉ set spread, firstShotDelay giữ 0).
- Pure function tính `charging` trong hàm (không nhận bool ngoài); nếu charging thì `charge = approach(charge, 1, delta / first_shot_delay)` (clamp, không vượt 1), nếu không thì `charge = 0` (reset outright, không decay); `first_shot_delay <= 0` → charging false → 0, không bao giờ chia cho 0. Trả `{"charge": charge, "charging": charging}` — 2 result symbol.
- Driver tick (SourceTurretBuildState.gd:605-607): `source_turret_charge_state(float(frame.get("charge", 0.0)), int(frame.get("queued_bullets", 0)), 0.0, seconds)` rồi stamp `frame["charge"]` + `frame["charging"]` — tick chạy TRƯỚC aim nên aim đọc được charging tươi (đúng thứ tự Java :527 trước :601/:609).
- Duo firstShotDelay 0 → charging luôn false, charge luôn 0 live; tick vẫn cần để stamp frame cho warmup/shoot gate đọc. queuedBullets = 0 tại mọi tick boundary với duo (mọi delay = firstShotDelay + shotDelay*i = 0 nên bullet() chạy đồng bộ trong shoot(), ++ rồi -- net 0; charge :527 chạy trước shoot gate :733). Counter cross-tick cho turret firstShotDelay > 0 vẫn DEFERRED.

## RED (lượt cron 11:00)

- `python3 -m unittest tests.test_c07_turret_charge`: Ran 4, FAILED (failures=2, errors=2) — registration + input-evidence ERROR (ledger N2259 chưa tồn tại → KeyError N2259), state test FAIL vì pure function chưa có, proof test FAIL vì `C07TurretChargeProof.tscn` chưa tồn tại. Đỏ đúng kỳ vọng, đúng mẫu RED của N2258.

## GREEN (lượt cron 11:15–12:00 — code đã có trên đĩa; các lượt sau xác minh độc lập)

- Pure function + driver tick + register script + proof `C07TurretChargeProof` đã có; SSOT đúng kỳ vọng 11613/1709/1643/3077, defense 188/187; `git diff --check` OK.
- Targeted chạy lại: **Ran 4, OK (16.255s)**.
- Proof JSON `C07TurretChargeProof.json`: **matches:true, 11/11 true** (8 keys charge — gồm `charge_advances_toward_one`, `charge_clamps_at_one`, `charge_uses_previous_charge` — + `registry_valid` + `one_headquarter_per_ssot`).
- Register `--verify`: **10/10 exprs present**.
- VM restart ~11:24 +07 giữa lượt (uptime 6 phút lúc kiểm tra): javalang + pytest bị wipe — đã cài lại javalang 0.13.0 (requirements.txt) + pytest 9.2.0 riêng. Mọi GREEN đã xong + xác minh TRƯỚC restart, file trên đĩa nguyên vẹn.
- Neighbours 23 module — lần 1 (main.log) chết theo timeout/restart; lần 2 (main2.log, launch 11:32): **17 failed, 75 passed** — cả 17 fail đều chứa "Failed to start server on port 7777" (fail bắt đầu từ module thứ 7, có tiến trình khác giữ port giữa batch), KHÔNG phải regression thật. Lần 3 (main3.log, PID 4408, launch ~11:48, main thread, port 7777 trống): **92 passed, 1012 subtests passed trong 319.17s** — xanh toàn bộ.
- Tương tác charging (hồi quy do tick N2259, đã sửa ở harness, không đụng game): tick charge stamp `frame["charging"] = false` mỗi tick (duo firstShotDelay 0) TRƯỚC tick aim/shoot, ghi đè `frames[7]["charging"] = true` mà proof aim_shoot cũ inject trực tiếp vào frame — H bắn như D, reload reset về 0 thay vì giữ 20. Fix của worker lượt 11:30 CHỈ là comment (diff proof chỉ 8+/4− toàn comment, dòng inject còn nguyên). Main thread đã sửa thật (harness-only): bỏ injection `frames[7]["charging"] = true`, H bắn như D; nửa charging của gate chứng minh bằng direct pure-function call `source_item_turret_aim_shoot_state(..., shoot_warmup=1.0, charging=true, minWarmup=0.0, ...)` — mirror nửa warmup-low có sẵn. Đã xác minh: aim_shoot chạy riêng **4 passed, 111 subtests, 16.68s**, proof JSON 11 key matches:true.
- Wiring 9 module (log n2259-wiring-main.log): **9/9 OK, 32 test** (factory 4, power_graph_live_update 3, battery_power_status 3, battery_placement 3, adjacent_factory 4, unit_factory 4, turret_live_loop 4, continuous_liquid_turret 3, power_graph_consumer_cheating 4).
- Gate (log `tools/mindustry_godot_transpiler/full-suite-n2259-gate.log`, PID 5528, main thread, launch ~11:58 +07, xong ~12:16 +07): **Ran 6129 trong 1097.511s, FAILED (failures=209, skipped=5)** — sạch như kỳ vọng. Xác minh độc lập: 209 FAIL header = 209 × `AssertionError: unexpectedly None`, 0 KeyError, 0 `return_schema_linkage`, 0 ERROR — toàn Godot-absent. So với gate-2 N2258 (Ran 6125, failures=208): +4 tests / +1 failure đúng bằng 4 test mới của slice.
- javalang 0.13.0 + pytest 9.2.0 OK; port 7777 trống lúc launch gate; lượt này KHÔNG launch gate mới (đã có discover PID 5528 đang chạy — guard ps).

## Tiếp theo: N2260

- N2260 candidate — unit sync :529-531 (`unit.tile(this); unit.rotation(rotation); unit.team(team);`) hoặc shoot gate live :733 — quyết định khi N2259 xong, theo backlog C07.
