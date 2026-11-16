# Report N2400 — LaunchPad advanced variant verification

**Slice:** N2400 — LaunchPad advanced variant verification
(verification-only, the N2357 precedent): the advanced
launch-pad def rows are verified against the live driver —
no driver change. **Wave:** advances-22. **Commit:** `062a920e8`
on `slice/N2400-launch-pad-advanced-variant-verification` (base
`78a74e152`). **Files:** 3, +503/−0 (no register/ledger).

## Source

Java: Blocks.java:6804 (advanced-launch-pad def),
:6794 (launch-pad def), :6805 (`liquidCapacity 40f`);
LaunchPad.java:32 (class default `launchTime` 1f).

## Implementation

Verification-only: the driver is untouched. Verified: power 8f,
size 4, launchTime 1800f (sense 900/1800 = 0.5), oil row
0.15/tick, hitbox 32.0 vs 24.0.

**⚠️ DISCREPANCY (reported, NOT fixed):** `liquidCapacity 40f`
(Blocks.java:6805) does NOT flow anywhere in the port — the
catalog has no such key for either launch-pad def (31 other
blocks HAVE it), and the driver never reads `liquidCapacity`;
nothing caps the advanced pad's oil store at 40f. Follow-up
slice (advances-23 candidate): add `liquidCapacity` 40.0 to the
catalog row `advanced-launch-pad` (+ check the plain def derives
10f per Block.init :1407-1419) and/or wire the cap into the
liquid store.

## Commits

- Slice: `062a920e8` (3 files, +503/−0).
- Integration cherry-pick: `d2f510376` (clean).

## Tests

Targeted (new module
`tests.test_c07_launch_pad_advanced_variant`): 2/3 PASS + proof
test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). (3 tests, not 4 — no
registration test: no register in a verification-only slice.)
Full gate (wave advances-22 integration, PID 7151, from 14:50):
Ran 6602 tests in 1564.685s, FAILED (failures=326, skipped=5), 0 errors — 326/326 Godot-absent `AssertionError: unexpectedly None` (319 inherited + 7 new proof tests N2394–N2400; N2401 adds no test)..

## SSOT / DEFERRED

SSOT single-slice **+0** (verification-only, no ledger entry —
the N2357 precedent). Audit stays 1336. DEFERRED **#46
RESOLVED** (coordinator deletes at merge — no register list).

## Godot debt

- NEW proof `C07LaunchPadAdvancedVariantProof` (6 keys:
  `advanced_def_catalog_rows`,
  `advanced_def_launch_time_1800_sense`,
  `advanced_def_launch_time_1800_advance`,
  `advanced_def_oil_row_live`, `advanced_def_size_4_hitbox`,
  `advanced_def_live_tick_stamps`) — written but NEVER run;
  debt in GOAL.md §5.
- No old proof needs a re-run.
