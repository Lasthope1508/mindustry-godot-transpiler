# Report N2457 — StackConveyor setStats rows

**Slice:** N2457 — StackConveyor.setStats(): one pure-only pure
models the itemsMoved stat. **Wave:** advances-30. **Commit:**
`aa4f02419` on `slice/N2457-stack-conveyor-set-stats-rows` (base
`4e4dc1a7c`). **Files:** 5, +758/−1.

## Source

setStats() (StackConveyor.java:64-68): `super.setStats();
stats.add(Stat.itemsMoved, Mathf.round(itemCapacity * speed * 60),
StatUnit.itemsSecond);`

## Implementation

One pure-only pure (no tick wiring):
`source_stack_conveyor_stats_state(item_capacity, speed)` →
`{items_moved_per_second, stat_key, stat_unit}`.
items_moved_per_second = `int(floor(item_capacity * speed * 60 +
0.5))` — the Java-exact rounding made visible (the
SourceBlockRequirementsState precedent). stat_key = "itemsMoved"
(Stat.java:52); stat_unit = "itemsSecond" (StatUnit.java:20) — the
pure returns TOKENS, not localized strings (the N2450 precedent).

**Verify-first findings:**
1. **Brief's def names were WRONG — Java wins:** there is NO
   `stack-conveyor` or `large-stack-conveyor` def in Blocks.java.
   The only two StackConveyor defs are **plastanium-conveyor**
   (Blocks.java:2084, speed `4f/60f`, itemCapacity 10 → **40**)
   and **surge-conveyor** (Blocks.java:2237, speed `5f/60f`,
   itemCapacity 10 → **50**). Class defaults: speed `0f`
   (StackConveyor.java:38), itemCapacity 10 (:52) → **0**. The
   proof keys are named after the real defs
   (`stats_plastanium_def` / `stats_surge_def`), not the brief's
   `stats_stack_def` / `stats_large_def`.
2. **Mathf.round semantics verified:** `round(float)` is
   `(int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT` (arc
   Mathf.java:500-502, BIG_ENOUGH_ROUND = 16384.5f) = `floor(v +
   0.5)` for non-negative v. GDScript `round()` (half away from
   zero) agrees on non-negative values, but the port uses
   `int(floor(v + 0.5))` explicitly. The proof pins the edge:
   4.5→5, 2.5→3, 4.2→4 (all double-exact, checked in Python first).
   Float32-vs-double checked: Java float32 gives 40.0 / 50.0000038,
   GDScript double gives 40.0 / 49.99999999999999 — both round to
   40 / 50.

## Commits

- Slice: `aa4f02419` (5 files, +758/−1).
- Integration cherry-pick: `3f677ee5d` (clean).

## Tests

Targeted (new module
`tests.test_c07_stack_conveyor_set_stats_rows`): 3/4 PASS
(registration, exact-evidence 14/14 exprs verbatim, row-state) +
proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). RED confirmed
first (Ran 4, 2 failures + 2 errors).
Full gate (wave advances-30 integration, PID 1777, from 22:30): Ran 6818 tests in 1589.793s, FAILED (failures=379, skipped=5), 0 errors — 379/379 Godot-absent (372 inherited + 7 new proof tests N2455–N2461; Ran 6818 = 6790 + 28 new tests, exact arithmetic; run 1 PID 13870 killed by VM restart #16 ~22:29, no footer).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 12315/1872/1813/3418 (exactly
as estimated). DEFERRED **#252 RESOLVED** (253→252, by entry TEXT
— verified `entries[251]` matched before removal; no new entry).

## Godot debt

- NEW proof `C07StackConveyorSetStatsRowsProof` (6 keys:
  `stats_class_default`, `stats_plastanium_def`,
  `stats_surge_def`, `stats_key`, `stats_unit`, `stats_rounding`)
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
