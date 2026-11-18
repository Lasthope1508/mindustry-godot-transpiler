# Report — N2255 Turret shoot stamp (C07, duo) [DONE + PUSHED]

## Status: DONE + PUSHED (2026-11-19 ~05:5x +07, lượt cron 05:45) — slice `076e10e8`, docs `808c8c4a`, GOAL `368fea41`, hashes `fa8377e2` (pushed; origin/main advances with this status commit). Targeted 4/4 + neighbours 76/76 + wiring 9/9 + proof matches:true 11/11 + gate Ran 6113, failures=205 toàn Godot-absent (đã xác minh độc lập).
Worker lượt 05:00 làm xong GREEN; main thread lượt 05:15 xác minh độc lập: targeted 4/4 OK,
proof 11/11 true matches:true (JSON tái tạo 05:16), register --verify 20/20;
lượt 05:30 chạy lại proof (JSON 05:27, 11/11 true, matches:true), neighbours 76/76 OK
(913 subtests), wiring 9/9 OK, gate Ran 6113 failures=205 tất cả Godot-absent; lượt 05:45
xác minh độc lập: targeted 4/4 OK (15.10s, verbose), register --verify 20/20,
SSOT 11608/1705/1639/3069, defense slices 184 / contracts 183.

- N2254 DONE + PUSHED (origin/main fb55208a) — đã xác minh độc lập lượt 04:30.
- N2255 scope đã khóa từ đĩa, RED test đã viết
  (`tools/mindustry_godot_transpiler/tests/test_c07_turret_shoot_stamp.py`).

## Slice (scope đã khóa)

- 1 pure function `source_turret_shoot_stamp_state(cur_recoil, heat, total_shots)`
  (3 params, 3 result keys: cur_recoil, heat, total_shots) trong
  `SourceTurretBuildState.gd` + 1 driver tick trong nhánh duo, SAU lời gọi
  `spawn_turret_bullet`.
- Java: `curRecoil = 1f;` (Turret.java:806), `heat = 1f;` (:810), `totalShots++;`
  (:811); fields :284 / :287, đều default 0. Multi-recoil stamp :807-809 KHÔNG
  phải slice này (duo recoils = -1 → skip); effects/sound/shake :799-805 KHÔNG
  phải slice này.
- Gap thật: driver chưa bao giờ stamp `frame["cur_recoil"]` / `frame["heat"]` /
  `frame["total_shots"]` sau phát bắn (N2252 chỉ stamp `frame["bullet_spawn"]`,
  N2254 chỉ decay về 0).

## RED (lượt này)

- `python3 -m unittest tests.test_c07_turret_shoot_stamp`: Ran 4, FAILED
  (failures=2, errors=2) — registration + input-evidence KeyError ledger N2255
  chưa tồn tại, state test fail vì pure function chưa có, proof test fail vì
  `C07TurretShootStampProof.tscn` chưa tồn tại.
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; uptime 50 phút.

## GREEN (lượt 05:00 worker + lượt 05:15 main thread xác minh)

- Targeted chạy lại: Ran 4, OK (15.10s, lượt cron 05:45 chạy verbose). Proof `C07TurretShootStampProof`: JSON tái tạo
  05:27, 11/11 true, matches:true. Register --verify: 20/20 exprs present, exit 0.
- SSOT 11608/1705/1639/3069 (đúng kỳ vọng); defense slices 184, contracts 183;
  `git diff --check` sạch.
- Neighbours 76/76 OK (913 subtests, 317.01s); wiring 9/9 OK. Gate (log
  full-suite-n2255-gate.log, xong ~05:45): Ran 6113 in 1199.966s, failures=205, skipped=5,
  errors=0 — all 205 verified Godot-absent (205 FAIL = 205 × `AssertionError: unexpectedly None`,
  0 KeyError, 0 ERROR).

## Tiếp theo: N2256 (sau push)

- N2256 candidate — xem Deferred sau N2255 (multi-recoil stamp, recoilOffset draw, charge advance + queuedBullets); scope ở lượt sau.
