# Report N2405 — BeamDrill timerDump dump neighbour live fill

**Slice:** N2405 — BeamDrill `timerDump` dump neighbour live
fill: a new fill scans the proximity ring live before the dump
and fills the neighbour accept/canDump arrays in ring order, so
`timerDump` no longer needs hand-seeded neighbour frames.
**Wave:** advances-23. **Commit:** `fd9f21bb9` on
`slice/N2405-beamdrill-dump-neighbour-live-fill` (base
`49af8435b`). **Files:** 5, +1146/−5.

## Source

Java: BuildingComp.java:1088 (dump gate);
`getMaximumAccepted` = `block.itemCapacity`
(BuildingComp.java:781-782), default 10 (Block.java:75). The
N2289 timerDump takes the neighbour accept/canDump arrays as
explicit frame inputs (default []) and the tick supplies the
frame as-is. The fill mirrors the N2353 resolve path (ring →
`block_sprite_at_cell` → first
`SOURCE_CONSUMER_FRAME_META_KEYS` frame; core/conduit carry no
frame).

## Implementation

New pure `source_beam_drill_dump_neighbour_live_fill_state(game,
cell, size, frame, item_order)` — mirror of the N2394 pure,
item-only. Fills `dump_neighbour_accepts` /
`dump_neighbour_can_dump` in ring order from live neighbour
frames: accepts from the DEFAULT acceptItem gate (consumesItem
via catalog rows + items < itemCapacity), canDump default true,
no-frame = false/false; offered item = first held in content
order. The tick wires the fill before the N2289 dump reads
(:1079-1080), after `content_item_ids` is bound (:1078), inside
the enabled gate after the advance. Supplied arrays win +
`dump_neighbour_live` refresh.

**Verify-first:** catalog `consumeItem` rows on `properties` —
melter scrap/cap 10, multi-press coal/cap 20. The fold runs
before the facing scan, so the live tick's seeded
`facing_amount` 1 still folds efficiency 1.0. **Correction
noted:** the N2394 proof comment calls the multi-press
"size-2" — it is size 3 (Blocks.java:1059); the footprint claim
still holds (see the N2406 finding on the N2394 live-tick
cdump).

## Commits

- Slice: `fd9f21bb9` (5 files, +1146/−5).
- Integration cherry-pick: `22b078eb0` (clean).

## Tests

Targeted (new module
`tests.test_c07_beam_drill_dump_neighbour_live_fill`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15). Regression
check: N2289 + N2363 modules 6/6 non-proof tests pass (their 2
proof tests fail Godot-absent as before) — the supplied-arrays-
win wiring preserves their seeded proofs.
Full gate (wave advances-23 integration, PID 13992, from 15:30): Ran 6630 tests in 1551.684s, FAILED (failures=333, skipped=5), 0 errors — 333/333 Godot-absent `AssertionError: unexpectedly None` (326 inherited + 7 new proof tests N2402–N2408).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12097/1826/1758/3308 (brief
estimated +3 symbols; only 2 result symbols exist — one per
filled array; the register decides). Audit stays 1336.
DEFERRED **#240 RESOLVED** (298→297, by entry TEXT; no new
entry).

## Godot debt

- NEW proof `C07BeamDrillDumpNeighbourLiveFillProof` (6 keys:
  `fill_accepts_from_live_neighbours`,
  `fill_can_dump_from_live_neighbours`,
  `fill_accepts_gate_requires_consumes_item`,
  `fill_accepts_gate_requires_capacity`,
  `fill_no_frame_neighbour_reports_empty`,
  `live_tick_dumps_with_live_fill` (live tick: coal 5→4, cdump
  0→3 — melter rejects, empty ring 1 rejects, press at ring 2
  accepts — press coal 1, melter coal 0, clock 0.0,
  `dump_neighbour_live` true)) — written but NEVER run; debt
  in GOAL.md §5.
- No old proof needs a re-run (supplied arrays win by
  construction).
- Follow-throughs for later slices: (1) per-block override
  dispatch; (2) per-item dump routing; (3) ring dedup + team
  filter.
