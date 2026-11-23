# Handoff — reconciliation round 6 DONE + re-gate GREEN

- Renumber N2250→N2288 (3760228) + N2251→N2289 (128c9f9) + N2252→N2290 (ca0a252) + N2253→N2291 (4edf8ca)
  + N2254→N2292 (0573346) + N2255→N2293 (23a5ed1), all replayed + committed by main thread (A''' chosen by
  main thread after Isabella objected to mid-task widget decisions).
- Re-gate GREEN: Ran 6193 in 1102.971s, failures=225, skipped=5, 0 errors — all Godot-absent (verified from log).
- Docs (this commit): spec rows already renumbered in place inside each renumber commit + GOAL §5 6 blocks
  (scene hashes → renumber commits) + report + this handoff. Done 1725, SSOT 11655/1725/1664/3119.
  allocations.json: N2288–N2293 done, next_free_n 2294.
- Cron 15m delivery stuck: 5 finished reports pending delivery to chat (07:00–08:00); main thread reports
  directly every 15 min until it unclogs. Do NOT re-send the stale reports.
- **NEXT: divergence #27** — renumber local N2256 (BurstDrill updateTile) → **N2294**, then re-gate + docs #27,
  then spawn batch N2285–N2287 (scope re-verified). Probe:
  `hidden_files/divergence-27-n2256-renumber-impact.md` (15 ledger entries mention N2256).
- Ambient C (N2264) still held — waits for Windows B (N2260).
- Push: local 55 ahead / 85 behind origin/main 0315a17; merge spec by hand at push time. No force-push.
  Merge-time flags: warmup ownership/dedup (remote N2253 vs local N2265), remote recoil family
  N2254+N2255+N2256 (complementary, no dedup), `SourceItemTurretBuildState.gd` both-modified.
