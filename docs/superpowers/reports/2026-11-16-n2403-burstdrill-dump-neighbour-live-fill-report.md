# Report N2403 — BurstDrill timerDump neighbour live fill

**Slice:** N2403 — BurstDrill `timerDump` neighbour live fill:
a new fill scans the proximity ring live before the dump and
fills the neighbour accept/canDump arrays in ring order, so
`timerDump` no longer needs hand-seeded neighbour frames.
**Wave:** advances-23. **Commit:** `0b369f537` on
`slice/N2403-burstdrill-dump-neighbour-live-fill` (base
`49af8435b`). **Files:** 5, +1142/−3.

## Source

Java: BuildingComp.java:1088 (dump gate);
`getMaximumAccepted` = `block.itemCapacity`
(BuildingComp.java:781-783), default 10 (Block.java:75). The
N2282 timerDump takes the neighbour accept/canDump arrays as
explicit frame inputs (default []) and the tick supplies the
frame as-is. The fill mirrors the N2353 resolve path (ring →
`game.block_sprite_at_cell` → first
`SOURCE_CONSUMER_FRAME_META_KEYS` meta; core/conduit carry no
frame → `no_frame`).

## Implementation

New pure `source_burst_drill_dump_neighbour_live_fill_state` —
mirror of the N2394 pure, item-only. Fills
`dump_neighbour_accepts` / `dump_neighbour_can_dump` in ring
order from live neighbour frames: accepts from the DEFAULT
acceptItem gate (consumesItem via catalog `consumeItem` rows +
items < itemCapacity), canDump default true, no-frame =
false/false. The fill answers for the FIRST held item in content
order. The tick wires the fill immediately before the dump reads
(:698-699), inside the same enabled block, after
`content_item_ids` (passed as `item_order`); `cell` is already
bound before the enabled block, so no inline `origin_cell`
read. Supplied arrays win + `dump_neighbour_live` refresh.

**Verify-first:** the surge-smelter is the ONLY catalog def
consuming copper (cap 20, size 3) — hence the live-tick
neighbour. Ring geometry recomputed independently: size-5 ring
around (28,20) has 20 cells; ring 0 = (25,19) melter, ring 14 =
(28,23) surge-smelter covering indices 12/13/14, ring 19 =
(25,20) copper wall — matches the N2360 pins.

## Commits

- Slice: `0b369f537` (5 files, +1142/−3).
- Integration cherry-pick: `a393485c4` (clean).

## Tests

Targeted (new module
`tests.test_c07_burst_drill_dump_neighbour_live_fill`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15). Sibling
regression: all 6 pre-existing BurstDrill test files — 18/18
non-proof tests pass; only the 6 pre-existing Godot proof tests
fail (Godot-absent, as before).
Full gate (wave advances-23 integration, PID 13992, from 15:30): Ran 6630 tests in 1551.684s, FAILED (failures=333, skipped=5), 0 errors — 333/333 Godot-absent `AssertionError: unexpectedly None` (326 inherited + 7 new proof tests N2402–N2408).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12097/1826/1758/3308 (brief
estimated +3 symbols; the pure returns exactly 2 arrays, so 2
result symbols; the register decides). Audit stays 1336.
DEFERRED **#228 RESOLVED** (298→297, by entry TEXT; no new
entry).

## Godot debt

- NEW proof `C07BurstDrillDumpNeighbourLiveFillProof` (6 keys:
  `fill_accepts_from_live_neighbours`,
  `fill_can_dump_from_live_neighbours`,
  `fill_accepts_gate_requires_consumes_item`,
  `fill_accepts_gate_requires_capacity`,
  `fill_no_frame_neighbour_reports_empty`,
  `live_tick_dumps_with_live_fill` (live tick: drill copper
  5→4, surge-smelter +1 copper at ring 12, cdump 0→13,
  `dump_neighbour_live` stamped)) — written but NEVER run;
  debt in GOAL.md §5.
- No old proof needs a re-run (supplied arrays win by
  construction).
- Follow-throughs for later slices: (1) per-block override
  dispatch; (2) per-item dump routing; (3) ring dedup + team
  filter (no multi-cell dedup, no team filter — the N2353/N2371
  convention).
