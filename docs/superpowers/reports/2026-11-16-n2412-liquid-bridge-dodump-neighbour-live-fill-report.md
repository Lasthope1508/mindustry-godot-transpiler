# Report N2412 — LiquidBridge doDump live neighbour fill

**Slice:** N2412 — LiquidBridge `doDump` neighbour live fill:
a new fill scans the proximity ring live before the dump and
fills all 8 neighbour arrays in ring order, so `doDump` no
longer needs hand-seeded neighbour frames. **Wave:** advances-24.
**Commit:** `d3b8b1fd6` on
`slice/N2412-liquid-bridge-dodump-neighbour-live-fill` (base
`a0e246e1f`). **Files:** 5, +1362/−5.

## Source

Java: BuildingComp.java:896-905 (liquid proximity), :868-870
(acceptLiquid), :910-912 (canDumpLiquid); doDump =
`dumpLiquid(liquids.current(), 1f)` at scaling 1f
(LiquidBridge.java:29-31), NOT the 2f default
(BuildingComp.java:877-878). The N2287 pure takes the
neighbour arrays as explicit frame inputs (default []) and the
tick supplies the frame as-is.

## Implementation

New pure
`source_liquid_bridge_dodump_neighbour_live_fill_state(game,
cell, size, liquids, liquid_names_by_id)` — fills all **8**
neighbour arrays in ring order (N2394 liquid half + N2408
Fracker 8-field shape, as parallel arrays): amounts /
capacities / accepts / has_liquids / can_dump /
liquids_present / destination_present / relative_to. DEFAULT
acceptLiquid/canDumpLiquid gates; no-frame outcome 0.0/0.0/
false×5/0; conduit = no-frame.

Tick wiring in the **unlinked branch only**, BEFORE the dump
reads at :540: supplied arrays win (all 8 `frame.has` checks,
N2381/N2394 precedent) + `dump_neighbour_live` refresh flag.
The `load()` calls for PowerGraph/LiquidModule state are
runtime loads, not preloads (cycle risk + :540 line-shift
avoidance), documented in the fill comment.

**Verify-first:** DEFERRED entry STALE as brief warned — the
tick builds 8 arrays at :540 (verified line 540 exactly), not
3. Dumped liquid is `liquids.current()`: the fill reads
`current` from the advanced store (same read as the N2287
pure) + name via the tick's `liquid_names_by_id`. N2371
resolution path mirrored (ring → `block_sprite_at_cell` →
first `SOURCE_CONSUMER_FRAME_META_KEYS` frame; neighbour
liquids under `frame["liquids"]`). Catalog verified: mixer
consumes water (hasLiquids, 36f), compressor oil (hasLiquids,
60f), electrolyzer consumes water with NO hasLiquids key; 30
defs have the gap — NOT fixed, Java default false used.
**Footprint trap avoided:** size-3 footprint is CENTRED
(`SourceBlockFootprint.footprint_offset`, the N2394
press-centre lesson) — proof places the electrolyzer origin at
(27,23), footprint (26..28, 22..24), covering ring 2 only; all
5 footprints verified non-overlapping. Size-1 ring = 4 cells
[(28,20), (29,21), (28,22), (27,21)] (angle-sort recomputed).

## Commits

- Slice: `d3b8b1fd6` (5 files, +1362/−5).
- Integration cherry-pick: `f21150630` (clean).

## Tests

Targeted (new module
`tests.test_c07_liquid_bridge_dodump_neighbour_live_fill`):
3/4 PASS (registration, exact-evidence, row-state) + proof
test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Family neighbours
all hold 3/4 + proof-only fail: N2287 doDump, N2379 write-back,
power-status, should-consume, update-transport, item-bridge
auto-link.
Full gate (wave advances-24 integration, PID 1736, from 16:29): Ran 6651 tests in 1446.605s, FAILED (failures=338, skipped=5), 0 errors — 338/338 Godot-absent (333 inherited + 5 new proof tests N2410, N2411, N2412, N2414, N2415; N2409/N2413 add no proof test). Gate run 1 (PID 21111, from 16:13) was killed by VM restart #13 ~16:29 after ~16 min (no footer); javalang reinstalled, gate re-run.

## SSOT / DEFERRED

SSOT single-slice **+8/+1/+1/+2** → 12116/1833/1765/3322
(exactly as estimated; 8 new result symbols — the 8 arrays).
Audit stays 1336. DEFERRED **#232 RESOLVED** (291→290, by
entry TEXT; no new entry).

## Godot debt

- NEW proof `C07LiquidBridgeDodumpNeighbourLiveFillProof` (6
  keys: `fill_liquid_arrays_from_live_neighbours`,
  `fill_accepts_gate_requires_has_liquids`,
  `fill_accepts_gate_requires_consumes_liquid`,
  `fill_capacity_from_live_neighbour` (incl. a no-store probe
  via erase + refill),
  `fill_no_frame_neighbour_reports_empty`,
  `live_tick_dumps_with_live_fill` (50 water → mixer takes 36
  capped by 36f capacity, bridge keeps 14.0, cdump wraps 0))
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (supplied arrays win by
  construction).
- Follow-throughs for later slices: (1) per-block override
  dispatch; (2) the catalog `hasLiquids` gap (30 defs); (3)
  ring dedup + team filter.
