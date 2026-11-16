# Report N2360 — BurstDrill timerDump neighbour write-back

**Slice:** N2360 — BurstDrill timerDump exposes the dumped neighbour
index + item; the tick writes the item into the neighbour store.
**Wave:** advances-18. **Commit:** `93013b926` on
`slice/N2360-burst-drill-timerdump-write-back` (base `1843003e2`).
**Files:** 5, +905/−8.

## Source

Java: BurstDrill.java:83-84 (handleItem INSIDE dump());
BuildingComp.java:1072-1113 (dump path), :1082/:1099 (proximity get),
:1089 (dump(null) branch), :1103 (specific branch). 15 exact exprs,
all verified verbatim.

## Implementation

The timerDump advance exposes `dump_neighbour_index` / `dumped_item`
(SCALAR — timerDump fires once per tick; the index via
`SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY` = `"handled_index"`, the
item = port `handled_item`, Java-exact on both branches incl. the
dump(null) first-held-item branch). The tick wires the shared N2353
helper after the dump frame write-back, before the advance (Java
order: handleItem INSIDE dump()); `cell` hoisted to loop top.

## Commits

- Slice: `93013b926` (5 files, +905/−8).
- Integration cherry-pick: `25a61ca80` (clean).

## Tests

Targeted (new module `tests.test_c07_burst_drill_timer_dump_write_back`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15). Exact-evidence
15/15. Siblings Ran 24 (18 PASS + 6 proof Godot-absent), 0 other
errors. Proof pins eruption (28,20) → separator ring 14 (28,23).
Full gate (wave advances-18 integration, PID 21965, 11:52–12:17): Ran
6493 tests in 1482.684s, FAILED (failures=299, skipped=5), 0 errors —
299/299 Godot-absent `AssertionError: unexpectedly None` (293 inherited
+ 6 new proof tests N2358–N2363; N2364 adds no new proof test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+0/+0** → 12001/1794/1727/3246 (the two new
advance keys registered as symbols — a register with 0 new symbols
fails validation, so a wiring-only slice exposing new advance keys
must register them). Audit stays 1336. The register rebuild mirrored
the existing N2282 contract into comp_api_contracts.json (pure
addition, rebuild artifact).
DEFERRED **320 → 319** (resolved #245 1-based; #244 is the live fill,
still deferred); the follow-ups entry #320 narrowed (BurstDrill
clause dropped).
The schema + contract fold for the two keys landed later in N2367.

## Godot debt

- NEW proof `C07BurstDrillTimerDumpWriteBackProof` (3 keys:
  `advance_exposes_dumped_neighbour_index`,
  `live_tick_writes_dumped_item_to_neighbour_frame`,
  `live_tick_dumped_item_leaves_drill_without_frame`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
