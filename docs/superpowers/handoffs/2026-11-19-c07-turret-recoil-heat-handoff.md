# Handoff — N2254 Turret recoil + heat decay (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~04:4x +07, lượt cron 04:30) — slice `223fbcf0`, docs `5e39c9a7`, GOAL `c0a15a96`, hashes `287fb1ae` (pushed; origin/main advances with this status commit). Targeted 4/4 + neighbours 72/72 + wiring 9/9 + proof matches:true 11/11 + gate Ran 6109, failures=204 toàn Godot-absent (đã xác minh độc lập).

- N2253 DONE + PUSHED (origin/main 061a3ba9, slice 41f09353) — đã xác minh độc lập lượt 03:30.
- N2254 GREEN: pure function + driver tick + register + proof + targeted 4/4 (41 subtests)
  + family/wiring 32/32 + spec/GOAL đã cập nhật. Xem report `2026-11-19-c07-turret-recoil-heat.md`.
- Lượt cron 04:00 xác minh lại độc lập: targeted 4/4 OK (15.35s, Godot trên PATH),
  proof JSON 11/11 true, matches:true, register --verify 28/28, `git diff --check` sạch,
  SSOT 11605/1704/1638/3067, ledger `slices.N2254` status done.
- Gate ĐÃ chạy xong (main thread, PID 2710, log full-suite-n2254-gate.log): Ran 6109
  in 1116.827s, failures=204, skipped=5, errors=0 — 204 FAIL header = 204 ×
  `AssertionError: unexpectedly None` (Godot-absent), 0 KeyError, 0 ERROR (xác minh
  độc lập lượt cron 04:30). Neighbours 72/72 OK (877 subtests, 280.41s), wiring 9/9 OK
  (9 × OK, log n2254-neighbours-main.log / n2254-wiring-main.log, main thread xác minh).
  Targeted re-run lượt 04:30: 4/4 OK (17.04s, PATH có godot-bin; lần chạy đầu fail 1
  do PATH thiếu godot-bin — lỗi môi trường, không phải regression). Proof JSON tái tạo
  lúc 04:32 +07: 11/11 true, matches:true.

## Scope (đã khóa, xác minh từ đĩa)

- Slice recoil + heat decay cho duo: driver chưa bao giờ đọc `frame["cur_recoil"]` /
  `frame["heat"]` — recoil/heat không decay live. N2254 lấp gap này.
- 1 pure function `source_turret_recoil_heat_state(cur_recoil, heat, recoil_time, cooldown_time, delta)`
  (5 params, 2 result keys: cur_recoil, heat) trong `SourceTurretBuildState.gd`
  (file turret chung — TurretBuild.updateTile) + 1 dòng driver tick trong nhánh duo,
  SAU warmup stamp (N2253), TRƯỚC aim/shoot.
- PIN: `curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);` (Turret.java:519),
  `heat = Mathf.approachDelta(heat, 0, 1 / cooldownTime);` (:526);
  approachDelta = approach × Time.delta (arc Mathf.java:420-422) → step = delta / recoil_time
  (resp. delta / cooldown_time). Duo: recoilTime = reload = 20 (:208), cooldownTime = 20
  (default :148) → rate 0.05. Delta = live-loop `seconds`, cùng quy ước N2253.
- 8 proof keys đã pin trong test: recoil_decays_toward_0_after_shot,
  recoil_reaches_0_within_recoil_time, heat_decays_toward_0_after_shot,
  heat_reaches_0_within_cooldown_time, recoil_stamped_to_frame_before_aim,
  heat_stamped_to_frame_before_aim, recoil_decay_rate_is_one_over_recoil_time,
  heat_decay_rate_is_one_over_cooldown_time.
- SSOT kỳ vọng sau GREEN: symbols +2, Done +1, contracts +1, schema +2
  → 11605/1704/1638/3067; defense shard slices 182 → 183, contracts 181 → 182.

## Tiếp theo: N2255

- N2255 candidate — shoot stamp `curRecoil = 1f;` / `heat = 1f;` /
  `totalShots++;` (Turret.java:807-810), hoặc charge advance :527 đi cùng queuedBullets.

## Deferred sau N2254

- Multi-recoil array (Turret.java:520-525, `recoils > 0`) — duo recoils = -1 → skip;
  slice riêng cho def có recoils > 0.
- Shoot stamp `curRecoil = 1f;` / `heat = 1f;` / `totalShots++;` (:807-810) — slice shoot-stamp riêng.
- recoilOffset draw (:532, recoilPow 1.8) — draw-side.
- Charge advance :527 (cần queuedBullets + firstShotDelay > 0) — đi cùng slice queuedBullets.
- effects/sound, queuedBullets (shotDelay > 0), findTarget (BLOCKED — live entity scan),
  các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
