# Report N2361 — Separator timerDump neighbour write-back

**Slice:** N2361 — Separator timerDump exposes the dumped neighbour
index + item; the tick writes the item into the neighbour store.
**Wave:** advances-18. **Commit:** `c98355149` on
`slice/N2361-separator-timerdump-write-back` (base `1843003e2`).
**Files:** 5, +855/−7.

## Source

Java: BuildingComp.java:1072-1113 (dump path), :1088 (proximity get),
:1089 (`other.handleItem(self(), item);`). 10 exact exprs, all
verified verbatim.

## Implementation

The timerDump advance exposes `dump_neighbour_index` / `dumped_item`
(SCALAR — timerDump fires once per tick); the tick wires the shared
N2353 helper after the timerDump persist. The register embeds the
DEFERRED numbering lesson: DEFERRED numbering is 1-based in the
DEFERRED-after-*.py files (the SCOPE cited 0-based indices from a
Python `enumerate` — all off by one; this slice resolves #242, not
#241).

## Commits

- Slice: `c98355149` (5 files, +855/−7).
- Integration cherry-pick: `a12da0a53` (clean).

## Tests

Targeted (new module `tests.test_c07_separator_timer_dump_write_back`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15). Exact-evidence
10/10. Siblings 32 tests (24 PASS + 8 proof Godot-absent), 0 other
errors.
Full gate (wave advances-18 integration, PID 21965, 11:52–12:17): Ran
6493 tests in 1482.684s, FAILED (failures=299, skipped=5), 0 errors —
299/299 Godot-absent `AssertionError: unexpectedly None` (293 inherited
+ 6 new proof tests N2358–N2363; N2364 adds no new proof test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+0/+0** → 12001/1794/1727/3246 (the two new
advance keys registered as symbols — a register with 0 new symbols
fails validation). Audit stays 1336.
DEFERRED **320 → 319** (resolved #242 1-based).
The schema + contract fold for the two keys landed later in N2367.

## Godot debt

- NEW proof `C07SeparatorTimerDumpWriteBackProof` (3 keys:
  `advance_exposes_dumped_neighbour_index`,
  `live_tick_writes_dumped_item_to_neighbour_frame`,
  `live_tick_dumped_item_leaves_separator_without_frame`) — written
  but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
