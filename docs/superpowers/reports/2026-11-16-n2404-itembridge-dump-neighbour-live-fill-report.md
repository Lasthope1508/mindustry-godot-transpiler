# Report N2404 — ItemBridge doDump neighbour live fill

**Slice:** N2404 — ItemBridge `doDump` neighbour live fill: a
new fill scans the proximity ring live before the dump and fills
the neighbour accept/canDump arrays in ring order, so `doDump`
no longer needs hand-seeded neighbour frames. **Wave:**
advances-23. **Commit:** `dc40f7f14` on
`slice/N2404-itembridge-dump-neighbour-live-fill` (base
`49af8435b`). **Files:** 5, +1143/−4.

## Source

Java: BuildingComp.java:1088 (dump gate);
`getMaximumAccepted` = `block.itemCapacity`
(BuildingComp.java:781-783), default 10 (Block.java:75). The
N2288 doDump takes the neighbour accept/canDump arrays as
explicit frame inputs (default []) and the tick supplies the
frame as-is. The fill mirrors the N2353 resolve path (ring →
`block_sprite_at_cell` → first frame).

## Implementation

New pure `source_item_bridge_dump_neighbour_live_fill_state` —
mirror of the N2394 pure, item-only. Fills
`dump_neighbour_accepts` / `dump_neighbour_can_dump` in ring
order from live neighbour frames: accepts from the DEFAULT
acceptItem gate (consumesItem via catalog rows + items <
itemCapacity), canDump default true, no-frame = false/false.
The tick wires the fill after the transport advance write-back
and BEFORE the doDump reads (:740-741). The fill runs
regardless of the link gate — the doDump pure self-gates on
`had_valid_link`. Supplied arrays win + `dump_neighbour_live`
refresh flag.

**⚠️ GATE-WATCH (worker flag, for the Godot side):** proofs
N2225/N2321 tick a bridge unlinked holding an item ≥60 ticks
near an accepting neighbour and may see new dumps appear now
that the fill runs live. On this VM both proofs still fail
Godot-absent as before; only the Godot run can observe the
change.

## Commits

- Slice: `dc40f7f14` (5 files, +1143/−4).
- Integration cherry-pick: `249823192` (clean).

## Tests

Targeted (new module
`tests.test_c07_item_bridge_dump_neighbour_live_fill`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-23 integration, PID 13992, from 15:30): Ran 6630 tests in 1551.684s, FAILED (failures=333, skipped=5), 0 errors — 333/333 Godot-absent `AssertionError: unexpectedly None` (326 inherited + 7 new proof tests N2402–N2408).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12097/1826/1758/3308 (brief
estimated +3 symbols; only 2 result symbols exist — one per
filled array; the register decides). Audit stays 1336.
DEFERRED **#238 RESOLVED** (298→297, by entry TEXT; no new
entry).

## Godot debt

- NEW proof `C07ItemBridgeDumpNeighbourLiveFillProof` (6 keys:
  `fill_accepts_from_live_neighbour`,
  `fill_can_dump_from_live_neighbour`,
  `fill_accepts_gate_requires_consumes_item`,
  `fill_accepts_gate_requires_capacity`,
  `fill_no_frame_neighbour_reports_empty`,
  `live_tick_dumps_with_live_fill`) — written but NEVER run;
  debt in GOAL.md §5.
- No old proof needs a re-run on this VM — but the Godot side
  should watch proofs N2225/N2321 (see GATE-WATCH above).
- Follow-throughs for later slices: (1) per-block override
  dispatch; (2) per-item dump routing; (3) ring dedup + team
  filter.
