# Handoff — renumber round 26 (N2276 → N2322, divergence #47)

## Done
- **Renumber #47: local N2276 (Turret write/read/version) → N2322, commit
  `08cb8f0`** (16 files, 411+/411-). Remote N2276 = Turret updateTile() unit
  health (origin 5f0f72c). Number-only, overlap 0/4 exprs, 0 symbols, 0 tests.
  Chain re-register 7 (write_read → is_active → min_range → status →
  micro_accessors → unit → has_ammo). --verify 36/36 + 17/17 + 16/16 + 25/25 +
  28/28 + 15/15 + 21/21. Targeted 32/32 (417); family Turret 64/64 (876);
  wiring 32/32 (250); proof C07TurretWriteReadProof 11 keys all true (re-run in
  main). Ledger N2276 = 0, N2322 = 28 occurrences in generated JSON. SSOT
  unchanged 11716/1737/1685/3161.
- **Gate #47 GREEN (chunked runner, PID 4498):** Ran 6241, failures=237 (all
  Godot-absent), errors=0, skipped=5, 364/364 modules (log
  `hidden_files/full-suite-renumber-47-gate.log`). Renumber #47 fully closed.
  Renumber queue #44–#47 EMPTY.
- **VM restart #41 at 09:09 +07** — AFTER gate #46 finished, so gate #46 was NOT
  killed. Godot symlink recreated by cron and verified
  `4.6.2.stable.official.71f334935`. No restart since #41.
- **Docs (this commit):** report
  `docs/superpowers/reports/2026-11-20-c07-reconciliation-round26-renumber.md` + this
  handoff. Done 1737. SSOT 11716/1737/1685/3161.

## Next — renumber #48, then batch N2324–N2326
- **Renumber #48:** local N2277 (DrillBuild.ambientVolume() super leg, 8 exprs,
  proof 8 keys) → **N2323**. Remote N2277 = Turret updateTile() isShooting
  (6 exprs, origin 9391d5a). Number-only, overlap 0/6. Probe:
  `hidden_files/divergence-48-n2277-renumber-impact.md` (88 occurrences / 36
  files, chain re-register 5: ambient_volume → burst_drill_write_read +
  drill_should_ambient_sound → drill_sense + radar_draw_place; read before
  starting). Reserve N2323 by script first (next_free_n is 2323 now).
  **Do NOT confuse local N2277 (Drill super leg) with local N2317 (BurstDrill
  override, renumber #42)** — #48 touches N2277 only.
- After #48 (chunked gate + docs round 27): relabel 4 scope files (+1) and spawn
  batch **N2324–N2326** (controlled() / DrillBuild.draw() base / 3 music
  getters), **N2327–N2329** (peekAmmo / Drill canPlaceOn+setBars+drawPlanConfig /
  findMusic), **N2330–N2332** (drawSelect / Drill.icons / play), **N2333–N2335**
  (Turret shouldTurn / BurstDrill shouldConsume / Game reload). next_free_n
  after #48 + 4 batches = **2336**. Reserve by script + write spawn lock BEFORE
  spawning; worktrees from latest HEAD (after docs #48); brief includes
  editor-import uid_cache + port-7777-free check + Godot symlink check +
  arc/mindustry-upstream symlinks in worktrees.
- **Divergence merge-time flags:** remote N2277 isShooting is new (no dedup; it
  IS the frame-tracking slice ~15 local Turret slices deferred on — when it
  merges, their `'Turret frame tracking for isShooting / reloadCounter / reload'`
  deferred entries must drop the isShooting part); remote N2274/N2275/N2276/N2277
  are four consecutive sub-slices of the same driver tick — merge all four
  together; remote N2273 charge effect is new (first slice touching
  `TurretBuild.shoot()`); remote N2273 vs remote N2271 (charge sound) are two
  sub-slices of the same `shoot()` — compare at merge.
- Push from Windows: local ahead/behind origin/main 9391d5a = **110 / 201**
  (recount at push time). Merge by hand in the spec at push time. No
  force-push.

## Cron delivery
- Job healthy (runs succeed; some timeout at 900s when spawning scope agents).
  The stuck queue keeps draining: handoffs arrive late and stale. Main thread
  keeps reporting directly every 15 minutes, including a one-line report when
  nothing changed (Isabella asked 07:03 +07 where the 15-minute reports were —
  main thread had been suppressing no-change cycles; fixed from the 07:03 report
  onward).
