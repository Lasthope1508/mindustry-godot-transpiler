# Report N2357 — PayloadMassDriver large variant verification

**Slice:** N2357 — PayloadMassDriver large variant verification (DEFERRED
#7). **Wave:** advances-17. **Commit:** `31f7878ef` on
`slice/N2357-pmd-large-variant` (base `9282b27a`). **Files:** 3, +440/−0.

## Source

Java: Blocks.java:6617-6639 (large variant def rows — size 5, range 2100,
charge time 100, accepts size 32) and PayloadMassDriver.java:24-30. No
exact exprs (verification slice — no new pure).

## Implementation

Verification slice: the driver is untouched, no bug found (no small-def
hardcode on the logic path — the large variant flows through the same
advance/tick as the small def). Tile-size catch: game `tile_size` = 32 (not
8) — the live link range in tiles differs from Java; a pre-existing driver
unit question, flagged by the worker, NOT fixed here (coordinator backlog).

## Commits

- Slice: `31f7878ef` (3 files, +440/−0).
- Integration cherry-pick: `f9ef0289e` (clean).

## Tests

Targeted (new module `tests.test_c07_payload_mass_driver_large_variant`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Siblings Ran 20 (15 PASS +
5 proof Godot-absent), 0 other errors.
Full gate (wave advances-17 integration, PID 12882, 10:58–11:23): Ran
6468 tests in 1457.080s, FAILED (failures=293, skipped=5), 0 errors —
293/293 Godot-absent `AssertionError: unexpectedly None` (287 inherited +
6 new proof tests N2351–N2354, N2356–N2357; N2355 has no proof test).

## SSOT / DEFERRED

SSOT single-slice **+0** (no ledger entry, the +0 precedent of
N2307/N2337/N2300…). Audit stays 1336.
DEFERRED **#7 resolved at merge** (no new entry).

## Godot debt

- NEW proof `C07PayloadMassDriverLargeVariantProof` (5 keys:
  `large_def_accepts_size_32_live`, `large_def_catalog_rows`,
  `large_def_charge_time_100`, `large_def_range_2100_live_link`,
  `large_def_size_5_move_out_dest`) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run.
- Backlog: the PMD live link tile-size unit question (game tile_size 32 vs
  Java 8 — live link range in tiles differs from Java).
