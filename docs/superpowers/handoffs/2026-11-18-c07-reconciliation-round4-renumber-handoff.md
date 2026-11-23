# Handoff — C07 reconciliation round 4 docs (2026-11-18 ~13:4x +07)

## Done
- Round 4 renames committed: N2244→N2268 83bf0bc (10 files, 240/240;
  --verify 21/21; targeted 4/44; Turret 28/343) + N2245→N2269 2b49c54
  (10 files, 519/519; --verify 13/13; targeted 4/28; BurstDrill
  28/575). Both wiring 32/235. SSOT unchanged 11615/1712/1644/3079.
- Gate round 4 GREEN (Ran 6141 in 1027.064s, failures=212, skipped=5,
  0 errors; log `full-suite-reconciled-round4-gate.log`; PID 2361).
- Docs commit (this handoff's commit): spec N2244→N2268 + N2245→N2269
  in place with renumber notes + gate text; GOAL §5 blocks renamed
  (scene commits 83bf0bc / 2b49c54); report + this handoff. Done stays
  1712.
- Allocation guarantee in place: `allocations.json` is the single N
  source (Isabella ~13:09); cron body carries the same rule.
- origin/main verified 53bac8a — no new divergence. Local 25 ahead /
  20 behind.

## Next (in order)
1. Turret findTarget — **N2270** (next free, scope ready in
   `hidden_files/next-batch-scope-after-n2265.md` §1). Assign ONLY by a
   main-thread decision (allocations.json rule: never infer, never take
   a reserved number). One slice, own worktree from latest HEAD, never
   parallel with another slice touching SourceTurretBuildState.gd.
   After findTarget: BurstDrill ambientVolume (BurstDrill.java:123-125)
   → draw (132-180, last) → Drill.setStats (super); Radar canPickup
   (76-78, micro) → drawPlace/drawSelect/draw (render-only). Ambient C
   (N2264) waits for Windows B (N2260).
2. PointDefenseTurret family ownership — still waiting on Isabella.
   Windows line: 7 consecutive slices N2239–N2245.
3. Push from Windows: local 25 ahead / 20 behind origin/main 53bac8a;
   hand-merge at the spec. No force-push. Do NOT start C08.

## Numbers to trust (verified from disk/git/log, not from memory)
- N2268 83bf0bc (10 files, 240 ins/240 del; --verify 21/21; targeted
  4/44; Turret 28/343; proof C07TurretFogRadiusProof 10 keys).
  N2269 2b49c54 (10 files, 519 ins/519 del; --verify 13/13; targeted
  4/28; BurstDrill 28/575; proof C07BurstDrillIconsProof 6 keys).
- Round-4 gate: Ran 6141 in 1027.064s, failures=212, skipped=5,
  0 errors (212 FAIL blocks, 0 ERROR, all "AssertionError:
  unexpectedly None").
- Docs batch N2265–N2267: 41d2593 (spec 3 rows + Done 1709→1712;
  N2265 proof 15 keys, not 4).
- VM restart #16 ~13:17 (symlink only; hit mid-N2269, recovered).
