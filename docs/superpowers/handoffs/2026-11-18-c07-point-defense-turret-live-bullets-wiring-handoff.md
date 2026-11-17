# Handoff — N2242 PointDefenseTurret driver map live bullets → observed dicts wiring (C07)

## Status: GREEN, gate done (Ran 6061, failures 192, all Godot-absent). Test + proof + gate xanh, chờ 5-commit + push. SSOT 11557/1692/1623/3037. Targeted 4/4, family PointDefenseTurret 20/20, wiring 32/32 = 56/56; proof 8 semantic keys / 11 in JSON matches:true.

## Commits

- Slice: (this commit)
- Docs: (next commit)
- GOAL: (next commit)

## Scope

1 pure function `source_point_defense_turret_live_bullets_state(live_bullets)`
(:441) → `{"observed_bullets": [...]}` + **1 driver tick line** (:582,
stamps `frame["observed_bullets"]` from live `game["bullets"]` EVERY
tick, unconditionally, immediately before the
`if frame.has("observed_bullets")` block). First wiring that maps real
live `game["bullets"]` (ShockwaveTower N2190/N2195 never mapped live
bullets — scan read a test-seeded frame key). Java evidence:
Groups.bullet.intersect min-dst2 pick (PointDefenseTurret.java:65-67);
every live Bullet has a team (BulletComp.java:29 @Import Team team);
hittable class default true (BulletType.java:143; 2 exceptions
damageLightning :32, fireball :45 in Bullets.java). LIVE MEASUREMENT
(not guessed): `game["bullets"]` dicts carry
sprite/target/velocity/speed/damage/hitSize/lifetime_remaining only —
NO team/hittable/id/type; single writer
SourceBulletSpawnState.gd:38-41, chain never passes team. Mapping: id =
sprite.get_instance_id() (SourcePlacedBlockState.gd:11 precedent; freed
sprite → bullet dropped, matches !isAdded() invalidation); x/y =
sprite.position (invalid sprite → dropped); damage from live dict; team
ONLY if live dict carries it (never invent -1); hittable default true
(2 false types = documented limit, per-type lookup later); has_type
true (every live bullet created with a type). GAP: live bullets carry
no team yet — needs a deferred slice stamping team at spawn (deferred
entry in N2242 ledger), otherwise should_consume is not truly live in
live play.

## RED

`test_c07_point_defense_turret_live_bullets_wiring.py`: Ran 4 in 1.227s,
FAILED (failures=2, errors=2), KeyError 'N2242' ×2 (main-thread re-run).
Register --verify 10/10 exit 0. NOTE: the RED test file was later fixed
by the worker (Godot 4.6 `Object.get` takes only 1 arg — the PINNED
driver line in the test used 2 args); the fix is test-harness only.

## GREEN (worker logs, verified by main thread from the logs)

- Targeted 4/4 (Ran 4 in 18.343s, OK — log
  n2242-targeted-after-scenefix.log).
- Family PointDefenseTurret 20/20 (5 module: power_status N2151 +
  target_acquire N2239 + aim_shoot N2240 + should_consume_cooling N2241
  + live_bullets_wiring; Ran 20 in 68.038s, OK — log
  n2242-family-after-scenefix2.log).
- Wiring 32/32 (9/9 module chuẩn, pytest 124.51s, 250 subtests — log
  n2242-wiring-after-scenefix.log).
- Tổng 56/56. `git diff --check` CLEAN (main thread).
- Proof 8 semantic keys / 11 trong JSON matches:true (keys:
  wiring_assigns_stable_id_from_sprite,
  wiring_clears_pooled_target_when_bullet_leaves_live_list,
  wiring_defaults_hittable_true, wiring_excludes_bullet_without_team,
  wiring_maps_live_bullet_position_from_sprite,
  wiring_marks_has_type_true, wiring_reads_team_and_hittable_when_present,
  wiring_stamps_observed_bullets_every_tick).
- Worker 04:15 timeout ở phase khảo sát (không để lại gì); worker 04:45
  GREEN xong nhưng family 17/20; worker 05:15 sửa 3 scene + chạy
  targeted/family/wiring xong nhưng timeout trước docs/gate/commit, và
  gate nó launch đã CHẾT cùng session (log 233 byte, 224 dots / 8 F /
  0 E, không footer — main thread relaunch). Logs worker ở goal
  hidden_files/n2242-*.log.

## Neighbour regression + fix (harness only)

N2242 driver overwrites scene-seeded frame observed_bullets with []
(game["bullets"] empty in scenes) → family 17/20 (N2239/N2240/N2241
reference tests fail). Fix = 3 proof scenes seed live bullets in
`game["bullets"]` (Sprite2D + team + damage + hittable) instead of
frame observed_bullets (worker 05:15; details in
`goal hidden_files/n2242-neighbour-regression.md`). First family run
after the scene fix FAILED (failures=2) on GDScript PARSE errors in
the rewritten scenes ("Expected indented block after function
declaration" at :9 of AimShoot + ShouldConsumeCoolant .gd) — worker
fixed the indentation ("body helper" fix) and the second run passed
20/20.

## SSOT

11557/1692/1623/3037 (symbols +1, ledger +1, contracts +1, schema +2).
N2242 done trong ledger. Defense shard change: defense_slices 170 →
171, defense_api_contracts 169 → 170. 7 file sửa (family.gd + 4 SSOT
canonical + 2 shard) + 3 proof scene sửa (N2239/N2240/N2241,
harness-only); untracked: test + register + proof.gd/.tscn
`C07PointDefenseTurretLiveBulletsWiringProof`.
Deferred pool 282 → 284 (+2: +1 Windows-proof debt AND +1 spawn-side
team stamp entry; resolve 0).

## Gate

Main thread, PID 3999, launch ~05:3x, xong ~05:50 (Ran 6061 in 1116.723s).
Footer: **Ran 6061, failures=192, skipped=5, errors=0** — đúng dự kiến trong
handoff (Ran 6057 → 6061, +4 test N2242; failures 191 → 192, +1 test
reference của slice mới). Đã xác minh bằng đếm trực tiếp trong log
`tools/mindustry_godot_transpiler/full-suite-n2242-gate.log` (untracked,
KHÔNG stage): `AssertionError: unexpectedly None` = 192, `FAIL:` = 192,
`ERROR:` = 0, KeyError = 0 — toàn bộ Godot-absent, KHÔNG phải regression.
Worker 05:15 ghi "~191" — SAI 1, đúng là 192 theo mẫu +1/slice. NOTE: gate
worker 05:15 launch đã CHẾT cùng session của nó (log 233 byte, 224 dots /
8 F / 0 E, không footer) — main thread relaunch; log mới ghi đè từ đầu.

## Next

5-commit + push N2242 (report/spec xong, gate đã xác minh). Sau đó:
spawn-side team stamp slice (deferred entry N2242) để should_consume sống
thật trong live play; suppression live + targets live list vẫn BLOCKED.
Proofs not yet run on Windows Godot — debt in GOAL.md §5.
