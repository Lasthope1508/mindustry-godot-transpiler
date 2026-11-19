# Handoff — reconciliation round 17 (renumber N2268 → N2311, divergence #39)

## Done
- **Renumber #39: local N2268 (Turret fogRadius) → N2311, commit `6726d65`** (39 files,
  303+/303-). Sed: register fogRadius + test + proof .gd + spec :332 (first occurrence
  only) + GOAL :383 + estimateDps register (whole file) + line-targeted seds in 5 downstream
  registers + drill_sense + 4 Radar registers + GD comments (Radar/Turret/BurstDrill) + 10
  test comments + 4 proof .gd comments. Probe missed 1 line (BurstDrill GD :402 has TWO
  N2268 occurrences on one line — second caught by full-tree grep, fixed with /g). Delete
  ledger key + 1 contract + 2 schemas + defense contract + defense slice key. Chain
  re-register **11 registers** (fogRadius → estimateDps → warmup → findTarget →
  trackingRange → writeRead → isActive → minRange → status → microAccessors → unit) +
  drill_sense re-run. --verify 21/21 + 20/20 + 44/44 + 87/87 + 18/18 + 36/36 + 17/17 +
  16/16 + 25/25 + 28/28 + 15/15 + 31/31; targeted 4/4 (44); family Turret 60/60 (829);
  wiring 32/32 (250); proof C07TurretFogRadiusProof re-run in main, 7 domain keys (10 total)
  all true. Literal N2268 in the ledger = 0 (N2311 = 12). SSOT unchanged 11699/1734/1682/3155.
  Done 1734.
- **Gate #39 GREEN (PID 17277, ~22:13–22:31): Ran 6229 in 1083.354s, failures=234,
  skipped=5, 0 errors** — all 234 `unexpectedly None`. Log
  `hidden_files/full-suite-renumber-39-gate.log`. No VM restart during the gate (uptime 3:05
  at the 22:42 check).
- **Docs (this commit):** report `docs/superpowers/reports/2026-11-19-c07-reconciliation-round17-renumber.md`
  + this handoff. Spec row + GOAL §5 number already renumbered in 6726d65.

## Next — renumber #40, then batch N2313–N2315
- **Renumber #40 (do first, right after this docs commit):** local N2269 (BurstDrill icons)
  → **N2312**. Probe `hidden_files/divergence-40-n2269-renumber-impact.md` §2 (sed targets +
  chain order, 8 registers: icons → on_proximity_update → set_stats → ambient_volume →
  drill_ambient_volume → should_ambient_sound + write_read + drill_set_stats; drill_draw_select
  is comment-only, sed but no re-run). After the probe-listed sed, grep literal N2269 across
  the whole tree and sed every live reference (lesson from #37/#38/#39); after the chain
  re-register, grep literal N2269 in the ledger (lesson from #36). Verify: --verify +
  targeted (test_c07_burst_drill_icons) + family BurstDrill+Drill + wiring + proof
  C07BurstDrillIconsProof re-run (expect 3 domain keys / 6 total — count from JSON when run)
  → commit → re-gate → docs round 18.
- **Batch N2313–N2315 after docs #40** (hasAmmo / BurstDrill draw / isDark): scope file
  `hidden_files/next-batch-scope-after-n2311.md` (base 49f8137) still carries pre-#40 labels
  N2312–N2314 / N2315–N2317 — **relabel +1 before spawning**. Reserve N2313–N2315 by script
  + write spawn lock BEFORE spawning; worktrees from latest HEAD; brief includes
  editor-import uid_cache + port-7777-free check + Godot symlink check + arc/mindustry-upstream
  symlinks. hasAmmo side-effect note: `ammo.swap(...)` modelling needs main-thread
  confirmation in scope before spawn. Then batch **N2316–N2318** (`controlled()` + charging
  alternate — note: remote N2269 already owns a `charging()` gate; local `charging()` slice
  scope must check overlap with remote N2269 at spawn time); next_free_n ends at **2319**.
- allocations.json: N2311 done (6726d65), next_free_n 2312. N2304 held (ambient C, waits for
  Windows B).
- Push from Windows: local ahead/behind origin/main a95971b — recount at push time. Merge by
  hand in the spec at push time. No force-push.
