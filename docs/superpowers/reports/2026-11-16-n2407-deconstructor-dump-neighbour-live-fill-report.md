# Report N2407 — PayloadDeconstructor dump neighbour live fill

**Slice:** N2407 — PayloadDeconstructor `dump` neighbour live
fill: a new fill scans the proximity ring live before the dump
and fills the neighbour accept/canDump arrays in ring order, so
`dump` no longer needs hand-seeded neighbour frames. **Wave:**
advances-23. **Commit:** `dcd95c0c4` on
`slice/N2407-deconstructor-dump-neighbour-live-fill` (base
`49af8435b`). **Files:** 5, +1147/−3.

## Source

Java: BuildingComp.java:1088 (dump gate);
`getMaximumAccepted` = `block.itemCapacity`
(BuildingComp.java:781-783), default 10 (Block.java:75). The
N2276 dump takes the neighbour accept/canDump arrays as
explicit frame inputs (default []) and the tick supplies the
frame as-is. The fill mirrors the N2353 resolve path (ring cell
i → `game.block_sprite_at_cell` → first
`SOURCE_CONSUMER_FRAME_META_KEYS` meta dict).

## Implementation

New pure
`source_payload_deconstructor_dump_neighbour_live_fill_state(game,
cell, size, frame, item_order)` — mirror of the N2394 pure,
item-only. Fills `dump_neighbour_accepts` /
`dump_neighbour_can_dump` in ring order from live neighbour
frames: accepts from the DEFAULT acceptItem gate (consumesItem
via catalog rows + items < itemCapacity), canDump default true,
no-frame = false/false. The item gate answers for the FIRST
held item in content order. The tick wires the fill before the
N2276 dump reads (:1023-1025), inside the enabled block and
BEFORE the progress advance (Java order
PayloadDeconstructor.java:111-115 before :117+). `cell` is
bound before the enabled block (:979), so the fill uses it
directly — no inline origin_cell read (unlike N2394/N2363).
Supplied arrays win (N2381 precedent); `dump_neighbour_live`
frames refresh every tick.

**Verify-first:** catalog consumeItem rows on
`block.properties` — melter consumes scrap (itemCapacity 10),
multi-press consumes coal (itemCapacity 20). **Correction
found:** multi-press is size **3** (Blocks.java:1059), not size
2 as the N2394 proof comment says — its footprint (28..30,
17..19) covers ring 4, 5 **and** 6; this proof asserts all
three indices. (The N2394 proof's fill-index assertions 5/6
still hold; the live-tick cdump issue is the separate N2406
finding.)

## Commits

- Slice: `dcd95c0c4` (5 files, +1147/−3).
- Integration cherry-pick: `f57a0133a` (clean).

## Tests

Targeted (new module
`tests.test_c07_payload_deconstructor_dump_neighbour_live_fill`):
3/4 PASS + proof test FAIL exactly AssertionError:
unexpectedly None — NO Godot binary on this VM (user order
2026-11-15). Sibling regression: N2276 dump + N2368 write-back
modules both still 3/4 (only their proof tests Godot-absent) —
no pins broken.
Full gate (wave advances-23 integration, PID 13992, from 15:30): Ran 6630 tests in 1551.684s, FAILED (failures=333, skipped=5), 0 errors — 333/333 Godot-absent `AssertionError: unexpectedly None` (326 inherited + 7 new proof tests N2402–N2408).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12097/1826/1758/3308 (brief
estimated +3 symbols; 2 result symbols, one per filled array;
the register decides). Audit stays 1336. DEFERRED **#217
RESOLVED** (298→297, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07PayloadDeconstructorDumpNeighbourLiveFillProof`
  (6 keys: `fill_accepts_from_live_neighbour`,
  `fill_can_dump_from_live_neighbour`,
  `fill_accepts_gate_requires_consumes_item`,
  `fill_accepts_gate_requires_capacity`,
  `fill_no_frame_neighbour_reports_empty`,
  `live_tick_dumps_with_live_fill` (live tick: coal 5→1, press
  +4 coal, melter 0, cdump 5, dump_accum 0.9, efficiency 0.0 —
  shouldConsume false, no deconstructing payload, dump still
  runs)) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (supplied arrays win by
  construction).
- Follow-throughs for later slices: (1) per-block override
  dispatch; (2) per-item dump routing; (3) ring dedup + team
  filter.
