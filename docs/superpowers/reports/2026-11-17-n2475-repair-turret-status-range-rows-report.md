# Report N2475 — RepairTurret status() / range() rows

**Slice:** N2475 — RepairTurret status() + range() as one
pure-only pure. **Wave:** advances-32. **Commit:** `466732bcd` on
`slice/N2475-repair-turret-status-range-rows` (base `99a167e15`).
**Files:** 5, +793/−1.

## Source

RepairTurret.java (core/src/mindustry/world/blocks/units/ — NOT
defense/): status() :226-228 (`return Mathf.equal(
potentialEfficiency, 0f, 0.01f) ? BlockStatus.noInput :
super.status();`) and range() :231-233 (`return repairRadius;` —
the Ranged.range() accessor, Ranged.java:6). Mathf.equal 3-arg
overload (arc Mathf.java:554-556) is `return Math.abs(a - b) <=
tolerance;` — INCLUSIVE, so exactly 0.01f still reads noInput.
BlockStatus.noInput is `noInput(Pal.remove),`
(BlockStatus.java:8). super.status() is BuildingComp.status()
(BuildingComp.java:632-646): logicDisable when !enabled, noOutput
when !shouldConsume(), noInput when efficiency <= 0 or
!productionValid(), else active iff ((state.tick / 30f) % 1f) <
efficiency. Defs: repair-point 60f (Blocks.java:6389),
repair-turret 145f (Blocks.java:6401).

## Implementation

One pure-only pure (no tick wiring — the N2435 precedent; the tick
never calls status()/range()):
`source_repair_turret_status_range_state(potential_efficiency,
super_status, repair_radius)` → {status, range}. The pure takes
caller-supplied inputs (the folded potentialEfficiency, the
BuildingComp status result — the port computes it as
source_building_status_state — the def repairRadius) and returns
the status token + the range as data.

**Verify-first findings:**
- Premise OK — no prior status/range pure existed.
- Java matched the brief on every point (Mathf.equal INCLUSIVE,
  defs 60f/145f, super.status() = BuildingComp.status() :632-646).
- RepairTurret.java is in world/blocks/units/, NOT defense/.

## Commits

- Slice: `466732bcd` (5 files, +793/−1).
- Integration cherry-pick: `b4b523484` (clean).

## Tests

Targeted (new module
`tests.test_c07_repair_turret_status_range_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (4 RepairTurret modules): Ran 16 (12
PASS + 4 proof Godot-absent), 0 errors.
Full gate (wave advances-32 integration, PID 1721, from 00:31): Ran 6874 tests in 1607.276s, FAILED (failures=393, skipped=5), 0 errors — 393/393 Godot-absent (386 inherited + 7 new proof tests N2469–N2475; Ran 6874 = 6846 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2 → 12370/1885/1837/3466** (exactly as
estimated). DEFERRED **#36 RESOLVED** (238→237, by entry TEXT).

## Godot debt

- NEW proof `C07RepairTurretStatusRangeRowsProof` (6 keys:
  `range_class`, `range_def`, `status_boundary`, `status_no_input`,
  `status_super`, `status_tolerance`) — written but NEVER run; debt
  in GOAL.md §5.
- No old proof needs a re-run.
