# Report N2310 — RepairTower N2213 proof fix (FIX slice)

**Slice:** N2310 — RepairTower N2213 proof stale ozone seed. **Wave:** advances-11.
**Commit:** `5fa4b0f3` on `slice/N2310-repair-tower-n2213-proof-fix` (base `18dcabf2`).
**Files:** 1, +23/−4.

## Source

N2250 added the REQUIRED ozone liquid row (RepairTower consumes ozone 3f/60f,
Blocks.java:6583). The N2213 proof (`C07RepairTowerShouldConsumeProof`) seeds no
ozone, so the machinery folds the live-tick efficiency to 0 instead of 0.5 and
the `efficiency_folds_power_when_gate_true` key (:98) fails on a Windows Godot
run. Same staleness class as N2300/N2302/N2303 (live-tick keys only).

## Implementation

Proof file only (`C07RepairTowerShouldConsumeProof.gd`): seed ozone 0.1 before
EACH tick (re-seed + re-fetch meta before the gate-true tick). The worker
verified `source_set_state` mutates in place (SourceLiquidModuleState.gd:29),
so the re-seed lands on the same store the tick reads. Expected values
unchanged.

## Commits

- Slice: `5fa4b0f3` (1 file, +23/−4).
- Integration cherry-pick: `f8f6e56f` (clean).

## Tests

Targeted `tests.test_c07_repair_tower_should_consume`: 3/4 PASS + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this VM (user order
2026-11-15). Siblings Ran 16 = 12 PASS + 4 proof, 0 other failures. Test file
untouched; the proof .gd change is invisible to the VM gate (the proof test
already fails Godot-absent).
Full gate (wave advances-11 integration, PID 7620, 05:08–05:30): Ran 6314 tests in 1275.835s, FAILED (failures=255, skipped=5), 0 errors — 255/255 Godot-absent `AssertionError: unexpectedly None` (252 inherited + 3 new proof tests N2313/N2314/N2315; N2309/N2310/N2311/N2312 add no test).

## SSOT / DEFERRED

SSOT +0/+0/+0/+0 confirmed (fix slice: no new pure, no new ledger entry, no new
proof test). DEFERRED unchanged.

## Godot debt

RE-RUN of proof N2213 (`C07RepairTowerShouldConsumeProof`) — the fixture
changed, so the Windows Godot agent must re-run it. Recorded in GOAL.md §5
(re-run note on the N2213 entry).
