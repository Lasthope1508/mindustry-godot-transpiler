# Handoff — N2240 PointDefenseTurret updateTile aim + reload + shoot (C07)

## Status: GREEN, gate DONE (main thread, PID 11835, ~02:02–02:20). Test + proof xanh, gate sạch (chỉ Godot-absent), chờ 5-commit + push. SSOT 11552/1690/1621/3033. Targeted 4/4, family PointDefenseTurret 12/12, wiring 32/32 = 48/48; proof 8 semantic keys / 11 in JSON matches:true. Gate footer Ran 6053, failures=190, skipped=5, errors=0 — toàn bộ Godot-absent.

## Commits

- Slice: (this commit)
- Docs: (next commit)
- GOAL: (next commit)

## Scope

1 pure function `source_point_defense_turret_aim_shoot_state(frame, target,
team_id, x, y, range, rotate_speed, reload, shoot_cone, bullet_damage,
block_damage_multiplier, edelta)` trong `SourcePointDefenseTurretBuildState.gd`
(:234) → rotation/reload_counter/dest/shot/damage_dealt/target_damage_after/
target_removed/shoot_event; **+ 1 driver tick line** (:466, giá trị per-def
segment range 180.0 / rotateSpeed 20.0 / reload 8.0 / shootCone 5.0 /
bulletDamage 30.0). Nửa sau của updateTile advance (N2239 làm nửa đầu
retarget + pooled invalidation, :62-71; đây là :76-101). Helpers
`_angle_dist` (:207) + `_move_toward_angle` (:217) — mirror
SourceMathState.

Java evidence (theo scope `n2240-scope.md`, đã grep trên disk):
- Gate :76 (5 điều kiện; `within` = dst2 < range² STRICT, Position.java:40-46).
- Aim :77-78 (`angleTo` = atan2(dx,dy), 0° = +Y — KHÔNG dùng Vector2
  `angle_to`; `moveToward` cung ngắn nhất, |angleDist| < speed → trả thẳng
  `to`; rotation default 90, BaseTurret.java:114).
- Reload :79 (`reloadCounter += edelta`, KHÔNG clamp — Turret.java:723
  không áp dụng, PointDefenseBuild không extends TurretBuild).
- Shoot gate :82 (`Angles.within(rotation, dest, shootCone)` = angleDist
  <= shootCone && reloadCounter >= reload).
- Damage :83-88 (realDamage = bulletDamage * blockDamageMultiplier; so
  sánh STRICT `>` — damage bằng đúng realDamage thì target bị remove).
- Reset :97 (`reloadCounter = 0`, KHÔNG `%= reload`).
- Effects/sound :90-95 KHÔNG spawn trong pure function — trả `shoot_event`
  dict (beam origin/rotation/target).
- Defaults: class shootCone 5f / bulletDamage 10f / shootLength 3f /
  rotateSpeed 20f / reload 30f; segment per-def (Blocks.java:3838-3846)
  range 180f / shootLength 5f / bulletDamage 30f / reload 8f.

## RED

`test_c07_point_defense_turret_aim_shoot.py`: Ran 4 in 1.223s,
FAILED (failures=2, errors=2), KeyError 'N2240' ×2 (main-thread re-run).
Register --verify 50/50 exit 0 (script implements --verify, đã kiểm tra
trước).

## GREEN (main thread re-run targeted; family/wiring từ log worker — đầy đủ)

- Targeted 4/4 (15.143s, main-thread re-run; worker log pytest 4 passed,
  62 subtests, 14.90s).
- Family PointDefenseTurret 12/12 (3 module: power_status N2151 +
  target_acquire N2239 + aim_shoot; pytest 40.90s, 126 subtests — worker
  log, đủ 3 module).
- Wiring 32/32 (9/9 module chuẩn, pytest 127.37s — worker log, đủ 9
  module).
- Tổng 48/48. `git diff --check` CLEAN (main thread).
- Proof 8 semantic keys / 11 trong JSON matches:true (keys:
  aim_rotates_toward_target, aim_ignores_out_of_range_target,
  aim_ignores_same_team_target, aim_no_rotation_without_target,
  reload_accumulates_and_shoots_at_cone, shoot_deals_block_damage,
  shoot_removes_target_when_lethal, shoot_event_carries_beam_origin).
- Worker 01:30 timeout trước khi chạy test/proof; worker 01:45 làm xong
  GREEN (register + targeted + family + wiring + proof) nhưng timeout
  trước docs/gate/commit. Logs của worker ở `tools/mindustry_godot_transpiler/n2240-*.log`
  (không phải hidden_files/ — lần sau tìm log bằng `find`).

## SSOT

11552/1690/1621/3033 (symbols +8, ledger +1, contracts +1, schema +2).
N2240 done trong ledger. Defense shard change: defense_slices 168 → 169,
defense_api_contracts 167 → 168. 7 file sửa (family.gd + 4 SSOT canonical
+ 2 shard); untracked: test + register + proof.gd/.tscn
`C07PointDefenseTurretAimShootProof`.
Deferred pool 280 → 281 (+1 Windows-proof debt, không resolve entry nào).

## Gate

Main thread, PID 11835, ~02:02–02:20 (guard ps ở exec riêng: không gate
nào đang chạy; javalang OK; godot KHÔNG trên PATH). Log
`tools/mindustry_godot_transpiler/full-suite-n2240-gate.log`. Footer: Ran
6053 in 1066.579s, failures=190, skipped=5, errors=0 — toàn bộ 190 verified
Godot-absent asserts (đếm trực tiếp trong log: `unexpectedly None` = 190,
`FAIL:` = 190, `ERROR:` = 0, KeyError = 0). Khớp đúng dự kiến trong handoff
(Ran 6049 → 6053 = +4 test N2240; failures 189 → 190 = +1 test reference
của slice mới).

## Next

Gate → report/spec + 5-commit + push N2240. Sau đó họ tiếp theo theo
backlog (suppression live + targets live list vẫn BLOCKED). Proofs not
yet run on Windows Godot — debt in GOAL.md §5.
