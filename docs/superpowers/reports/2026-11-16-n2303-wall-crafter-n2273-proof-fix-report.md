# Report N2303 — WallCrafter N2273 proof fix (FIX slice)

**Slice:** N2303 — WallCrafter N2273 proof stale efficiency_factor seed. **Wave:** advances-10.
**Commit:** `51feaff4` on `slice/N2303-wall-crafter-n2273-proof-fix` (base `fa627ace`).
**Files:** 1, +23/−10.

## Source

N2301 stamps `frame["efficiency_factor"]` unconditionally each enabled tick from
`frame["wall_edge_tiles"]` (WallCrafter.getEfficiency, WallCrafter.java:141-180).
The N2273 proof's `timer_consume_removes_graphite` key needs eff > 0 for the
consume gate; the proof seeded `efficiency_factor` directly, and the N2301 stamp
overwrites it with 0.0 (empty edge), so the key fails on a Windows Godot run.
Same staleness class as N2300/N2302.

## Implementation

Proof file only (`C07WallCrafterTimerConsumeProof.gd`): seed `wall_edge_tiles`
summing to 1.0. Both frames are large-cliff-crusher size 3 (Blocks.java:3021);
seeded 3 tiles 0.5+0.25+0.25 = 1.0 (exact in binary FP). Frame C zero-eff
intentionally gets NO edge tiles (the stamp yields 0.0, the gate stays closed,
same expected outcome). Frame D (cliff-crusher) untouched — its key doesn't
depend on eff. Expected values unchanged.

## Commits

- Slice: `51feaff4` (1 file, +23/−10).
- Integration cherry-pick: `53c1f97e` (clean).

## Tests

Targeted `tests.test_c07_wall_crafter_timer_consume`: 3/4 PASS + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this VM (user order
2026-11-15). Test file untouched.
Full gate (wave advances-10 integration, PID 1755, 04:31–04:53, run 2 — run 1 PID 20261 killed by VM restart #8 ~04:30, no footer): Ran 6302 tests in 1216.770s, FAILED (failures=252, skipped=5), 0 errors — 252/252 Godot-absent `AssertionError: unexpectedly None` (248 inherited + 4 new proof tests N2304/N2305/N2306/N2308; N2302/N2303/N2307 add no test).

## SSOT / DEFERRED

SSOT +0/+0/+0/+0 confirmed (fix slice: no new pure, no new ledger entry, no new
proof test). DEFERRED unchanged.

## Godot debt

RE-RUN of proof N2273 (`C07WallCrafterTimerConsumeProof`) — the fixture changed,
so the Windows Godot agent must re-run it. Recorded in GOAL.md §5 (re-run note on
the N2273 entry).
