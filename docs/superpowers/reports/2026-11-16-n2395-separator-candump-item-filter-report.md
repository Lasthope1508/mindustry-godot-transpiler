# Report N2395 — Separator canDump itemFilter model

**Slice:** N2395 — Separator `canDump` itemFilter model: the
`consumesItem` filter behind `canDump` is now modeled from
catalog consumeItem rows, so the Separator (all-false) and the
Disassembler (scrap-only) answer `canDump` Java-exact. **Wave:**
advances-22. **Commit:** `32d0bce2f` on
`slice/N2395-separator-candump-item-filter` (base `78a74e152`).
**Files:** 5, +956/−1.

## Source

Java: Separator.java:175-177 (`canDump` — cite kept :175-177 for
consistency: signature :177, return :178); Block.java:774-776
(`consumesItem(item)` = `itemFilter[item.id]`); ConsumeItems
apply semantics for the filter. Verify-first: the separator has
NO consumeItem key in the catalog, the disassembler has
`[{scrap, 1}]`; item ids follow Items.load() (scrap id 8, 22
items).

## Implementation

**2 pures, not 1:** the filter pure takes catalog consumeItem
rows + `item_names_by_id` — exactly ConsumeItems.apply, no
hardcoded def; the canDump pure calls the generic
`consumes_item_state` directly. Separator → all-false filter
(`canDump` always true: nothing is consumed, so nothing blocks
the dump); Disassembler → scrap-only (scrap is consumed, so a
scrap dump is refused).

## Commits

- Slice: `32d0bce2f` (5 files, +956/−1).
- Integration cherry-pick: `f5ed519df` (clean).
- Integration touch-up `293de3675`: the N2388 sense pure
  docstring still said "canDump stays deferred" — stale since
  this slice; fixed 1 line at integration (the worker left it
  per brief — forbidden to touch the sense pure).

## Tests

Targeted (new module
`tests.test_c07_separator_candump_item_filter`): 3/4 PASS +
proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-22 integration, PID 7151, from 14:50):
Ran 6602 tests in 1564.685s, FAILED (failures=326, skipped=5), 0 errors — 326/326 Godot-absent `AssertionError: unexpectedly None` (319 inherited + 7 new proof tests N2394–N2400; N2401 adds no test)..

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+2/+4** → 12072/1820/1751/3294. Audit
stays 1336. DEFERRED **#300 RESOLVED** (301→300, by entry TEXT).

## Godot debt

- NEW proof `C07SeparatorCanDumpItemFilterProof` (6 keys:
  `filter_separator_all_false`,
  `filter_disassembler_scrap_only`,
  `candump_separator_always_true`,
  `candump_disassembler_scrap_false`, `filter_unknown_def_edge`,
  `candump_live_frame_values`) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run.
