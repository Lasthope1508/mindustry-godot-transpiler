# Handoff — reconciliation round 14 (renumber N2265 → N2308, divergence #36)

## Done
- **Renumber #36: local N2265 (Turret updateTile warmup) → N2308, commit `c4c89ee`** (16 files,
  446+/446-). Sed: register warmup + test + proof .gd + find_target register/test/proof +
  micro_accessors register/test/proof + GD comment + spec :337 (first occurrence only) + GOAL
  :393. Delete ledger key + 1 contract + 2 schemas + defense shard key + defense contract.
  Chain re-register **9 registers** in import order (warmup → find_target → tracking_range →
  write_read → is_active → min_range → status → micro_accessors → unit) — probe said 8; the
  9th (unit, N2307) was caught by a literal grep of N2265 in the ledger after the first 8.
  --verify 44/44 + 87/87 + 18/18 + 36/36 + 17/17 + 16/16 + 25/25 + 28/28 + 15/15; targeted
  4/4 (90); family Turret 60/60 (829); wiring 32/32 (250); proof
  C07TurretUpdateTileWarmupProof re-run in main, 18 keys all true. SSOT unchanged
  11699/1734/1682/3155. Done 1734.
- **Gate #36 — first attempt killed by VM restart #32 (~19:37):** PID 15834 died mid-run, log
  frozen at 5905 bytes, 0 "Ran" lines (kept as
  `hidden_files/full-suite-renumber-36-gate-killed-by-restart32.log`).
- **Gate #36 RERUN GREEN (PID 2723, ~19:48–20:06): Ran 6229 in 1096.514s, failures=234,
  skipped=5, 0 errors** — all 234 `unexpectedly None`. Log
  `hidden_files/full-suite-renumber-36-gate-rerun.log`.
- **Docs (this commit):** report `docs/superpowers/reports/2026-11-19-c07-reconciliation-round14-renumber.md`
  + this handoff. Spec row + GOAL §5 number already renumbered in c4c89ee.

## Next — renumber #37, then #38, then batch N2311–N2313
- **Renumber #37 (do first):** local N2266 (BurstDrill setStats) → **N2309**. Probe
  `hidden_files/divergence-37-n2266-renumber-impact.md` §5 (sed targets + chain order, 6
  registers). After the chain re-register, grep literal N2266 in the ledger (lesson from #36:
  probes can miss a register merged after they were written). Verify: --verify + targeted
  (test_c07_burst_drill_set_stats) + family BurstDrill+Drill + wiring + proof
  C07BurstDrillSetStatsProof re-run (expect 5 keys — count from JSON when run) → commit →
  re-gate → docs round 15.
- **Renumber #38 (do second):** local N2267 (Radar write/read) → **N2310**. Probe
  `hidden_files/divergence-38-n2267-renumber-impact.md` §5 (sed targets + chain order, 5
  registers: write/read → canPickup → draw → drawSelect → drawPlace). Same literal-grep
  check after the chain. Verify: --verify + targeted (test_c07_radar_write_read) + family
  Radar + wiring + proof C07RadarWriteReadProof re-run (expect 7 domain keys / 10 total —
  count from JSON when run) → commit → re-gate → docs round 16.
- **Batch N2311–N2313 after docs #38** (hasAmmo / BurstDrill draw / isDark): scope file
  `hidden_files/next-batch-scope-after-n2307.md` (base c4c89ee) still carries pre-#38 labels
  N2310–N2312 / N2313–N2315 — relabel +1 before spawning. Reserve N2311–N2313 by script +
  write spawn lock BEFORE spawning; worktrees from latest HEAD; brief includes editor-import
  uid_cache + port-7777-free check + Godot symlink check + arc/mindustry-upstream symlinks.
  hasAmmo side-effect note: `ammo.swap(...)` modelling needs main-thread confirmation in
  scope before spawn. Then batch **N2314–N2316** (`controlled()` + charging alternate);
  next_free_n ends at **2317**.
- allocations.json: N2308 done (c4c89ee), next_free_n 2309. N2304 held (ambient C, waits for
  Windows B). N2285/N2287 stale 'reserved' fixed to done (fd76c4f/81d116f).
- Push from Windows: local ahead/behind origin/main 410ac5d — recount at push time. Merge by
  hand in the spec at push time. No force-push.
