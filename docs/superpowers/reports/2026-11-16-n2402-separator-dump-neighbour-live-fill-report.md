# Report N2402 — Separator timerDump dump neighbour live fill

**Slice:** N2402 — Separator `timerDump` neighbour live fill: a
new fill scans the proximity ring live before the dump and fills
the neighbour accept/canDump arrays in ring order, so `timerDump`
no longer needs hand-seeded neighbour frames. **Wave:**
advances-23. **Commit:** `bf1917e32` on
`slice/N2402-separator-dump-neighbour-live-fill` (base
`49af8435b`). **Files:** 5, +1159/−6.

## Source

Java: BuildingComp.java:1088 (`if(other.acceptItem(self(), item)
&& canDump(other, item)){`); `getMaximumAccepted` =
`block.itemCapacity` (BuildingComp.java:781-783), default 10
(Block.java:75). The N2281 timerDump takes the neighbour
accept/canDump arrays as explicit frame inputs (default []) and
the tick supplies the frame as-is. The fill mirrors the resolve
path of N2353/N2371 (game + cell + size + index → ring cell →
`block_sprite_at_cell` → first frame); neighbour def via sprite
block-id → catalog `blocks_by_id`.

## Implementation

New pure `source_separator_dump_neighbour_live_fill_state(game,
cell, size, frame, item_order)` — mirror of the N2394 pure,
item-only. Fills `dump_neighbour_accepts` /
`dump_neighbour_can_dump` in ring order from live neighbour
frames: accepts from the DEFAULT acceptItem gate (consumesItem
via catalog `consumeItem` rows + neighbour frame `items` count <
`itemCapacity`, default 10), canDump default true for any framed
neighbour, no-frame (no sprite / unknown def / conduit / no
meta-key frame) reports false/false. The tick wires the fill
immediately before the N2281 timerDump reads (:905-907).
Supplied arrays win (the N2381 precedent) + a
`dump_neighbour_live` refresh flag.

**Offload one-tick lag (documented in the driver comment):** the
N2343 offload routing reads the frame arrays BEFORE the fill
runs in the same tick, so it sees the previous tick's live-filled
arrays. Moving the fill ahead of the advance would need
`content_item_ids` hoisted — a follow-through, not this slice.

## Commits

- Slice: `bf1917e32` (5 files, +1159/−6).
- Integration cherry-pick: `6233d61e8` (clean).

## Tests

Targeted (new module
`tests.test_c07_separator_dump_neighbour_live_fill`): 3/4 PASS +
proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-23 integration, PID 13992, from 15:30): Ran 6630 tests in 1551.684s, FAILED (failures=333, skipped=5), 0 errors — 333/333 Godot-absent `AssertionError: unexpectedly None` (326 inherited + 7 new proof tests N2402–N2408).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12097/1826/1758/3308 (brief
estimated +3 symbols; only 2 result symbols exist — one per
filled array; the register decides). Audit stays 1336. DEFERRED
**#226 RESOLVED** (298→297, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07SeparatorDumpNeighbourLiveFillProof` (6 keys:
  `fill_accepts_from_live_neighbours`,
  `fill_can_dump_from_live_neighbours`,
  `fill_accepts_gate_requires_consumes_item`,
  `fill_accepts_gate_requires_capacity`,
  `fill_no_frame_neighbour_reports_empty`,
  `live_tick_dumps_with_live_fill` (live tick: separator holds
  scrap 5, clock 4.0, no seeded arrays → 1 scrap to the melter
  at ring 0, cdump 0→1, `dump_neighbour_live` true)) — written
  but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (supplied arrays win by
  construction; no existing Separator test pins the changed
  comment text).
- Follow-throughs for later slices: (1) per-block override
  dispatch — the Separator's own canDump (N2395) matters when
  OTHER blocks dump INTO the separator; (2) per-item dump
  routing (Java tries later held items against the same
  neighbour); (3) offload one-tick lag (hoist `content_item_ids`
  so the fill runs before the advance); (4) ring dedup + team
  filter.
