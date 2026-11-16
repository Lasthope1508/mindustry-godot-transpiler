# Report N2364 — PayloadMassDriver live link tile-size fix

**Slice:** N2364 — The PMD live link range used game `tile_size` (32)
for logic world coords; Java uses `tilesize` 8. **Wave:** advances-18.
**Commit:** `a29f44f3c` on `slice/N2364-pmd-tile-size-fix` (base
`1843003e2`). **Files:** 2, +106/−3.

## Source

Java: Vars.java:135 (`tilesize = 8`, world units); game `tile_size`
is 32 (rendering px/tile — feeds viewport/input, not logic).
PayloadMassDriver.java link range rows. The driver read
`game.get("tile_size")` for logic distances, making every range 4x
too short in tiles.

## Implementation

Replaced `game.get("tile_size")` with the Java constant 8.0 in
SourcePayloadMassDriverBuildState.gd tick. Boundary verified: 30
cells — Java 240 < 700 in-range vs old port 960 > 700 out; 87 cells
last in-range (small), 88 out; large 262 in / 263 out. Fix slice: no
new test module, no register — the new test went into the existing
module `tests.test_c07_payload_mass_driver_update_tile`.

## Commits

- Slice: `a29f44f3c` (2 files, +106/−3).
- Integration cherry-pick: `1932953f8` (clean).

## Tests

Targeted (existing module, +1 test): Ran 5 (4 PASS + 1 proof
Godot-absent — the pre-existing PMD proof, no new proof test).
Siblings PMD green. No new proof test.
Full gate (wave advances-18 integration, PID 21965, 11:52–12:17): Ran
6493 tests in 1482.684s, FAILED (failures=299, skipped=5), 0 errors —
299/299 Godot-absent `AssertionError: unexpectedly None` (293 inherited
+ 6 new proof tests N2358–N2363; N2364 adds no new proof test).

## SSOT / DEFERRED

SSOT +0, DEFERRED 0 (fix slice, no register).

## Godot debt

- No new proof.
- ⚠️ Brief premise (c) was WRONG: the N2357 proof's small pair sits
  40 cells apart, deliberately out-of-range under 32× math (1280 >
  700, stays idle), and key `large_def_range_2100_live_link` asserts
  both stay idle — after this fix 40 cells = 320 < 700, so both switch
  idle → shooting and that key FAILS in Godot. The worker did NOT edit
  the proof (correct per brief). **The N2357 proof needed a RE-RUN +
  re-seed — done as N2365.**
- Backlog: MassDriver has the identical pattern
  (SourceMassDriverBuildState.gd:504-505) — NOT touched here, separate
  slice (pinned in the new test).
- The stale SSOT description at register_c07_payload_mass_driver_update_tile.py:493
  ("game tile_size when set" — now false) was fixed by N2365.
