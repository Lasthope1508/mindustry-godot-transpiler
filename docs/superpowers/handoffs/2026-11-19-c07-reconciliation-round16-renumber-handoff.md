# Handoff — reconciliation round 16 (renumber N2267 → N2310, divergence #38)

## Done
- **Renumber #38: local N2267 (Radar write/read) → N2310, commit `49f8137`** (17 files,
  1491+/1491-). Sed: register write/read + test + proof .gd + spec :339 (first occurrence
  only) + GOAL :397 + canPickup alias + proof-debt strings in 4 downstream registers +
  3 proof .gd comments. Probe missed 1 line (canPickup register :49 DEFERRED-carry comment)
  — caught by a full-tree grep after the first sed pass. Delete ledger key + 2 contracts +
  4 schemas + defense contract (write only) + defense slice key. Chain re-register **5
  registers** in the linear Radar chain (write/read → canPickup → draw → drawSelect →
  drawPlace). --verify 26/26 + 6/6 + 18/18 + 14/14 + 20/20; targeted 4/4 (56); family Radar
  40/40 (392); wiring 32/32 (250); proof C07RadarWriteReadProof re-run in main, 7 domain
  keys (10 total) all true. Literal N2267 in the ledger = 0 (N2310 = 16). SSOT unchanged
  11699/1734/1682/3155. Done 1734.
- **Gate #38 GREEN (PID 13542, ~21:34–21:52): Ran 6229 in 1112.045s, failures=234,
  skipped=5, 0 errors** — all 234 `unexpectedly None`. Log
  `hidden_files/full-suite-renumber-38-gate.log`. No VM restart during the gate (uptime 2:17
  at the 21:55 check).
- **Docs (this commit):** report `docs/superpowers/reports/2026-11-19-c07-reconciliation-round16-renumber.md`
  + this handoff. Spec row + GOAL §5 number already renumbered in 49f8137.

## Next — renumber #39, then batch N2312–N2314
- **Renumber #39 (do first, right after this docs commit):** local N2268 (Turret fogRadius)
  → **N2311**. Probe `hidden_files/divergence-39-n2268-renumber-impact.md` §5 (sed targets +
  chain order, 11 registers: fogRadius → estimateDps → warmup → findTarget → trackingRange
  → writeRead → isActive → minRange → status → microAccessors → unit, + re-run
  `register_c07_drill_sense.py`). After the probe-listed sed, grep literal N2268 across the
  whole tree and sed every live reference (lesson from #37/#38). After the chain re-register,
  grep literal N2268 in the ledger (lesson from #36). Caveats: precedent pairs
  "N2268/N2249" and "N2268/N2261" are half-stale — re-point only the N2268 half, keep the
  stale half; alias `N2237_DEFERRED` in the own register is stale since round 3 but runs
  correctly — do not rename. Verify: --verify + targeted (test_c07_turret_fog_radius) +
  family Turret + wiring + proof C07TurretFogRadiusProof re-run (expect 7 domain keys / 10
  total — count from JSON when run) → commit → re-gate → docs round 17.
- **Batch N2312–N2314 after docs #39** (hasAmmo / BurstDrill draw / isDark): scope file
  `hidden_files/next-batch-scope-after-n2311.md` (refreshed by a cron research agent ~21:5x,
  base 49f8137) — relabel-check against allocations.json before spawning. Reserve N2312–N2314
  by script + write spawn lock BEFORE spawning; worktrees from latest HEAD; brief includes
  editor-import uid_cache + port-7777-free check + Godot symlink check + arc/mindustry-upstream
  symlinks. hasAmmo side-effect note: `ammo.swap(...)` modelling needs main-thread
  confirmation in scope before spawn. Then batch **N2315–N2317** (`controlled()` + charging
  alternate); next_free_n ends at **2318**.
- allocations.json: N2310 done (49f8137), next_free_n 2311. N2304 held (ambient C, waits for
  Windows B).
- Push from Windows: local ahead/behind origin/main 6cfc8b8 — recount at push time (cron
  21:30 counted 86 ahead / 149 behind, unverified by main thread). Merge by hand in the
  spec at push time. No force-push.
