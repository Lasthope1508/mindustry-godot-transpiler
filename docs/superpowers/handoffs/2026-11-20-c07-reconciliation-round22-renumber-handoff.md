# Handoff — renumber round 22 (N2272 → N2318, divergence #43)

## Done
- **Renumber #43: local N2272 (Radar canPickup) → N2318, commit `837d31b`** (13 files,
  898+/898-). Remote N2272 = Turret canConsume() heat gate (origin c9ab307). Number-only,
  overlap 1/4 exprs (only `return false;`), 0 symbols, 0 tests. Chain re-register 4
  (canPickup → draw → drawSelect → drawPlace). --verify 6/6 + 18/18 + 14/14 + 20/20.
  Targeted 16/16 (135); family Radar 40/40 (392); wiring 32/32 (250); proof
  C07RadarCanPickupProof 6 keys all true (re-run in main). Ledger N2272 = 0, N2318 = 17
  occurrences in generated JSON. SSOT unchanged 11716/1737/1685/3161.
- **Gate #43 RUNNING (PID 7378, launch ~04:27, log
  `hidden_files/full-suite-renumber-43-gate.log`)** — expect Ran 6241, failures 237
  Godot-absent, skipped 5, 0 errors. Verify from the log when it finishes.
- **Docs (this commit):** report
  `docs/superpowers/reports/2026-11-20-c07-reconciliation-round22-renumber.md` + this
  handoff. Done 1737. SSOT 11716/1737/1685/3161.

## Next — renumber #44 (after gate #43 green), then batch N2320–N2322
- **Renumber #44:** local N2273 (Turret trackingRange, 99a4c9f, proof 10 keys) →
  **N2319**. Remote N2273 = Turret shoot() charge-effect part (origin 34c947c).
  Number-only, overlap 0/13 exprs, 0 symbols, 0 tests. Probe:
  `hidden_files/divergence-44-n2273-renumber-impact.md` (68 occurrences / 18 files, chain
  re-register 8: trackingRange → writeRead → isActive → minRange → status →
  microAccessors → unit → hasAmmo). Head of the Turret DEFERRED chain. Reserve N2319 by
  script first (next_free_n is 2319 now). After the chain, grep the old number in the
  generated JSON too (lesson #42). Then re-gate + docs #44.
- **Batch N2320–N2322 scope** (`hidden_files/next-batch-scope-after-n2315.md`, labels
  TEMP — relabel +3 after #42/#43/#44): Turret controlled() (Turret.java:441-443,
  `unit.isPlayer()`), DrillBuild.draw() base (Drill.java:346-379) + drawCracks no-op +
  drawDefaultCracks, Game getBossMusic/getAmbientMusic/getDarkMusic (3 getters,
  SoundControl.java:270-284). Then **N2323–N2325** (peekAmmo / Drill
  canPlaceOn+setBars+drawPlanConfig / findMusic), **N2326–N2328** (drawSelect /
  Drill.icons / play), **N2329–N2331** (Turret shouldTurn / BurstDrill shouldConsume /
  Game reload — scope file `hidden_files/next-batch-scope-after-n2327.md` already exists).
  3 different GD files each → parallel OK. Reserve by script + write spawn lock BEFORE
  spawning; worktrees from latest HEAD (after docs #44); brief includes editor-import
  uid_cache + port-7777-free check + Godot symlink check + arc/mindustry-upstream
  symlinks in worktrees. next_free_n after both renumbers + 4 batches = 2332.
- **Divergence #44 merge-time flag:** remote N2273 charge effect is new (no dedup, first
  slice touching `TurretBuild.shoot()`); remote N2273 vs remote N2271 (charge sound, #42)
  are two sub-slices of the same `shoot()` — compare at merge.
- Push from Windows: local ahead/behind origin/main 34c947c — recount at push time. Merge by
  hand in the spec at push time. No force-push.

## Cron delivery
- Job healthy (runs succeed, some timeout at 900s when spawning scope agents). The stuck
  queue keeps draining: handoffs arrive late and stale. Main thread keeps reporting
  directly every 15 minutes.
