# Handoff — renumber round 29 (N2279 → N2328, divergence #50)

## Done
- **Renumber #50: local N2279 (TurretBuild.isActive(), 12 exprs, proof 11
  keys) → N2328, commit `9eee254`** (11 files, 225+/225-). Remote N2279 =
  Turret updateTile() activationTimer decay (5 exprs, origin 2e1267a).
  Number-only, overlap 3/5 — all three are field declarations / the
  `placed()` reset, not slice logic: remote writes/decays the timer in the
  tick, local reads it in the predicate — complementary, no dedup. Chain
  re-register 6 (is_active 17/17 → min_range 16/16 → status 25/25 →
  micro_accessors 28/28 → unit 15/15 → has_ammo 21/21). Targeted 24/24 (289
  subtests); proof C07TurretIsActiveProof 11 keys all true (re-run in main);
  family Turret 64/64 (876); wiring 32/32 (250). Ledger N2279 = 0, N2328 =
  13 occurrences in generated JSON. SSOT unchanged 11716/1737/1685/3161.
  Probe error caught by assert: the contract key carries the
  `SourceTurretBuildState.` prefix (probe named it without).
- **Relabel in the same turn as the commit:** batch 2 → N2329–N2331, batch 3
  → N2332–N2334, batch 4 → N2335–N2337, next_free_n **2338**. Relabel script
  changed order vs #49: token shifts FIRST, phrase fixes AFTER (a phrase fix
  creates N2328, which is in the shift map). Also fixed stale cross-refs in
  scope bodies (Radar HẾT slice arrows, write/read N2276→N2322).
- **Gate #50 GREEN (chunked runner, PID 16898):** Ran 6241, failures=237 (all
  Godot-absent `unexpectedly None`), errors=0, skipped=5, 364/364 modules
  (log `hidden_files/full-suite-renumber-50-gate.log`, finished ~12:57 +07).
  Renumber #50 fully closed. No VM restart since #42 (boot 03:59 UTC).
- **No divergence #51:** origin/main still 2e1267a at docs time; the remote
  ledger's highest new key is still N2279.
- **Batch N2324–N2326 continuations done** (verified from disk ~11:31–11:37):
  proofs 6/6, 12/12, 13/13 all true; families 68/68, 68/68, 24/24; wiring
  32/32 each. Waiting merge.
- **Docs (this commit):** report
  `docs/superpowers/reports/2026-11-20-c07-reconciliation-round29-renumber.md` + this
  handoff. Done 1737. SSOT 11716/1737/1685/3161.

## Next — merge batch N2324–N2326, then spawn batch 2
- **Merge batch N2324–N2326 now** (gate #50 GREEN, docs 29 done): merge in N
  order (N2324 → N2325 → N2326), one slice at a time (copy → register →
  targeted re-verify → commit), then chunked batch gate + batch docs (Done
  1737→1740). Then spawn batch 2 **N2329–N2331** (peekAmmo / Drill
  canPlaceOn+setBars+drawPlanConfig / findMusic). Reserve by script + write
  spawn lock BEFORE spawning; worktrees from latest HEAD; brief includes
  editor-import uid_cache + port-7777-free check + Godot symlink check +
  arc/mindustry-upstream symlinks in worktrees. A scope file for batch 5
  already exists (`hidden_files/next-batch-scope-batch5.md`, numbers TBD at
  spawn time).
- **Divergence merge-time flags:** remote N2279: check tick-driver order
  (Java decay :561-564 before aim/shoot) against where isActive is read;
  cross-reference with the other remote updateTile slices so the driver ticks
  are not merged as one blob. Remote N2278: dedup pure function + 3 pure
  proof keys into N2297 (KEEP local frame-first signature), take only the
  driver tick + 2 driver proof keys; remote N2274–N2278 are five consecutive
  sub-slices of the same driver tick — merge all five together.
- Push from Windows: local ahead/behind origin/main 2e1267a = **116 / 211**
  (recount at push time). Merge by hand in the spec at push time. No
  force-push.

## Cron delivery
- Cron runs 12:30, 12:45 and 13:00 all delivered on time this cycle and were
  verified from disk by main thread before use. Main thread keeps reporting
  directly every 15 minutes, including a one-line report when nothing changed.
