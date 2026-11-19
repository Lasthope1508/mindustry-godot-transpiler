# Handoff — renumber round 19 (N2270 → N2316, divergence #41)

## Done
- **Renumber #41: local N2270 (Turret findTarget) → N2316, commit `103dbae`** (21 files,
  3821+/3821-). Remote N2270 = Turret updateEfficiencyMultiplier heat fold (origin
  683f89a). Number-only, overlap 0/13 exprs, 0 symbols, 0 tests. Chain re-register 9
  Turret registers + burst_drill_ambient_volume (precedent rule text). --verify 87/87 +
  chain; targeted 4/4 (132); family Turret 64/64 (876); wiring 32/32 (250); proof
  C07TurretFindTargetProof 14 keys all true (re-run in main). Ledger N2270 = 0, N2316 =
  46 (1 key + 45 deferred). SSOT unchanged 11716/1737/1685/3161.
- **Gate #41 GREEN on rerun (PID 1716, ~02:41–03:00): Ran 6241 in 1094.830s,
  failures=237, skipped=5, 0 errors** — all 237 `unexpectedly None`. Log
  `hidden_files/full-suite-renumber-41-gate.log` (158238 byte). Attempt 1 (PID 7689) was
  killed by VM restart #34/35 (~02:17–02:41); log preserved as
  `hidden_files/full-suite-renumber-41-gate-killed-by-restart34.log`.
- **Docs (this commit):** report
  `docs/superpowers/reports/2026-11-20-c07-reconciliation-round19-renumber.md` + this
  handoff. Done 1737. SSOT 11716/1737/1685/3161.

## Next — renumber #42, then #43, then batch N2319–N2321
- **Renumber #42:** local N2271 (BurstDrill ambientVolume, 69751d1, proof 8 keys) →
  **N2317**. Remote N2271 = Turret shoot() charge sound (origin b21b55f). Number-only,
  overlap 0/8 exprs, 0 symbols, 0 tests. Probe:
  `hidden_files/divergence-42-n2271-renumber-impact.md` (116 occurrences / 38 files, chain
  re-register 5: setStats N2309 → ambientVolume → Drill.ambientVolume N2277 →
  shouldAmbientSound N2305 → write/read). Head of the BurstDrill/Drill DEFERRED fork.
  Rename-at-place (sed register/test/proof/GD comment + spec/GOAL, delete old ledger entry
  + contracts/schemas, re-register plain, --verify + targeted + family + wiring + proof
  re-run in main), then re-gate + docs #42.
- **Renumber #43:** local N2272 (Radar canPickup, 52c7854, proof 6 keys) → **N2318**.
  Remote N2272 = Turret canConsume() heat gate (origin c9ab307). Number-only, overlap
  1/4 exprs (only `return false;`), 0 symbols, 0 tests. Probe:
  `hidden_files/divergence-43-n2272-renumber-impact.md` (46 occurrences / 15 files, chain
  re-register 4: canPickup → draw → drawSelect → drawPlace). Head of the Radar DEFERRED
  chain. Do #42 first, #43 second (same SSOT files, N order), then re-gate + docs #43.
- **Batch N2319–N2321 scope** (`hidden_files/next-batch-scope-after-n2315.md`, labels
  TEMP — relabel +2 after #42/#43): Turret controlled() (Turret.java:441-443,
  `unit.isPlayer()`), DrillBuild.draw() base (Drill.java:346-379) + drawCracks no-op +
  drawDefaultCracks, Game getBossMusic/getAmbientMusic/getDarkMusic (3 getters,
  SoundControl.java:270-284). Then **N2322–N2324** (peekAmmo / Drill
  canPlaceOn+setBars+drawPlanConfig / findMusic) and **N2325–N2327** (drawSelect /
  Drill.icons / play). 3 different GD files each → parallel OK. Reserve by script + write
  spawn lock BEFORE spawning; worktrees from latest HEAD (after docs #43); brief includes
  editor-import uid_cache + port-7777-free check + Godot symlink check +
  arc/mindustry-upstream symlinks in worktrees. next_free_n after both renumbers + 3
  batches = 2328.
- **Divergence #42/#43 merge-time flags:** remote N2271 charge sound is new (no dedup,
  `chargeEffect` deferred); remote N2272 canConsume gate overlaps local N2308 (4/11
  exprs) — dedup decision at merge (inline fold in warmup vs pure function); remote
  N2266 targetPosition overlaps local N2122 (16/21 exprs) + needs hasAmmo (N2313, done) +
  peekAmmo (T6) owned before it merges.
- Push from Windows: local ahead/behind origin/main c9ab307 — recount at push time. Merge by
  hand in the spec at push time. No force-push.

## Cron delivery
- Job healthy (runs succeed). The stuck queue keeps draining: handoffs arrive late and
  stale. Main thread keeps reporting directly every 15 minutes.
