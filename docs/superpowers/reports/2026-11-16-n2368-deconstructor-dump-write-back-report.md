# Report N2368 — PayloadDeconstructor dump neighbour write-back

**Slice:** N2368 — PayloadDeconstructor dump exposes its deliveries; the
tick writes each dumped item into the neighbour store. **Wave:**
advances-19. **Commit:** `21397f7e7` on
`slice/N2368-deconstructor-dump-write-back` (base `46b1b951b`).
**Files:** 5, +932/−5.

## Source

Java: PayloadDeconstructor.java:111-115 (dumpRate 4 runs dumpAccumulate
4 times per tick); BuildingComp.java:1053-1061 (dumpAccumulate loop),
:1072-1113 (dump path), :1088 (proximity get), :1089
(`other.handleItem(self(), item);`). 14 exact exprs, all verified
verbatim.

## Implementation

The dump advance exposes `dump_deliveries` — an ARRAY of
{neighbour_index, item} dicts, one per successful dump, in attempt
order. dumpRate 4 runs dumpAccumulate 4×/tick, so a singular \"routed
index + dumped item\" shape would drop every delivery but one — the
array is the correct shape here (the N2362 lesson), unlike the scalar
timerDump write-backs (N2360/N2361/N2363, once per tick). The tick
wires the shared N2353 helper per delivery, amount 1, catalog size
(deconstructor 5 / small 3; size-5 ring 0 offset (−3,−1) pinned).

## Commits

- Slice: `21397f7e7` (5 files, +932/−5).
- Integration cherry-pick: `7cb150be3` (clean).

## Tests

Targeted (new module
`tests.test_c07_payload_deconstructor_dump_write_back`): 3/4 PASS +
proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Exact-evidence 14/14.
Siblings Ran 28 (21 PASS + 7 proof Godot-absent), 0 other errors.
Full gate (wave advances-19 integration, PID 7308, 12:44–13:09): Ran 6522 tests in 1485.371s, FAILED (failures=306, skipped=5), 0 errors — 306/306 Godot-absent `AssertionError: unexpectedly None` (299 inherited + 7 new proof tests N2368–N2374; N2375 adds +1 pin test, N2376 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+0/+0** → 12019/1800/1729/3250 (the one new
`dump_deliveries` symbol). Audit stays 1336. The schema/contract fold
landed later in N2376. DEFERRED **319 → 318** (the register base was
the stale N2363 list at 319, not the merged 316 — the coordinator
merged by entry TEXT; resolves #238).

## Godot debt

- NEW proof `C07PayloadDeconstructorDumpWriteBackProof` (3 keys:
  `advance_exposes_dump_deliveries`,
  `live_tick_writes_dumped_item_to_neighbour_frame`,
  `live_tick_dumped_item_leaves_deconstructor_without_frame`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
