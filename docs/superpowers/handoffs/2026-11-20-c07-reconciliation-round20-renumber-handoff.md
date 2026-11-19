# Handoff — renumber round 20 (N2271 → N2317, divergence #42)

## Done
- **Renumber #42: local N2271 (BurstDrill ambientVolume) → N2317, commit `5298682`**
  (26 files, 831+/831-). Remote N2271 = Turret shoot() charge sound (origin b21b55f).
  Number-only, overlap 0/8 exprs, 0 symbols, 0 tests. Chain re-register 5 (setStats →
  ambientVolume → Drill.ambientVolume → shouldAmbientSound → writeRead) + drill_sense +
  radar_draw_place (rule text). --verify 26/26 + 11/11 + 11/11 + 20/20 + 28/28 + 31/31
  + 20/20. Targeted 16/16 (158); family BurstDrill+Drill 64/64 (1125); wiring 32/32
  (250); proof C07BurstDrillAmbientVolumeProof 8 keys all true (re-run in main). Ledger
  N2271 = 0, N2317 = 31 occurrences in generated JSON. SSOT unchanged
  11716/1737/1685/3161.
- **Gate #42 RUNNING (PID 5722, launch ~03:20, log
  `hidden_files/full-suite-renumber-42-gate.log`)** — expect Ran 6241, failures 237
  Godot-absent, skipped 5, 0 errors. Verify from the log when it finishes.
- **Docs (this commit):** report
  `docs/superpowers/reports/2026-11-20-c07-reconciliation-round20-renumber.md` + this
  handoff. Done 1737. SSOT 11716/1737/1685/3161.

## Next — renumber #43 (after gate #42 green), then batch N2319–N2321
- **Renumber #43:** local N2272 (Radar canPickup, 52c7854, proof 6 keys) → **N2318**.
  Remote N2272 = Turret canConsume() heat gate (origin c9ab307). Number-only, overlap
  1/4 exprs (only `return false;`), 0 symbols, 0 tests. Probe:
  `hidden_files/divergence-43-n2272-renumber-impact.md` (46 occurrences / 15 files, chain
  re-register 4: canPickup → draw → drawSelect → drawPlace). Head of the Radar DEFERRED
  chain. Reserve N2318 by script first (next_free_n is 2318 now). After the chain,
  grep the old number in the generated JSON too (lesson #42: sibling rule text).
  Then re-gate + docs #43.
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
- **Divergence #43 merge-time flag:** remote N2272 canConsume gate overlaps local N2308
  (4/11 exprs) — dedup decision at merge (inline fold in warmup vs pure function).
- Push from Windows: local ahead/behind origin/main c9ab307 — recount at push time. Merge by
  hand in the spec at push time. No force-push.

## Cron delivery
- Job healthy (runs succeed). The stuck queue keeps draining: handoffs arrive late and
  stale. Main thread keeps reporting directly every 15 minutes.
