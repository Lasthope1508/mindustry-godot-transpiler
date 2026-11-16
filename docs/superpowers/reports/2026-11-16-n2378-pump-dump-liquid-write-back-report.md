# Report N2378 — Pump dumpLiquid neighbour write-back

**Slice:** N2378 — Pump dump exposes the handled neighbour; the tick
writes the dumped liquid into the neighbour store. **Wave:**
advances-20. **Commit:** `9bec948b8` on
`slice/N2378-pump-dump-liquid-write-back` (base `7b99d3d63`).
**Files:** 5, +897/−13.

## Source

Java: Pump.java:179 (`dumpLiquid(liquidDrop);`); BuildingComp.java:896
(proximity get), :918-919 (`next.handleLiquid` / `liquids.remove`).

## Implementation

The dump advance exposes `dump_neighbour_index` (from the shared
routing `handled_index`) + `dumped_liquid` on both return paths. The
tick wires the shared N2371 helper after the dump write-back when
`dumped_amount > 0` and the index is ≥ 0. No new preload (already
present); `cell` is already bound before the enabled block, so no
`dump_cell` workaround was needed (unlike Fracker).

**Scope correction — liquid_drop is a name, not an id:**
`source_floor_liquid_drop_state` returns the String name
(`"water"` / `"oil"` / `"cryofluid"` / `"slag"` / `"arkycite"`) or
null, and the pure already resolves it through `str(liquid_drop)`
for `liquid_id_by_name`. So `dumped_liquid = str(liquid_drop)`,
`""` on the null-drop path (the tick never calls the helper when
nothing dumps). The dumped liquid VARIES BY TILE, unlike the
Fracker's def constant "oil".

## Commits

- Slice: `9bec948b8` (5 files, +897/−13).
- Integration cherry-pick: `572181812` (clean).

## Tests

Targeted (new module
`tests.test_c07_pump_liquid_neighbour_write_back`): 3/4 PASS +
proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Siblings (Pump N2285,
power_status, should_consume, update_tile + N2371): Ran 20, only
the 5 proofs failing Godot-absent, 0 other errors.
Full gate (wave advances-20 integration, PID 14748, 13:27–13:50): Ran 6547 tests in 1364.438s, FAILED (failures=312, skipped=5), 0 errors — 312/312 Godot-absent `AssertionError: unexpectedly None` (306 inherited + 6 new proof tests N2377–N2381 + N2383; N2382 adds +1 pin test, N2384/N2385 add no test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+0/+0** → 12040/1807/1738/3268 (the two new
symbols; 3 N2285 symbols re-listed per the N2369/N2321 precedent).
Audit stays 1336. The schema/contract fold landed later in N2384.
DEFERRED **311 → 310** (resolves #241, by entry TEXT).

## Godot debt

- NEW proof `C07PumpLiquidNeighbourWriteBackProof` (3 keys:
  `advance_exposes_dump_neighbour_index`,
  `live_tick_writes_dumped_water_to_neighbour_frame`,
  `live_tick_dumped_water_leaves_pump_without_frame`) —
  written but NEVER run; debt in GOAL.md §5. The live tick mirrors
  N2285 (rotary-pump 0.4 pumps → 0.2 dumps → 0.2 into the
  separator frame at ring 0 (28,19); a pump by a wall still loses
  the 0.2).
- No old proof needs a re-run.
