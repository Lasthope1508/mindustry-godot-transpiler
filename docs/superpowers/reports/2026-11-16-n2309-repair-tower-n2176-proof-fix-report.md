# Report N2309 — RepairTower N2176 proof fix (FIX slice)

**Slice:** N2309 — RepairTower N2176 proof stale ozone seed. **Wave:** advances-11.
**Commit:** `6e4484b0` on `slice/N2309-repair-tower-n2176-proof-fix` (base `18dcabf2`).
**Files:** 1, +21/−3.

## Source

N2250 added the REQUIRED ozone liquid row (RepairTower consumes ozone 3f/60f,
Blocks.java:6583). The N2176 proof (`C07RepairTowerPowerStatusProof`) seeds no
ozone, so the machinery folds the live-tick efficiency to 0 instead of 0.5 and
the `efficiency_folds_power_min` key (:77) fails on a Windows Godot run. Same
staleness class as N2300/N2302/N2303 (live-tick keys only — pure-call keys
calling the advance directly with explicit inputs are NOT stale).

## Implementation

Proof file only (`C07RepairTowerPowerStatusProof.gd`): seed ozone 0.1 on the
sprite liquids meta (pattern N2306) + 3 preloads; stale comment rewritten. One
seed suffices — tick 1 consumes ~0.025, tick 2 asserts 0.0 regardless of ozone.
Expected values unchanged.

## Commits

- Slice: `6e4484b0` (1 file, +21/−3).
- Integration cherry-pick: `4f45e9f8` (clean).

## Tests

Targeted `tests.test_c07_repair_tower_power_status`: 3/4 PASS + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this VM (user order
2026-11-15). Siblings Ran 16 = 12 PASS + 4 proof, 0 other failures. Test file
untouched; the proof .gd change is invisible to the VM gate (the proof test
already fails Godot-absent).
Full gate (wave advances-11 integration, PID 7620, 05:08–05:30): Ran 6314 tests in 1275.835s, FAILED (failures=255, skipped=5), 0 errors — 255/255 Godot-absent `AssertionError: unexpectedly None` (252 inherited + 3 new proof tests N2313/N2314/N2315; N2309/N2310/N2311/N2312 add no test).

## SSOT / DEFERRED

SSOT +0/+0/+0/+0 confirmed (fix slice: no new pure, no new ledger entry, no new
proof test). DEFERRED unchanged.

## Godot debt

RE-RUN of proof N2176 (`C07RepairTowerPowerStatusProof`) — the fixture changed,
so the Windows Godot agent must re-run it. Recorded in GOAL.md §5 (re-run note
on the N2176 entry).
