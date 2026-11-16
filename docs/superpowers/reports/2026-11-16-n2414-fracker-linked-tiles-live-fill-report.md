# Report N2414 — Fracker fraction linked-tiles live fill

**Slice:** N2414 — Fracker fraction linked-tiles live fill: a
new fill scans the live tile map and builds
`proximity_linked_tiles`, which the N2305 tick recomputes
validTiles/boost from each enabled tick. **Wave:** advances-24.
**Commit:** `5d99b309d` on
`slice/N2414-fracker-linked-tiles-live-fill` (base `a0e246e1f`).
**Files:** 5, +1091/−7.

## Source

canPump (SolidPump.java:80-83, `tile != null &&
!tile.floor().isLiquid`); floor oil attribute values
(Block.java:575-582, sumAttribute); deep-floor flag
(`other.floor().isDeep()`). Linked-tile enumeration:
`Tile.getLinkedTiles` (Tile.java:474-485: dx outer, dy inner,
`(x+dx+o, y+dy+o)`, `o = sizeOffset = -((size-1)/2)`,
Block.java:762/1430 → −1 with size 3). Java skips null
(Tile.java:480). The N2305 pure entry shape is Dict
`{can_pump, attribute_value, is_deep}`
(`SourceFrackerBuildState.source_fracker_proximity_fraction_state`,
delegating to the N2292 SolidPump pure): `can_pump` gates
validTiles, `attribute_value` sums → boost = sum/9 (deep
excluded when !floating && !placeableLiquid, Block.java:580),
`is_deep` carries the deep flag.

## Implementation

**Design decision (verify-first): world_tiles does NOT carry
enough fields → MINIMAL EXTENSION.** BeamDrill `world_tiles`
is a Dict keyed `"x,y"` → `{solid, wall_drop}`
(SourceBeamDrillBuildState.gd:374) — NO floor/attribute/deep
(test pin `assertNotIn('floor_is_liquid'/'oil_attribute',
beam_drill)`). No producer stamps `frame["world_tiles"]`:
only the BeamDrill tick reads it (`frame.get` default {}),
proofs seed by hand. So the pure defines the minimal
extension `{floor_is_liquid, oil_attribute, is_deep}` in its
input contract + documents the producer gap (the live tile
producer waits for its own slice); NO tile producer invented.
The gap is a follow-through note, not a new DEFERRED entry.

**Enumeration: linked tiles are the FOOTPRINT size×size, NOT
the ring** — footprint 3×3 centred on the origin cell, Java
walk order (dx outer, dy inner), stable. Map entries
missing/null/non-Dict produce no dict — empty map → empty
list, as briefed.

New pure `source_fracker_linked_tiles_live_fill_state(world_tiles,
cell, size)` → `{proximity_linked_tiles}` (placed at end of
file, after the tick, so the :633 pin does not shift); tick
wiring in the enabled block BEFORE the N2305 recompute:
`frame["world_tiles"]` default `{}` → empty list; supplied
arrays win (N2381 — the N2305 proof seeds by hand),
live-filled frames (`proximity_linked_tiles_live`, N2394
precedent) refresh every tick.

## Commits

- Slice: `5d99b309d` (5 files, +1091/−7).
- Integration cherry-pick: `a02097ab3` (clean).

## Tests

Targeted (new module
`tests.test_c07_fracker_linked_tiles_live_fill`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on
this VM (user order 2026-11-15). Extra checks: cite sweep +
N2305 + N2408 modules — 10/13 non-proof PASS, the other 3 are
their proof tests failing Godot-absent. Note: the first run
failed the cite sweep because a doc edit added 2 lines before
:633 — fixed to line-neutral, passing again.
Full gate (wave advances-24 integration, PID 1736, from 16:29): Ran 6651 tests in 1446.605s, FAILED (failures=338, skipped=5), 0 errors — 338/338 Godot-absent (333 inherited + 5 new proof tests N2410, N2411, N2412, N2414, N2415; N2409/N2413 add no proof test). Gate run 1 (PID 21111, from 16:13) was killed by VM restart #13 ~16:29 after ~16 min (no footer); javalang reinstalled, gate re-run.

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 12109/1833/1765/3322
(exactly as estimated; 1 new symbol
`source_fracker_linked_tiles_live_fill_state_result.proximity_linked_tiles`).
Audit stays 1336. DEFERRED **#247 RESOLVED** (291→290, by
entry TEXT; no new entry).

## Godot debt

- NEW proof `C07FrackerLinkedTilesLiveFillProof` (6 keys:
  `linked_tiles_filled_from_live_tile_map`,
  `can_pump_gate_requires_non_liquid_floor`,
  `attribute_values_summed_from_floors`,
  `deep_flag_carried`, `no_tile_map_reports_empty`,
  `live_tick_pumps_with_fill` (live tick: boost 0.2, fraction
  0.5, max_pump > 0)) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run (supplied arrays win by
  construction).
- Follow-throughs for later slices: (1) the live tile producer
  that stamps `{floor_is_liquid, oil_attribute, is_deep}` per
  tile; (2) Fracker attribute env live fill (separate entry).
