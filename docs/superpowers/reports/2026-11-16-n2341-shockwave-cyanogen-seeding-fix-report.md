# Report N2341 — ShockwaveTower old-proof cyanogen seeding fix

**Slice:** N2341 — ShockwaveTower old-proof cyanogen seeding fix (fixes the
4 proofs gone stale from the N2331 liquid row). **Wave:** advances-15.
**Commit:** `bc00c12c` on `slice/N2341-shockwave-cyanogen-seeding-fix`
(base `c89f1d09`). **Files:** 4, +116/−8.

## Source

Java: ConsumeLiquids.efficiency (ConsumeLiquids.java:52-60, min over
stacks). The N2331 row is REQUIRED: a live tick without seeded cyanogen
folds efficiency to 0. PortGame binds no store for ShockwaveTower (the
catalog lacks consumeLiquids); the tick lazy-inits an empty store → fold
0. The 4 stale proofs: N2177, N2187, N2318, N2327 (flagged STALE in the
advances-14 docs; N2247 was NOT stale).

## Implementation

4 proof scenes only (no .tscn/driver/test changes): preload
LiquidModule/PlacedBlock/ContentRegistry → resolve cyanogen_id →
`source_initialize_building_liquids_state(sprite, true, catalog)` →
`source_set_state(store, cyanogen_id, 1.0)` before the live tick (the
N2331 pattern, NOT the plain N2323 pattern). Margins (consumption/tick =
0.025 × eff): N2177 80× (2 ticks, 0.0125), N2187 ~27× (3 ticks, 0.0375),
N2318 40×/tower, N2327 40×. Also fixed 2 stale comments "first pass holds
only the power row" (N2177/N2187).

## Commits

- Slice: `bc00c12c` (4 files, +116/−8).
- Integration cherry-pick: `c8e76577` (clean).

## Tests

Targeted (4 old modules): Ran 16 = 12 PASS + 4 proof Godot-absent,
identical before/after, 0 regression.
Full gate (wave advances-15 integration, PID 1755, 08:31–08:52): Ran 6415 tests in 1285.515s, FAILED (failures=280, skipped=5), 0 errors — 280/280 Godot-absent `AssertionError: unexpectedly None` (275 inherited + 5 new proof tests N2338/N2339/N2340/N2342/N2343).

## SSOT / DEFERRED

SSOT **+0** (fix slice, no register, no ledger entry). DEFERRED **−1**
(#326 ShockwaveTower old-proof cyanogen seeding resolved — applied by the
coordinator at the DEFERRED merge since N2341 has no register). Audit
stays 1336.

## Godot debt

- NO new proof. The 4 proofs (N2177/N2187/N2318/N2327) never ran before,
  so they are NOT re-runs — the coordinator removes the 4 STALE notes from
  their GOAL.md §5 entries in the advances-15 docs.
