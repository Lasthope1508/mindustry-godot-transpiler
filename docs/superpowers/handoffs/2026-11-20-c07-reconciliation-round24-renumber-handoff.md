# Handoff — renumber round 24 (N2274 → N2320, divergence #45)

## Done
- **Renumber #45: local N2274 (Radar updateTile) → N2320, commit `4b69cc5`** (16
  files, 2652+/2652-). Remote N2274 = Turret updateTile() unit world position
  (origin 46d4b30). Number-only, overlap 0/10 exprs, 0 symbols, 0 tests. Chain
  re-register 5 (update_tile → fog_radius → draw → draw_select → draw_place).
  --verify 36/36 + 13/13 + 18/18 + 14/14 + 20/20. Targeted 20/20 (240); family Radar
  40/40 (392); wiring 32/32 (250); proof C07RadarUpdateTileProof 10 keys all true
  (re-run in main). Ledger N2274 = 0, N2320 = 15 occurrences in generated JSON.
  SSOT unchanged 11716/1737/1685/3161.
- **Gate #45 GREEN (chunked runner, PID 10688):** Ran 6241, failures=237 (all
  Godot-absent), errors=0, skipped=5, 364/364 modules (log
  `hidden_files/full-suite-renumber-45-gate.log`). Renumber #45 fully closed.
- **Docs (this commit):** report
  `docs/superpowers/reports/2026-11-20-c07-reconciliation-round24-renumber.md` + this
  handoff. Done 1737. SSOT 11716/1737/1685/3161.

## Next — renumber #46 → #47, then batch N2323–N2325
- **Renumber #46:** local N2275 (Radar fogRadius, 10 exprs, proof 9 keys) → **N2321**.
  Remote N2275 = Turret updateTile() unit maxHealth (4 exprs, origin 192a5bc).
  Number-only, overlap 0/4. Probe:
  `hidden_files/divergence-46-n2275-renumber-impact.md` (chain re-register 5 — read
  the probe before starting). Reserve N2321 by script first (next_free_n is 2321 now).
- **Renumber #47:** local N2276 (Turret write/read/version, 25 exprs, proof 11 keys)
  → **N2322**. Remote N2276 = Turret updateTile() unit health (4 exprs, origin
  5f0f72c). Number-only, overlap 0/4. Probe:
  `hidden_files/divergence-47-n2276-renumber-impact.md`.
- Strict order #46 → #47, one at a time, chunked gate + docs after each. Then
  batch **N2323–N2325** (controlled() / DrillBuild.draw() base / 3 music getters),
  **N2326–N2328** (peekAmmo / Drill canPlaceOn+setBars+drawPlanConfig / findMusic),
  **N2329–N2331** (drawSelect / Drill.icons / play), **N2332–N2334** (Turret
  shouldTurn / BurstDrill shouldConsume / Game reload). Scope files relabel after the
  queue: after-n2315 +6, after-n2319 +6, after-n2323 +5, after-n2327 +3.
  next_free_n after 4 renumbers + 4 batches = **2335**. Reserve by script + write
  spawn lock BEFORE spawning; worktrees from latest HEAD (after docs #47); brief
  includes editor-import uid_cache + port-7777-free check + Godot symlink check +
  arc/mindustry-upstream symlinks in worktrees.
- **Divergence merge-time flags:** remote N2274 unit world position is new (no
  dedup); frame key `unit_tile` is also stamped by remote N2260 (unit sync) — check
  at merge who stamps it locally (N2307 unit() is the candidate); remote N2273
  charge effect is new (first slice touching `TurretBuild.shoot()`); remote N2273
  vs remote N2271 (charge sound) are two sub-slices of the same `shoot()` — compare
  at merge.
- Push from Windows: local ahead/behind origin/main 5f0f72c = **106 / 196** (recount at
  push time). Merge by hand in the spec at push time. No force-push.

## Cron delivery
- Job healthy (runs succeed; some timeout at 900s when spawning scope agents). The
  stuck queue keeps draining: handoffs arrive late and stale. Main thread keeps
  reporting directly every 15 minutes, including a one-line report when nothing changed
  (Isabella asked 07:03 +07 where the 15-minute reports were — main thread had been
  suppressing no-change cycles; fixed from the 07:03 report onward).
