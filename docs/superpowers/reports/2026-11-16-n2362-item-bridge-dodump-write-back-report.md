# Report N2362 — ItemBridge doDump neighbour write-back

**Slice:** N2362 — ItemBridge doDump exposes its deliveries; the tick
writes each dumped item into the neighbour store. **Wave:**
advances-18. **Commit:** `171386be4` on
`slice/N2362-item-bridge-dodump-write-back` (base `1843003e2`).
**Files:** 5, +880/−5.

## Source

Java: ItemBridge.java:335-337 (doDump), :350-353 (dumpAccumulate);
BuildingComp.java:1053-1061 (dumpAccumulate loop), :1072-1113 (dump
path), :1089 (`other.handleItem(self(), item);`). 13 exact exprs (12
at slice time; N2367 added `res |= dump(item);`), all verified
verbatim.

## Implementation

The doDump advance exposes `dump_deliveries` — an ARRAY of
{neighbour_index, item} dicts, one per successful dump, in attempt
order. A singular "routed index + dumped item" shape would drop every
delivery but one when dumpAccumulate fires multiple times per frame
(ItemBridge.java:351) — the array is the correct shape here, unlike
the scalar timerDump write-backs (N2360/N2361/N2363, once per tick).
The tick loops the deliveries calling the shared N2353 helper;
preload-cycle verified clean.

## Commits

- Slice: `171386be4` (5 files, +880/−5).
- Integration cherry-pick: `adab067c8` (clean).

## Tests

Targeted (new module `tests.test_c07_item_bridge_do_dump_write_back`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15). Exact-evidence
13/13. Siblings Ran 32 (24 PASS + 8 proof Godot-absent), 0 other
errors.
Full gate (wave advances-18 integration, PID 21965, 11:52–12:17): Ran
6493 tests in 1482.684s, FAILED (failures=299, skipped=5), 0 errors —
299/299 Godot-absent `AssertionError: unexpectedly None` (293 inherited
+ 6 new proof tests N2358–N2363; N2364 adds no new proof test).

## SSOT / DEFERRED

SSOT single-slice **+0/+1/+0/+0** → 11999/1794/1727/3246 (ledger only,
reusing the five N2288 symbols — the N2321 shared-ownership precedent;
the validator only requires a non-empty list). Audit stays 1336. The
`dump_deliveries` symbol + schema/contract fold landed later in N2367.
DEFERRED **324 → 323** (the register base was the stale N2356 list at
324, not the merged 320 — the coordinator merged by entry TEXT; the
follow-ups entry was not in that base).

## Godot debt

- NEW proof `C07ItemBridgeDoDumpWriteBackProof` (3 keys:
  `advance_exposes_dump_deliveries`,
  `live_tick_writes_dumped_item_to_neighbour_frame`,
  `live_tick_dumped_item_leaves_bridge_without_frame`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
