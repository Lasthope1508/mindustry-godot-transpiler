# Handoff — renumber round 25 (N2275 → N2321, divergence #46)

## Done
- **Renumber #46: local N2275 (Radar fogRadius) → N2321, commit `2db57da`** (24
  files, 943+/943-). Remote N2275 = Turret updateTile() unit maxHealth (origin
  192a5bc). Number-only, overlap 0/4 exprs, 0 symbols, 0 tests. Chain re-register 5
  (fog_radius + drill_sense independent, then draw → draw_select → draw_place).
  --verify 13/13 + 31/31 + 18/18 + 14/14 + 20/20. Targeted 24/24 (280); family Radar
  40/40 (392); wiring 32/32 (250); proof C07RadarFogRadiusProof 9 keys all true
  (re-run in main). Ledger N2275 = 0, N2321 = 19 occurrences in generated JSON.
  SSOT unchanged 11716/1737/1685/3161.
- **Gate #46 GREEN (chunked runner, PID 14366):** Ran 6241, failures=237 (all
  Godot-absent), errors=0, skipped=5, 364/364 modules (log
  `hidden_files/full-suite-renumber-46-gate.log`). Renumber #46 fully closed.
- **VM restart #41 at 09:09 +07** (boot Nov 20 02:09 UTC) — AFTER gate #46 finished
  (~09:07), so the gate was NOT killed. Godot symlink recreated by cron and verified
  `4.6.2.stable.official.71f334935` (main thread re-verified).
- **Docs (this commit):** report
  `docs/superpowers/reports/2026-11-20-c07-reconciliation-round25-renumber.md` + this
  handoff. Done 1737. SSOT 11716/1737/1685/3161.

## Next — renumber #47 (last of the queue), then batch N2323–N2325
- **Renumber #47:** local N2276 (Turret write/read/version, 25 exprs, proof 11 keys)
  → **N2322**. Remote N2276 = Turret updateTile() unit health (4 exprs, origin
  5f0f72c). Number-only, overlap 0/4. Probe:
  `hidden_files/divergence-47-n2276-renumber-impact.md` (read before starting).
  Reserve N2322 by script first (next_free_n is 2322 now).
- After #47 (chunked gate + docs round 26): batch **N2323–N2325** (controlled() /
  DrillBuild.draw() base / 3 music getters), **N2326–N2328** (peekAmmo / Drill
  canPlaceOn+setBars+drawPlanConfig / findMusic), **N2329–N2331** (drawSelect /
  Drill.icons / play), **N2332–N2334** (Turret shouldTurn / BurstDrill shouldConsume /
  Game reload). Scope files relabel after the queue: after-n2315 +6, after-n2319 +6,
  after-n2323 +5, after-n2327 +3. next_free_n after 4 renumbers + 4 batches = **2335**.
  Reserve by script + write spawn lock BEFORE spawning; worktrees from latest HEAD
  (after docs #47); brief includes editor-import uid_cache + port-7777-free check +
  Godot symlink check + arc/mindustry-upstream symlinks in worktrees.
- **Divergence merge-time flags:** remote N2275 unit maxHealth is new (no dedup);
  remote N2274 + N2275 are consecutive sub-slices of the same driver tick — merge
  together; remote N2273 charge effect is new (first slice touching
  `TurretBuild.shoot()`); remote N2273 vs remote N2271 (charge sound) are two
  sub-slices of the same `shoot()` — compare at merge.
- Push from Windows: local ahead/behind origin/main 5f0f72c = **108 / 196** (recount at
  push time). Merge by hand in the spec at push time. No force-push.

## Cron delivery
- Job healthy (runs succeed; some timeout at 900s when spawning scope agents). The
  stuck queue keeps draining: handoffs arrive late and stale. Main thread keeps
  reporting directly every 15 minutes, including a one-line report when nothing changed
  (Isabella asked 07:03 +07 where the 15-minute reports were — main thread had been
  suppressing no-change cycles; fixed from the 07:03 report onward).
