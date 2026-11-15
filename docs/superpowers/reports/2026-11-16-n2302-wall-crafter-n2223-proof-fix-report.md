# Report N2302 — WallCrafter N2223 proof fix (FIX slice)

**Slice:** N2302 — WallCrafter N2223 proof stale efficiency_factor seed. **Wave:** advances-10.
**Commit:** `eb9c292b` on `slice/N2302-wall-crafter-n2223-proof-fix` (base `fa627ace`).
**Files:** 1, +14/−7.

## Source

N2301 stamps `frame["efficiency_factor"]` unconditionally each enabled tick from
`frame["wall_edge_tiles"]` (WallCrafter.getEfficiency, WallCrafter.java:141-180).
The N2223 proof seeded `efficiency_factor = 1.0` directly; the N2301 stamp
overwrites it with 0.0 (empty edge), so the live-tick key (which expects eff 1.0 /
time 0.5) fails on a Windows Godot run. Same staleness class as N2300 (live-tick
keys only — pure-call keys calling the advance directly with explicit inputs are
NOT stale).

## Implementation

Proof file only (`C07WallCrafterUpdateTileProof.gd`): seed `wall_edge_tiles`
summing to 1.0 instead of seeding `efficiency_factor`. The live-tick crusher is
cliff-crusher size 2 (Blocks.java:3007); seeded 2 solid tiles × 0.5 (total 1.0,
mirroring the N2301 proof pattern). Expected values unchanged. Pure-call keys
(:56-67) untouched.

## Commits

- Slice: `eb9c292b` (1 file, +14/−7).
- Integration cherry-pick: `92edc7ee` (clean).

## Tests

Targeted `tests.test_c07_wall_crafter_update_tile`: 3/4 PASS + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this VM (user order
2026-11-15). Test file untouched; the proof .gd change is invisible to the VM
gate (the proof test already fails Godot-absent).
Full gate (wave advances-10 integration, PID 1755, 04:31–04:53, run 2 — run 1 PID 20261 killed by VM restart #8 ~04:30, no footer): Ran 6302 tests in 1216.770s, FAILED (failures=252, skipped=5), 0 errors — 252/252 Godot-absent `AssertionError: unexpectedly None` (248 inherited + 4 new proof tests N2304/N2305/N2306/N2308; N2302/N2303/N2307 add no test).

## SSOT / DEFERRED

SSOT +0/+0/+0/+0 confirmed (fix slice: no new pure, no new ledger entry, no new
proof test). DEFERRED unchanged.

## Godot debt

RE-RUN of proof N2223 (`C07WallCrafterUpdateTileProof`, 8 keys incl. 3 registry)
— the fixture changed, so the Windows Godot agent must re-run it. Recorded in
GOAL.md §5 (re-run note on the N2223 entry).
