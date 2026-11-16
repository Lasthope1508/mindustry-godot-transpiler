# Report N2406 — MassDriver dump neighbour live fill

**Slice:** N2406 — MassDriver `dump` neighbour live fill: a new
fill scans the proximity ring live before the dump and fills
the neighbour accept/canDump arrays in ring order, so `dump`
no longer needs hand-seeded neighbour frames. **Wave:**
advances-23. **Commit:** `4b9a4961b` on
`slice/N2406-massdriver-dump-neighbour-live-fill` (base
`49af8435b`). **Files:** 5, +1141/−2.

## Source

Java: BuildingComp.java:1088 (dump gate);
`getMaximumAccepted` = `block.itemCapacity`
(BuildingComp.java:781-783), default 10 (Block.java:75). The
N2294 dump takes the neighbour accept/canDump arrays as
explicit frame inputs (default []) and the tick supplies the
frame as-is. The fill mirrors the N2353 resolve path (ring →
`block_sprite_at_cell` → first
`SOURCE_CONSUMER_FRAME_META_KEYS` meta).

## Implementation

New pure `source_mass_driver_dump_neighbour_live_fill_state` —
mirror of the N2394 pure, item-only. Fills
`dump_neighbour_accepts` / `dump_neighbour_can_dump` in ring
order from live neighbour frames: accepts from the DEFAULT
acceptItem gate (consumesItem via catalog rows + items <
itemCapacity), canDump default true, no-frame = false/false
(incl. an explicit conduit guard). The tick wires the fill
AFTER the advance write-back (`frame["items"] =
advanced["items"]`, so the offered item reads the post-advance
store Java dumps from) and BEFORE the dump reads (:929-930);
`cell` is already bound (:807) so no `fill_cell` is needed.
Supplied arrays win + `dump_neighbour_live` refresh.

**Verify-first:** catalog consumeItem rows on
`block.properties` — melter scrap/1 cap 10, multi-press coal/3
cap 20 (both verified in `content_registry.json` +
Blocks.java). Proof arithmetic validated by a Python simulation
mirroring the GDScript + helpers exactly: 17/17 checks pass.

**⚠️ Finding for the coordinator (N2394 proof defect):**
multi-press is size **3** (Blocks.java:1059), not size 2 as the
N2394 proof comment claims, and `occupied_cells` centres odd
sizes — so the N2394 proof's press centred ON ring cell (30,20)
overlaps the origin footprint AND covers ring **4** as well as
5/6. Simulating its live tick with ring 4 accepting gives final
cdump **5**, not the asserted 7 (coal counts still pass). The
Godot-side agent will likely hit the N2394 `cdump == 7`
failure; a fix slice for the N2394 proof is queued for
advances-24 (re-centre the press as N2406 does: centre (31,20),
footprint (30..32, 19..21), covers exactly ring 4/5/6 with zero
origin overlap).

## Commits

- Slice: `4b9a4961b` (5 files, +1141/−2).
- Integration cherry-pick: `fabd3552c` (clean).

## Tests

Targeted (new module
`tests.test_c07_mass_driver_dump_neighbour_live_fill`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15). Sibling
safety: all 285 static pins in the other MassDriver test
modules still hold.
Full gate (wave advances-23 integration, PID 13992, from 15:30): Ran 6630 tests in 1551.684s, FAILED (failures=333, skipped=5), 0 errors — 333/333 Godot-absent `AssertionError: unexpectedly None` (326 inherited + 7 new proof tests N2402–N2408).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12097/1826/1758/3308 (brief
estimated +3 symbols; only 2 result symbols exist — one per
filled array; the register decides). Audit stays 1336.
DEFERRED **#247 RESOLVED** (298→297, by entry TEXT; no new
entry).

## Godot debt

- NEW proof `C07MassDriverDumpNeighbourLiveFillProof` (6 keys:
  `fill_accepts_from_live_neighbour`,
  `fill_can_dump_from_live_neighbour`,
  `fill_accepts_gate_requires_consumes_item`,
  `fill_accepts_gate_requires_capacity`,
  `fill_no_frame_neighbour_reports_empty`,
  `live_tick_dumps_with_live_fill` (live tick: coal 5→4, press
  0→1, cdump 0→5, accum 0.9)) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run (N2294/N2369 proofs seed arrays
  so the fill skips there; N2237/N2336/N2153 unaffected).
- Follow-throughs for later slices: (1) per-block override
  dispatch; (2) per-item dump routing; (3) ring dedup + team
  filter; (4) the N2394 proof fix (cdump 5, not 7 — queued for
  advances-24).
