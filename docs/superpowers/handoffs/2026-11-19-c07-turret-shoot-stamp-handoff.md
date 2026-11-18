# Handoff — N2255 Turret shoot stamp (C07, duo) [GREEN — gate xong, chờ commit + push]

## Status: GREEN (2026-11-19 ~05:45 +07, lượt cron 05:45) — slice `076e10e8`, docs `808c8c4a`, GOAL `368fea41`; gate Ran 6113 / failures 205 toàn Godot-absent (xác minh độc lập lượt cron 05:45). Chưa push.
Worker lượt 05:00 làm xong GREEN (code + test + proof); main thread lượt 05:15 xác minh độc lập
targeted 4/4 OK, proof 11/11 true matches:true (JSON tái tạo 05:16), register --verify 20/20;
lượt 05:30 chạy lại proof (JSON 05:27, 11/11 true, matches:true), neighbours 76/76 OK
(913 subtests), wiring 9/9 OK, gate Ran 6113 failures=205 tất cả Godot-absent; lượt 05:45
xác minh độc lập: targeted 4/4 OK (15.10s, verbose), register --verify 20/20,
SSOT 11608/1705/1639/3069, defense slices 184 / contracts 183, `git diff --check` sạch.

- N2254 DONE + PUSHED (origin/main fb55208a, slice 223fbcf0) — đã xác minh độc lập lượt 04:30.
- N2255 scope đã khóa từ đĩa (Java + driver hiện tại), RED test đã viết
  (`tools/mindustry_godot_transpiler/tests/test_c07_turret_shoot_stamp.py`).
  Xem report `2026-11-19-c07-turret-shoot-stamp.md`.

## Scope (đã khóa, xác minh từ đĩa)

- Slice shoot stamp cho duo: driver chưa bao giờ stamp `frame["cur_recoil"]` /
  `frame["heat"]` / `frame["total_shots"]` sau phát bắn — N2252 chỉ stamp
  `frame["bullet_spawn"]`, N2254 chỉ decay các giá trị về 0. N2255 lấp gap này.
- 1 pure function `source_turret_shoot_stamp_state(cur_recoil, heat, total_shots)`
  (3 params, 3 result keys: cur_recoil, heat, total_shots) trong
  `SourceTurretBuildState.gd` (file turret chung — bullet() là TurretBuild.bullet,
  không phải ItemTurret-only) + 1 driver tick trong nhánh duo, SAU lời gọi
  `spawn_turret_bullet` (Java order :806-811 sau khi bullet được tạo ở :797).
- PIN: `curRecoil = 1f;` (Turret.java:806), `heat = 1f;` (:810),
  `totalShots++;` (:811); fields `public float curRecoil, heat, logicControlTime = -1;`
  (:284), `public int totalShots, barrelCounter;` (:287), đều default 0.
  Multi-recoil stamp (`if(recoils > 0){` / `curRecoils[barrelCounter % recoils] = 1f;` / `}`,
  :807-809) KHÔNG phải slice này: duo recoils = -1 (Turret.java:142) → skip.
  Effects / sound / shake (:799-805) KHÔNG phải slice này.
- Pure function trả `{"cur_recoil": 1.0, "heat": 1.0, "total_shots": total_shots + 1}`:
  inputs là giá trị pre-shot trên frame, nên hàm map recoil/heat đã decay bất kỳ
  về 1.0 và count bất kỳ về count + 1. Driver đọc `frame["cur_recoil"]` /
  `frame["heat"]` / `frame["total_shots"]` (defaults 0.0 / 0.0 / 0 — chưa có key
  total_shots nào trước slice này) rồi stamp cả ba lại frame, để tick sau decay
  từ 1.0 (N2254) và đếm từ total đã stamp.
- 8 proof keys đã pin trong test: recoil_stamped_to_1_after_shot,
  heat_stamped_to_1_after_shot, total_shots_increments_after_shot,
  total_shots_counts_consecutive_shots, recoil_stamped_to_frame_after_spawn,
  heat_stamped_to_frame_after_spawn, total_shots_stamped_to_frame_after_spawn,
  stamp_runs_after_bullet_spawn.
- SSOT kỳ vọng sau GREEN: symbols +3, Done +1, contracts +1, schema +2
  → 11608/1705/1639/3069; defense shard slices 183 → 184, contracts 182 → 183.

## RED (lượt này, đã chạy)

- `python3 -m unittest tests.test_c07_turret_shoot_stamp` (PATH có ~/workspace/godot-bin):
  Ran 4, FAILED (failures=2, errors=2) — registration + input-evidence lỗi
  KeyError ledger N2255 chưa tồn tại, state test fail vì pure function chưa có,
  proof test fail vì `C07TurretShootStampProof.tscn` chưa tồn tại. Đỏ đúng kỳ vọng.
- javalang 0.13.0 + pytest 9.2.0 importable; port 7777 trống; uptime 50 phút
  (không restart gần đây).

## GREEN (lượt 05:00 worker + lượt 05:15 main thread xác minh)

- Code: `source_turret_shoot_stamp_state` trong `SourceTurretBuildState.gd` + 1 driver
  tick nhánh duo SAU `spawn_turret_bullet`; SSOT đã register (ledger N2255 status done).
- Targeted (main thread chạy lại 05:16, PATH có ~/workspace/godot-bin): Ran 4, OK (18.383s).
- Proof `C07TurretShootStampProof`: JSON tái tạo 05:16, 8 semantic keys / 11 tổng, 11/11 true, matches:true.
- Register: `python3 register_c07_turret_shoot_stamp.py --verify` → 20/20 exprs present, exit 0.
- SSOT: 11608/1705/1639/3069 (đúng kỳ vọng); defense shard slices 184, contracts 183.
- Neighbours 76/76 OK (913 subtests, 317.01s, log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2255-neighbours-main.log`); wiring 9/9 OK (log `n2255-wiring-main.log`).
- Gate (log `tools/mindustry_godot_transpiler/full-suite-n2255-gate.log`, xong ~05:45 +07): Ran 6113 in 1199.966s, failures=205, skipped=5, errors=0 — all 205 verified Godot-absent (205 FAIL headers = 205 × `AssertionError: unexpectedly None`, 0 KeyError, 0 ERROR; riêng test N2255 trong gate cũng chỉ fail `unexpectedly None`).
- Port 7777 trống (neighbours/wiring/gate đã xong).

## Tiếp theo: docs/spec/GOAL → commit + push

- Đợi neighbours + wiring xong (đọc 2 log trên) → gate đầy đủ (main thread launch)
  → docs/spec/GOAL → commit + push. Không commit/push khi chưa đủ điều kiện
  (Godot proof + gate phải xanh).

## Deferred sau N2255

- Multi-recoil stamp (Turret.java:807-809, `recoils > 0`) — slice riêng cho def có recoils > 0.
- recoilOffset draw (:532, recoilPow 1.8) — draw-side.
- Charge advance :527 (cần queuedBullets + firstShotDelay > 0) — đi cùng slice queuedBullets.
- effects/sound, queuedBullets (shotDelay > 0), findTarget (BLOCKED — live entity scan),
  các def ItemTurret khác ngoài duo.
- Live coolant driver wiring + suppression/targets live list vẫn BLOCKED (catalog capture).
