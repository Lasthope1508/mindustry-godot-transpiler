# Handoff — reconciliation round 9 (divergence #29, renumber N2258→N2296)

## Done
- **Renumber N2258→N2296 (BurstDrill liquid rows), commit 6df3b1f** (13 files, 1171+/1171-).
  --verify 58/58 + chain (13/13, 49/49, 26/26, 11/11, 54/54, 11/11, 28/28); targeted 4/4 (141);
  family BurstDrill+Drill 52/52 (864); wiring 32/32 (250); proof C07BurstDrillLiquidRowsProof
  **12 keys all true** (counted from JSON). SSOT unchanged 11685/1728/1671/3133. allocations.json:
  N2296 done, next_free_n 2297.
- **Re-gate GREEN (PID 2679, ~11:47–12:09): Ran 6205 in 1303.234s, failures=228, skipped=5,
  0 errors** — all 228 `unexpectedly None`. Log `hidden_files/full-suite-renumber-29-gate.log`
  (152601 byte). VM restart #28 ~11:38 hit the wiring run mid-flight (not the gate): symlink
  recreated, verified 4.6.2, wiring re-run green.
- **Docs (this commit):** report `docs/superpowers/reports/2026-11-19-c07-reconciliation-round9-renumber.md` +
  this handoff. Spec :330 + GOAL §5 :379 renumbered inside 6df3b1f. Done unchanged (1728).

## Divergence #29 (for the record)
- origin/main b02d14d → e9dfee4. Remote N2258 = TurretBuild.updateTile() recoilOffset draw
  (0ba552b) vs local N2258 = BurstDrillBuild.updateTile() liquid rows. Number-only collision,
  overlap 0/5 exact_exprs. Probe: `hidden_files/divergence-29-n2258-renumber-impact.md`.
- Merge-time flags (unresolved, decide at push/merge): remote N2253 warmup duplicates local N2265
  warmup (15/34 exprs) — ownership/dedup; remote recoil family N2254+N2255+N2256+N2257+N2258
  complementary, no dedup; remote N2258 re-promotes a formula already in local N741/N742
  (PortGame-era) — dedup at merge; remote adds 6 functions to SourceTurretBuildState.gd;
  `SourceItemTurretBuildState.gd` both-modified.

## Next — batch N2297–N2299 (merge in N order)
- **N2297 Turret micro-accessors → READY** (worktree `mindustry-wt-n2297-turret`: --verify 28/28,
  targeted 4/4 (64), family Turret 52/52 (727), wiring 32/32 (250), proof
  C07TurretMicroAccessorsProof 15 keys all true — all verified from disk by main thread; family +
  wiring ran in the worktree by continuation, log /tmp/n2297-family-wiring.log). 4 accessors only
  (drawrot/warmup/canControl/logicControlled); `controlled()` NOT included — see below.
- **N2298 BurstDrill senseObject/sense — wiring 4/9 in worktree** (verify 31/31, targeted 4/4
  (58), family BurstDrill+Drill per continuation, proof C07DrillSenseProof 9 keys all true).
  Remaining 5 wiring modules (adjacent_factory_live_loop, unit_factory_live_loop,
  turret_live_loop, continuous_liquid_turret_live_loop, power_graph_consumer_cheating) to run in
  the worktree before merging. Log /tmp/n2298-wiring.log (4 modules EXIT 0, 5th cut by timeout).
- **N2299 Game SoundControl.shouldPlay/isPlaying — DONE in worktree** (--verify 12/12, targeted
  4/4 (29), family 8/8, wiring 32/32 per worker, proof C07SoundControlShouldPlayProof 7 keys all
  true). Re-verify family + wiring at merge in main.
- Merge order: N2297 → N2298 → N2299. Each merge: copy non-SSOT files → register in main →
  targeted re-verify → family + wiring in main → commit. Then one batch gate + batch docs
  (Done 1728 → 1731).
- **controlled() deferred:** TurretBuild.controlled() (Turret.java:441-443, `unit.isPlayer()`) is
  0-hit in both ledgers. Scope file left it as "decide before spawn"; the cron's spawn brief did
  not carry the main-thread decision to fold it into N2297. Put it in batch N2300–N2302 as its own
  micro-slice or folded into the next Turret slice. Do NOT re-open N2297.
- Ambient C (N2264) still held — waits for Windows B (N2260).
- Push from Windows: local 65 ahead / 95 behind origin/main e9dfee4 (counted 11:51 +07; recount at
  push time). Merge by hand in the spec at push time. No force-push.

## Cron delivery (Isabella asked to resolve it 09:55)
- Job healthy (runs succeed). The stuck queue is draining: handoffs for 07:00–10:45 arrived
  ~10:38–11:23; the 11:30/11:45/12:00/12:15 runs arrived as late handoffs. Main thread keeps
  reporting directly every 15 minutes.
