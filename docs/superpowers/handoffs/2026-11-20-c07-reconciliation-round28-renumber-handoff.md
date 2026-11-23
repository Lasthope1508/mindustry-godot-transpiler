# Handoff — renumber round 28 (N2278 → N2327, divergence #49)

## Done
- **Renumber #49: local N2278 (RadarBuild.draw(), 10 exprs, proof 11 keys) →
  N2327, commit `92395c5`** (14 files, 1265+/1265-). Remote N2278 = Turret
  updateTile() logicControlled live derivation (5 exprs, origin 7df3724).
  Number-only at the N level, overlap 0/5 — BUT remote N2278 vs the whole
  local ledger: 4/5 exprs already owned (N2297, N2316) and its symbol is
  identical to N2297's — read the probe's §5 before merging remote. Chain
  re-register 3 (draw 18/18 → draw_select 14/14 → draw_place 20/20).
  Targeted 4/4 (40); proof C07RadarDrawProof 11 keys all true (re-run in
  main); family Radar 40/40 (392); wiring 32/32 (250). Ledger N2278 = 0,
  N2327 = 16 occurrences in generated JSON. SSOT unchanged
  11716/1737/1685/3161.
- **Relabel in the same turn as the commit:** batch 2 → N2328–N2330, batch 3
  → N2331–N2333, batch 4 → N2334–N2336, next_free_n **2337**. Also fixed 5
  wrong labels left by script #48 (draw base → N2325, findMusic → N2330, 3
  getters → N2324–N2326). Correction: the round 27 handoff said next_free_n
  2340 — wrong; the correct value is 2337.
- **Gate #49 GREEN (chunked runner, PID 11353):** Ran 6241, failures=237 (all
  Godot-absent `unexpectedly None`), errors=0, skipped=5, 364/364 modules
  (log `hidden_files/full-suite-renumber-49-gate.log`, finished ~12:09 +07).
  Renumber #49 fully closed. No VM restart since #42 (boot 03:59 UTC).
- **Duplicate continuation spawn #2 (11:02–11:03):** main thread spawned 3
  continuations N2324–N2326 ~11:02; cron run 11:00 spawned the same 3, same
  worktrees, 1 second later. Cron's N2325 died on timeout; cron's N2324/N2326
  cancelled ~11:18. Only main's set ran; all three finished (verified from
  disk). **Isabella approved ~11:18: CONTINUATION-LOCK rule** added to the
  cron body ~11:19 — whoever spawns a continuation writes a lock
  `continuation` {by, at, status running} into allocations.json BEFORE
  spawning; a running lock means do NOT spawn.
- **Batch N2324–N2326 continuations done** (verified from disk ~11:31–11:37):
  proofs 6/6, 12/12, 13/13 all true; families 68/68, 68/68, 24/24; wiring
  32/32 each. Waiting merge.
- **Docs (this commit):** report
  `docs/superpowers/reports/2026-11-20-c07-reconciliation-round28-renumber.md` + this
  handoff. Done 1737. SSOT 11716/1737/1685/3161.

## Next — renumber #50, then merge batch N2324–N2326
- **Renumber #50:** local N2279 (TurretBuild.isActive(), 12 exprs, proof 11
  keys) → **N2328**. Remote N2279 = Turret updateTile() activationTimer decay
  (5 exprs, origin 2e1267a). Number-only, overlap 3/5 — all three are field
  declarations / the `placed()` reset, not slice logic: remote writes/decays
  the timer in the tick, local reads it in the predicate — complementary, no
  dedup. Probe: `hidden_files/divergence-50-n2279-renumber-impact.md` (53
  occurrences / 16 files, chain re-register 6: is_active → min_range → status
  → micro_accessors → unit → has_ammo; renumber commit expected 11 files;
  read before starting). **Relabel `batch-queue.md` + 4 scope files IN THE
  SAME TURN as the renumber commit:** batch 2 → N2329–N2331, batch 3 →
  N2332–N2334, batch 4 → N2335–N2337, next_free_n **2338**. Batch 1
  (N2324–N2326) unchanged. Old worktree `mindustry-wt-n2279-turret` is
  dirty/stale — do NOT merge from it.
- **Merge batch N2324–N2326** after renumber #50: merge in N order (N2324 →
  N2325 → N2326), one slice at a time (copy → register → targeted re-verify
  → commit), then chunked batch gate + batch docs (Done 1737→1740). Then spawn
  batch 2 **N2329–N2331** (peekAmmo / Drill canPlaceOn+setBars+drawPlanConfig /
  findMusic). Reserve by script + write spawn lock BEFORE spawning; worktrees
  from latest HEAD; brief includes editor-import uid_cache + port-7777-free
  check + Godot symlink check + arc/mindustry-upstream symlinks in worktrees.
  A scope file for batch 5 already exists
  (`hidden_files/next-batch-scope-batch5.md`, numbers TBD at spawn time).
- **Divergence merge-time flags:** remote N2278: dedup pure function + 3 pure
  proof keys into N2297 (KEEP local frame-first signature), take only the
  driver tick + 2 driver proof keys; remote N2274–N2278 are five consecutive
  sub-slices of the same driver tick — merge all five together; remote N2279:
  check tick-driver order (Java decay :561-564 before aim/shoot) against where
  isActive is read; cross-reference with the other remote updateTile slices so
  the driver ticks are not merged as one blob.
- Push from Windows: local ahead/behind origin/main 2e1267a = **114 / 211**
  (recount at push time). Merge by hand in the spec at push time. No
  force-push.

## Cron delivery
- Cron runs 12:00 and 12:15 both delivered on time this cycle (probe #50 and
  gate #49 GREEN) and both were verified from disk by main thread before use.
  Main thread keeps reporting directly every 15 minutes, including a one-line
  report when nothing changed.
