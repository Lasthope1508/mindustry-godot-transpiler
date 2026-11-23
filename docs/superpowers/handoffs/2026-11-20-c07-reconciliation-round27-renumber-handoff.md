# Handoff — renumber round 27 (N2277 → N2323, divergence #48)

## Done
- **Renumber #48: local N2277 (DrillBuild.ambientVolume() super leg, 8 exprs,
  proof 8 keys) → N2323, commit `062de93`** (24 files, 1008+/1008-).
  Remote N2277 = Turret updateTile() isShooting (6 exprs, origin 9391d5a).
  Number-only, overlap 0/6 exprs, 0 symbols, 0 tests. Chain re-register 5
  (drill_ambient_volume → burst_drill_write_read + drill_should_ambient_sound →
  drill_sense + radar_draw_place). --verify 11/11 + 28/28 + 20/20 + 31/31 +
  20/20. Targeted 20/20 (233); family BurstDrill+Drill 64/64 (1125); wiring
  32/32 (250); proof C07DrillAmbientVolumeProof 8 keys all true (re-run in
  main). Ledger N2277 = 0, N2323 = 20 occurrences in generated JSON. SSOT
  unchanged 11716/1737/1685/3161. Near-miss: first commit 784e9f2 missed the
  symbol-registry line — amended into 062de93; allocations record fixed by
  script after the 10:30 cron run caught the stale hash.
- **Gate #48 GREEN (chunked runner, PID 9338):** Ran 6241, failures=237 (all
  Godot-absent), errors=0, skipped=5, 364/364 modules (log
  `hidden_files/full-suite-renumber-48-gate.log`). Renumber #48 fully closed.
- **VM restart #42 at 10:59 +07** — AFTER gate #48 finished, so the gate was
  NOT killed. Godot symlink recreated by main thread and verified
  `4.6.2.stable.official.71f334935`. No restart since #42.
- **Batch N2324–N2326 spawned by cron ~10:45** (controlled / DrillBuild.draw
  base / 3 music getters) from HEAD 062de93. Workers cut by cron timeout +
  restart #42 after targeted + proof (proofs 6/6, 12/12, 13/13 all true from
  disk). **Three continuations spawned ~11:0x** to finish family + wiring.
- **Docs (this commit):** report
  `docs/superpowers/reports/2026-11-20-c07-reconciliation-round27-renumber.md` + this
  handoff. Done 1737. SSOT 11716/1737/1685/3161.

## Next — renumber #49, then merge batch N2324–N2326
- **Renumber #49:** local N2278 (RadarBuild.draw(), 10 exprs, proof 11 keys) →
  **N2327**. Remote N2278 = Turret updateTile() logicControlled live derivation
  (5 exprs, origin 7df3724). Number-only at the N level, overlap 0/5 — BUT
  remote N2278 vs the whole local ledger: 4/5 exprs already owned (N2297, N2316)
  — read the probe's §5 before merging remote. Probe:
  `hidden_files/divergence-49-n2278-renumber-impact.md` (67 occurrences / 21
  files, chain re-register 3: draw 18/18 → draw_select 14/14 → draw_place
  20/20; read before starting). N2327 reserved by script ~11:10 (status
  'renumbering'). **Relabel `batch-queue.md` + 4 scope files IN THE SAME TURN
  as the renumber commit:** batch 2 → N2328–N2330, batch 3 → N2331–N2333,
  batch 4 → N2334–N2336, next_free_n 2340. Batch 1 (N2324–N2326) unchanged.
- **Merge batch N2324–N2326** when continuations report (family + wiring each):
  merge in N order (N2324 → N2325 → N2326), one slice at a time (copy →
  register → targeted re-verify → commit), then chunked batch gate + batch docs.
  Then spawn batch 2 (N2328–N2330 after relabel: peekAmmo / Drill
  canPlaceOn+setBars+drawPlanConfig / findMusic). Reserve by script + write
  spawn lock BEFORE spawning; worktrees from latest HEAD; brief includes
  editor-import uid_cache + port-7777-free check + Godot symlink check +
  arc/mindustry-upstream symlinks in worktrees.
- **Divergence merge-time flags:** remote N2277 isShooting is new (no dedup; it
  IS the frame-tracking slice ~15 local Turret slices deferred on — when it
  merges, their deferred entries must drop the isShooting part); remote
  N2274/N2275/N2276/N2277 are four consecutive sub-slices of the same driver
  tick — merge all four together; remote N2278: dedup pure function + 3 pure
  proof keys into N2297, take only the driver tick + 2 driver proof keys;
  remote N2274–N2278 are five consecutive sub-slices of the same driver tick —
  merge all five together.
- Push from Windows: local ahead/behind origin/main 7df3724 = **112 / 206**
  (recount at push time). Merge by hand in the spec at push time. No
  force-push.

## Cron delivery
- Job healthy (runs succeed; some timeout at 900s when spawning scope agents).
  The 10:30 run caught a real error (stale commit hash in allocations.json
  after an amend) — the cron's disk checks are working. Main thread keeps
  reporting directly every 15 minutes, including a one-line report when nothing
  changed.
