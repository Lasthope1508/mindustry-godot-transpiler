# Report N2363 — BeamDrill timerDump neighbour write-back

**Slice:** N2363 — BeamDrill timerDump exposes the dumped neighbour
index + item; the tick writes the item into the neighbour store.
**Wave:** advances-18. **Commit:** `af977d648` on
`slice/N2363-beam-drill-timerdump-write-back` (base `1843003e2`).
**Files:** 5, +863/−9.

## Source

Java: BeamDrill.java timerDump path; BuildingComp.java:1072-1113
(dump path), :1082/:1099 (proximity get), :1089
(`other.handleItem(self(), item);`). 9 exact exprs, all verified
verbatim.

## Implementation

The timerDump advance exposes `dump_neighbour_index` / `dumped_item`
(−1/`""` when nothing dumps), read from `dump_item_state`'s literal
`handled_index` / `handled_item` (NOT
`SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY` — that is the Separator
offload path). The tick wires the shared N2353 helper after the
timerDump persist, guarded `dump_index >= 0`, reading `origin_cell`
inline as `dump_cell` (no `cell` in scope inside the enabled block);
a failed write-back drops the item (the N2353 precedent). The
facing-tiles stamp N2352 was left untouched (pinned in the test — the
pin was later updated by N2366 when the gate was removed).

## Commits

- Slice: `af977d648` (5 files, +863/−9).
- Integration cherry-pick: `44c087459` (clean).

## Tests

Targeted (new module `tests.test_c07_beam_drill_timer_dump_write_back`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15). Exact-evidence
9/9. Siblings BeamDrill Ran 32 (24 PASS + 8 proof) + Separator helper
Ran 8 (6 PASS + 2 proof), 0 other errors.
Full gate (wave advances-18 integration, PID 21965, 11:52–12:17): Ran
6493 tests in 1482.684s, FAILED (failures=299, skipped=5), 0 errors —
299/299 Godot-absent `AssertionError: unexpectedly None` (293 inherited
+ 6 new proof tests N2358–N2363; N2364 adds no new proof test).

## SSOT / DEFERRED

SSOT single-slice **+0/+1/+0/+0** → 11999/1794/1727/3246 (ledger only,
re-listing the five N2289 symbols — the validator non-empty rule).
Audit stays 1336. The two key symbols + schema/contract fold landed
later in N2367.
DEFERRED **320 → 319** (resolved #263 1-based).

## Godot debt

- NEW proof `C07BeamDrillTimerDumpWriteBackProof` (3 keys:
  `advance_exposes_routed_neighbour_index`,
  `live_tick_writes_dumped_item_to_neighbour_frame`,
  `live_tick_dumped_item_leaves_drill_without_frame`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
