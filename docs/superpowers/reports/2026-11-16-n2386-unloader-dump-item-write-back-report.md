# Report N2386 — PayloadUnloader dump ITEM neighbour write-back

**Slice:** N2386 — PayloadUnloader dump ITEM neighbour write-back:
the dump advance exposes `dump_deliveries`, the tick lands each
dumped item in the neighbour store through the shared N2353 helper.
**Wave:** advances-21. **Commit:** `2c6d78e23` on
`slice/N2386-unloader-dump-item-write-back` (base `d35c67781`).
**Files:** 5, +1006/−16.

## Source

Java: BuildingComp.java:1052 (`dumpAccumulate` — "May dump multiple
times per frame"), :1056-1058 (the `while(dumpAccum >= 1f)` loop),
:1089 (`other.handleItem(self(), item);`), :1090-1091
(`items.remove(item, 1)` + `incrementDump`); PayloadUnloader.java:
105-108 (`offloadSpeed = 4` runs dumpAccumulate 4 times per tick).

## Implementation

**ARRAY, not a scalar pair (verified from Java before coding):**
dumpAccumulate can fire several times per frame and offloadSpeed 4
runs it 4 times per tick, so one tick can dump several items — a
singular routed index + item would drop every delivery but one (the
N2362/N2368/N2369 precedent). The advance exposes `dump_deliveries`
— one `{"neighbour_index", "item"}` dict per successful `dump()`
call, in attempt order, read from `dump_item_state`'s
`handled_index` + `handled_item`, guarded by `dumped`. The tick
lands each delivery through the shared
`source_neighbour_item_write_back_state` (N2353, amount 1, catalog
size); a failed write-back drops the item (the N2353 precedent).

**Key collision handled:** `dump_neighbour_index` is ALREADY the
liquid half's scalar key (N2380) — the item half does NOT reuse it
and does NOT add a scalar pair (`dump_item_neighbour_index` /
`dumped_item`); the deliveries array carries the item routing.
Liquid keys + wiring N2380 untouched (only the deferral comment
updated to "live since N2386").

**Scope correction:** the brief estimated +2/+1/+0/+0 on the scalar
hypothesis (2 keys); the verified ARRAY decision leaves 1 new key —
SSOT +1/+1/+0/+0 (recorded in the register docstring).

## Commits

- Slice: `2c6d78e23` (5 files, +1006/−16).
- Integration cherry-pick: `8432f265a` (clean).

## Tests

Targeted (new module
`tests.test_c07_payload_unloader_dump_item_write_back`): 3/4 PASS +
proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Sibling tests pinned to
this driver also green: N2293 dump + N2380 liquid (6/6 non-proof
PASS, only their 2 proofs failing Godot-absent). Preload-cycle
verified: the unloader file is not in the transitive preload tree of
SourceBuildingItemState (107 files).
Full gate (wave advances-21 integration, PID 20509, from 14:01):
Ran 6575 tests in 1517.133s, FAILED (failures=319, skipped=5), 0 errors — 319/319 Godot-absent `AssertionError: unexpectedly None` (312 inherited + 7 new proof tests N2386–N2392; N2393 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+0/+0** → 12052/1813/1740/3272 (1 symbol:
`source_payload_unloader_dump_state_result.dump_deliveries`;
re-lists the 6 N2293 symbols + 2 N2380 keys — the N2321 precedent).
Audit stays 1336. DEFERRED **306 → 305** (resolves #304, by entry
TEXT; no new entry). Schema + contract fold landed in N2393.

## Godot debt

- NEW proof `C07PayloadUnloaderDumpItemWriteBackProof` (3 keys:
  `advance_exposes_dump_deliveries` (single/multi/second-neighbour/
  no-dump + liquid keys untouched),
  `live_tick_writes_dumped_item_to_neighbour_frame` (4 copper →
  phase-conveyor ring 0 (26,19)),
  `live_tick_dumped_item_leaves_unloader_without_frame` (wall
  (18,9), copper still leaves 5→1)) — written but NEVER run; debt
  in GOAL.md §5.
- No old proof needs a re-run (N2380/N2293 proofs unchanged).
- Follow-through: live neighbour fill still deferred (acceptItem/
  canDump arrays are frame inputs, default [] — an unloader with no
  live fill does not dump); the N2380 deferral pin kept as a quoted
  historical note on the handleItem line.
