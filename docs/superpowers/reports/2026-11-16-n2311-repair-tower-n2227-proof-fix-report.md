# Report N2311 — RepairTower N2227 proof fix (FIX slice)

**Slice:** N2311 — RepairTower N2227 proof stale ozone seed. **Wave:** advances-11.
**Commit:** `016da108` on `slice/N2311-repair-tower-n2227-proof-fix` (base `18dcabf2`).
**Files:** 1, +17/−3.

## Source

N2250 added the REQUIRED ozone liquid row (RepairTower consumes ozone 3f/60f,
Blocks.java:6583). The N2227 proof (`C07RepairTowerUpdateTileProof`) seeds no
ozone, so the machinery folds the live-tick efficiency to 0 instead of 0.5 and
the `warmup_approaches_efficiency_when_healing` key (:120) fails on a Windows
Godot run. Same staleness class as N2300/N2302/N2303 (live-tick keys only).

## Implementation

Proof file only (`C07RepairTowerUpdateTileProof.gd`): seed ozone 0.1 (pattern
N2250 Tower B fill / N2306) + 3 preloads; comment :98–102 rewritten. Pure-call
keys (:48–82) untouched. Expected values unchanged (eff 0.5, warmup 0.04,
total_progress 1/120, heal [0.75]).

## Commits

- Slice: `016da108` (1 file, +17/−3).
- Integration cherry-pick: `075dbb82` (clean).

## Tests

Targeted `tests.test_c07_repair_tower_update_tile`: 3/4 PASS + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this VM (user order
2026-11-15). Siblings Ran 16 = 12 PASS + 4 proof, 0 other failures. Test file
untouched; the proof .gd change is invisible to the VM gate (the proof test
already fails Godot-absent).
Full gate (wave advances-11 integration, PID 7620, 05:08–05:30): Ran 6314 tests in 1275.835s, FAILED (failures=255, skipped=5), 0 errors — 255/255 Godot-absent `AssertionError: unexpectedly None` (252 inherited + 3 new proof tests N2313/N2314/N2315; N2309/N2310/N2311/N2312 add no test).

## SSOT / DEFERRED

SSOT +0/+0/+0/+0 confirmed (fix slice: no new pure, no new ledger entry, no new
proof test). DEFERRED unchanged.

## Godot debt

RE-RUN of proof N2227 (`C07RepairTowerUpdateTileProof`) — the fixture changed,
so the Windows Godot agent must re-run it. Recorded in GOAL.md §5 (re-run note
on the N2227 entry).
