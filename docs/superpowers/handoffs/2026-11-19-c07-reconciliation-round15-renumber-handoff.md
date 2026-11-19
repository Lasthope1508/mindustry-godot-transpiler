# Handoff — reconciliation round 15 (renumber N2266 → N2309, divergence #37)

## Done
- **Renumber #37: local N2266 (BurstDrill setStats) → N2309, commit `26fbb10`** (21 files,
  1711+/1711-). Sed: register setStats + test + proof .gd + spec :338 (first occurrence
  only) + GOAL :395 + downstream comments (write_read :46/:48, draw_select :44,
  drill_ambient_volume :29, should_ambient_sound :36, test drill_set_stats :33/:36, proof
  DrillSetStatsProof.gd :38/:41, GD :377 TRAP comment). Probe missed 6 comment lines in the
  N2271/N2280 registers — caught by a full-tree grep after the first sed pass. Delete ledger
  key + 1 contract + 2 schemas + production contract + production shard key. Chain re-register
  **6 registers** in import order (setStats → ambientVolume → Drill.ambientVolume →
  Drill.setStats → write/read → shouldAmbientSound). --verify 26/26 + 11/11 + 11/11 + 54/54
  + 28/28 + 20/20; targeted 4/4 (52); family BurstDrill+Drill 56/56 (922); wiring 32/32
  (250); proof C07BurstDrillSetStatsProof re-run in main, 5 domain keys (8 total) all true.
  Literal N2266 in the ledger = 0 (N2309 = 24). SSOT unchanged 11699/1734/1682/3155.
  Done 1734.
- **Gate #37 GREEN (PID 8618, ~20:44–21:02): Ran 6229 in 1084.563s, failures=234,
  skipped=5, 0 errors** — all 234 `unexpectedly None`. Log
  `hidden_files/full-suite-renumber-37-gate.log`.
- **Docs (this commit):** report `docs/superpowers/reports/2026-11-19-c07-reconciliation-round15-renumber.md`
  + this handoff. Spec row + GOAL §5 number already renumbered in 26fbb10.

## Next — renumber #38, then #39, then batch N2312–N2314
- **Renumber #38 (do first):** local N2267 (Radar write/read) → **N2310**. Probe
  `hidden_files/divergence-38-n2267-renumber-impact.md` §5 (sed targets + chain order, 5
  registers: write/read → canPickup → draw → drawSelect → drawPlace). After the probe-listed
  sed, grep literal N2267 across the whole tree and sed every live reference (lesson from
  #37). After the chain re-register, grep literal N2267 in the ledger (lesson from #36).
  Verify: --verify + targeted (test_c07_radar_write_read) + family Radar + wiring + proof
  C07RadarWriteReadProof re-run (expect 7 domain keys / 10 total — count from JSON when run)
  → commit → re-gate → docs round 16.
- **Renumber #39 (do second):** local N2268 (Turret fogRadius) → **N2311** (confirm from the
  probe `hidden_files/divergence-39-n2268-renumber-impact.md` — agent running at docs time;
  N2310 is #38's). Same grep-twice discipline. Verify: --verify + targeted
  (test_c07_turret_fog_radius) + family Turret + wiring + proof C07TurretFogRadiusProof
  re-run (count keys from JSON when run) → commit → re-gate → docs round 17.
- **Batch N2312–N2314 after docs #39** (hasAmmo / BurstDrill draw / isDark): scope file
  `hidden_files/next-batch-scope-after-n2310.md` (base 26fbb10) still carries pre-#39 labels
  N2311–N2313 / N2314–N2316 — relabel +1 before spawning. Reserve N2312–N2314 by script +
  write spawn lock BEFORE spawning; worktrees from latest HEAD; brief includes editor-import
  uid_cache + port-7777-free check + Godot symlink check + arc/mindustry-upstream symlinks.
  hasAmmo side-effect note: `ammo.swap(...)` modelling needs main-thread confirmation in
  scope before spawn. Then batch **N2315–N2317** (`controlled()` + charging alternate);
  next_free_n ends at **2318**.
- allocations.json: N2309 done (26fbb10), next_free_n 2310. N2304 held (ambient C, waits for
  Windows B).
- Push from Windows: local ahead/behind origin/main 6cfc8b8 — recount at push time. Merge by
  hand in the spec at push time. No force-push.
