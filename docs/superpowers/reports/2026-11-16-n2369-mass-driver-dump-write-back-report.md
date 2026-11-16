# Report N2369 — MassDriver dump neighbour write-back

**Slice:** N2369 — MassDriver dump exposes its deliveries; the tick
writes each dumped item into the neighbour store. **Wave:**
advances-19. **Commit:** `f946ba25a` on
`slice/N2369-mass-driver-dump-write-back` (base `46b1b951b`).
**Files:** 5, +934/−7.

## Source

Java: MassDriver.java:163-166 (dump gate — dump when idle or
accepting); BuildingComp.java:1053-1061 (dumpAccumulate loop — the
while loop fires multiple times per frame), :1072-1113 (dump path),
:1088 (proximity get), :1089 (`other.handleItem(self(), item);`). 14
exact exprs, all verified verbatim.

## Implementation

The dump advance exposes `dump_deliveries` — an ARRAY of
{neighbour_index, item} dicts, one per successful dump, in attempt
order. The while loop makes this multi-dump per frame, so the scalar
shape would drop deliveries (the N2362 lesson). The tick wires the
shared N2353 helper after the dump write-back; size-3 ring[0] offset
(−2,−1) pinned (simulated angle sort); the live neighbour is a size-1
phase-conveyor (a size-3 neighbour would overlap the 3×3 footprint).
The tile-size lines :504-505 were NOT touched (separate slice N2375).

## Commits

- Slice: `f946ba25a` (5 files, +934/−7).
- Integration cherry-pick: `06778f204` (clean).

## Tests

Targeted (new module `tests.test_c07_mass_driver_dump_write_back`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15). Exact-evidence
14/14. Siblings Ran 41 (31 PASS + 10 proof Godot-absent); write-back
neighbours Ran 16 (12 PASS + 4 proof), 0 other errors.
Full gate (wave advances-19 integration, PID 7308, 12:44–13:09): Ran 6522 tests in 1485.371s, FAILED (failures=306, skipped=5), 0 errors — 306/306 Godot-absent `AssertionError: unexpectedly None` (299 inherited + 7 new proof tests N2368–N2374; N2375 adds +1 pin test, N2376 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+0/+0** → 12019/1800/1729/3250 (the one new
`dump_deliveries` symbol). Audit stays 1336. The schema/contract fold
landed later in N2376. DEFERRED **319 → 318** (the register base was
the stale N2363 list at 319, not the merged 316 — the coordinator
merged by entry TEXT; resolves #279; #272 in the stale list is a
different entry — merge by TEXT).

## Godot debt

- NEW proof `C07MassDriverDumpWriteBackProof` (3 keys:
  `advance_exposes_dump_deliveries`,
  `live_tick_writes_dumped_item_to_neighbour_frame`,
  `live_tick_dumped_item_leaves_driver_without_frame`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
