# Report — N2254 Turret recoil + heat decay (C07, duo) [GREEN — gate xong, chờ push]

## Status: GREEN (2026-11-19 ~03:5x +07) — slice `223fbcf0`, docs `5e39c9a7`, GOAL `c0a15a96`; gate Ran 6109 / failures 204 toàn Godot-absent (xác minh độc lập lượt cron 04:30). Chưa push.

- N2253 DONE + PUSHED (origin/main 061a3ba9) — đã xác minh độc lập lượt 03:30.
- N2254 GREEN trong lượt này: pure function + driver tick + register + proof
  + targeted 4/4 + family/wiring 32/32 + spec/GOAL đã cập nhật.
- Gate ĐÃ chạy xong (main thread, PID 2710, log full-suite-n2254-gate.log): Ran 6109
  in 1116.827s, failures=204, skipped=5, errors=0 — 204 FAIL header = 204 ×
  `AssertionError: unexpectedly None` (Godot-absent), 0 KeyError, 0 ERROR (xác minh
  độc lập lượt cron 04:30). Neighbours 72/72 OK (877 subtests, 280.41s), wiring 9/9 OK
  (log n2254-neighbours-main.log / n2254-wiring-main.log). Targeted re-run lượt 04:30:
  4/4 OK (17.04s, PATH có godot-bin; lần chạy đầu fail 1 do PATH thiếu godot-bin —
  lỗi môi trường, không phải regression). Proof JSON tái tạo lúc 04:32 +07: 11/11 true,
  matches:true. Slice commit `223fbcf0` (11 file: code + SSOT + proof .gd/.tscn +
  register + test), `git diff --check` sạch.

## Slice

- 1 pure function `source_turret_recoil_heat_state(cur_recoil, heat, recoil_time, cooldown_time, delta)`
  (5 params, 2 result keys: cur_recoil, heat) trong `SourceTurretBuildState.gd:224`
  + 1 driver tick trong nhánh duo (`SourceTurretBuildState.gd:432` gọi pure function
  với per-def duo 20.0 / 20.0, `:433-434` stamp `frame["cur_recoil"]` + `frame["heat"]`),
  SAU warmup stamp (N2253), TRƯỚC aim/shoot.
- Java: `curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);` (Turret.java:519),
  `heat = Mathf.approachDelta(heat, 0, 1 / cooldownTime);` (:526); approachDelta = approach ×
  Time.delta (arc Mathf.java:420-422) → step = delta / recoil_time (resp. delta / cooldown_time).
  Duo: recoilTime = reload = 20 (:208), cooldownTime = 20 (default :148) → rate 0.05.
  Multi-recoil loop :520-525 KHÔNG phải slice này (duo recoils = -1 → skip); shoot stamp
  `curRecoil = 1f;` / `heat = 1f;` (:807-810) và recoilOffset draw (:532) KHÔNG phải slice này.

## Kết quả kiểm tra (đã xác minh độc lập trong lượt này)

- Targeted `tests.test_c07_turret_recoil_heat`: **Ran 4, OK (41 subtests, 16.70s)** —
  chạy 2 lần (trước và sau VM restart), đều 4/4. Proof JSON
  `C07TurretRecoilHeatProof.json`: 8/8 keys true, `matches: true`, 11/11 true.
- Family + wiring (8 module: warmup, aim_shoot, validate_target, bullet_spawn,
  turret power_status, turret live_loop, build_turret power_status + should_consume):
  **Ran 32, OK (111.50s)** — không regression.
- Register `--verify`: **28/28 exprs present**.
- SSOT sau GREEN: **11605/1704/1638/3067** (đúng kỳ vọng scope); defense shard
  slices 182 → 183, contracts 181 → 182.
- Spec Done 1703 → 1704 + row N2254 (spec line 331); GOAL §5 line 386 nợ Windows N2254.
- Port 7777 trống lúc chạy proof; `git diff --check` sạch.

## Tiếp theo: PUSH (lượt cron 04:30)

- Commit docs (handoff + report + spec) → GOAL → hashes → push origin main →
  handoff Status DONE + PUSHED.
- Sau push: N2255 candidate — shoot stamp `curRecoil = 1f;` / `heat = 1f;` /
  `totalShots++;` (Turret.java:807-810), hoặc charge advance :527 đi cùng queuedBullets.

## Deferred sau N2254

- Multi-recoil array (Turret.java:520-525, `recoils > 0`) — slice riêng cho def có recoils > 0.
- Shoot stamp (:807-810) — slice shoot-stamp riêng.
- recoilOffset draw (:532, recoilPow 1.8) — draw-side.
- Charge advance :527 (cần queuedBullets + firstShotDelay > 0) — đi cùng slice queuedBullets.
- effects/sound, queuedBullets (shotDelay > 0), findTarget (BLOCKED — live entity scan),
  các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
