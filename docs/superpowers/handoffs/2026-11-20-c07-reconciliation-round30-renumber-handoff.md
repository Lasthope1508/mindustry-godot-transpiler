# Handoff — renumber round 30 (N2280 → N2332, divergence #51)

## Done
- **Renumber #51: local N2280 (Drill setStats super leg, 39 exprs, proof 12
  keys) → N2332, commit `83c0707`** (12 files, 708+/708-, metadata-only).
  Remote N2280 = Turret isActive() (5 exprs, origin df426c4). Number-only,
  overlap 0/5. Chain re-register 3 (set_stats 54/54 → write_read 28/28 →
  draw_select 32/32); targeted 4/4 (84 subtests); proof
  C07DrillSetStatsProof 12 keys all true (re-run in main); family
  BurstDrill+Drill 68/68 (1280); wiring 32/32 (250). Totals unchanged
  11731/1740/1690/3171; N2280 = 0 in generated JSON, N2332 = 13 occurrences.
  Spec line 348 sed first occurrence only; GOAL :415 renumbered.
- **Relabel in the same turn as the commit:** batch 1 N2324–N2326 marked
  MERGED, batch 2 **N2329–N2331** unchanged, batch 3 → **N2333–N2335**,
  batch 4 → **N2336–N2338**, next_free_n **2339**; allocations.json N2332
  done, next_free_n 2333. Also fixed live setStats cross-refs (N2280 → N2332)
  in 3 scope bodies + the §3 next_free_n lines.
- **Gate batch N2324–N2326 GREEN (chunked, resumed after restart #43):**
  Ran 6253, failures 240 (all `unexpectedly None`, new baseline), errors 0,
  skipped 5, 367/367.
- **Gate #51 RUNNING (chunked, PID 10288, log
  `hidden_files/full-suite-renumber-51-gate.log`, expected Ran 6253/240/0/5).**
- **Docs (this commit):** report
  `docs/superpowers/reports/2026-11-20-c07-reconciliation-round30-renumber.md` + this
  handoff. Done 1740. SSOT 11731/1740/1690/3171.

## Next — batch 2 continuations, then merge, then batch 3
- **When gate #51 is green:** spawn 3 continuations for batch 2 N2329–N2331
  (family + wiring only; N2331 wiring failed 8/9 in parallel with the batch
  gate — re-run its wiring modules alone to tell flake from real). Write
  continuation locks to allocations.json BEFORE spawning. Then merge in N
  order (N2329 → N2330 → N2331), batch gate, batch docs (Done 1740→1743),
  then spawn batch 3 **N2333–N2335** (drawSelect / Drill.icons / play).
  Worktrees base 27a383b — note renumber #51 changed the N2280 number in the
  shared JSONs + comments, but not the slices' GD files; check base drift per
  the batch rule at merge.
- **Divergence merge-time flags:** remote N2280 vs local N2328 — same GD
  function name, DIFFERENT signatures (remote 4 explicit params, local
  frame-first) and remote has a driver-tick stamp (`frame["is_active"]`)
  that local lacks; decide signature + keep the stamp, do not dedup blindly;
  check local ownership of the N2279 activationTimer decay first. Remote
  N2279: check tick-driver order (decay :561-564 before aim/shoot) vs where
  isActive is read. Remote N2278: dedup pure into N2297, take only driver
  tick + 2 driver proof keys.
- Push from Windows: local ahead/behind origin/main df426c4 = **121 / 217**
  (recount at push time). Merge by hand in the spec at push time. No
  force-push.

## Cron delivery
- Cron runs 13:15, 13:30, 13:45 and 14:00 all delivered on time this cycle and
  were verified from disk by main thread before use. Main thread keeps
  reporting directly every 15 minutes, including a one-line report when
  nothing changed.
