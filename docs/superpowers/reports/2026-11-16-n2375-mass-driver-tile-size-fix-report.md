# Report N2375 — MassDriver live link tile-size fix

**Slice:** N2375 — The MassDriver live link range used game
`tile_size` (32) for logic world coords; Java uses `tilesize` 8.
**Wave:** advances-19 (coordinator-serial). **Commit:** `9cbc1a0ba`
on `integration/wave-advances-19-n2368-n2374` (no slice branch —
coordinator-serial after integration; the fix conflicts with N2369 on
the same driver). **Files:** 3, +108/−9.

## Source

Java: Vars.java:135 (`tilesize = 8`, world units); game `tile_size`
is 32 (rendering px/tile — feeds viewport/input, not logic).
MassDriver.java:343 (shooterValid) + :346-349 (linkValid) gate on
`within(other, range)`; within is STRICT dst < range
(Position.java:44-46); range is 440f (Blocks.java:2172). The driver
read `game.get(\"tile_size\")` for logic distances, making every range
4x too short in tiles.

## Implementation

Replaced `game.get(\"tile_size\")` with the Java constant 8.0 in
SourceMassDriverBuildState.gd tick (the N2364 PMD precedent).
Boundary verified: 30 cells — Java 240 < 440 in-range vs old port 960
> 440 out; 54 cells last in-range (432 < 440), 55 cells out (440, NOT
< 440 — strict dst); old boundary 13 in / 14 out. Fix slice: no new
test module, no register — the new test went into the existing module
`tests.test_c07_mass_driver_update_tile`, and the N2364 boundary pin
in `tests.test_c07_payload_mass_driver_update_tile` was updated
(now asserts the MassDriver driver hard-codes 8.0 too).

## Commits

- Serial slice: `9cbc1a0ba` (3 files, +108/−9).

## Tests

Targeted (existing module, +1 test): Ran 5 (4 PASS + 1 proof
Godot-absent — the pre-existing MassDriver proof, no new proof test).
MassDriver family Ran 26 (20 PASS + 6 proof Godot-absent), 0 other
errors. No new proof test.
Full gate (wave advances-19 integration, PID 7308, 12:44–13:09): Ran 6522 tests in 1485.371s, FAILED (failures=306, skipped=5), 0 errors — 306/306 Godot-absent `AssertionError: unexpectedly None` (299 inherited + 7 new proof tests N2368–N2374; N2375 adds +1 pin test, N2376 adds no test).

## SSOT / DEFERRED

SSOT +0, DEFERRED 0 (fix slice, no register).

## Godot debt

- No new proof.
- **No re-seed needed, no re-run needed** (unlike N2364 → N2365):
  every MassDriver proof was checked against the fix — the AcceptItem
  pair sits 2 cells apart (in range under BOTH maths: 2*8 = 16 < 440
  and 2*32 = 64 < 440, so no verdict flips), and every other live-tick
  proof ticks with link -1 / no link / no waiting shooter (the
  updateTile live tick, the Dump proof, the DumpWriteBack proof, the
  PowerStatus proof — single unlinked driver). The pure/advance
  fixtures pass precomputed coords already in Java units (partner x
  80.0 = 10 cells × 8). Pinned in the new test.
