# Report N2356 — ShockwaveTower draw rows

**Slice:** N2356 — ShockwaveTower draw rows (draw heatRegion additive +
shape poly heat^2 lerp; drawSelect/drawPlace waveColor dash circle;
DEFERRED #69 + #204 resolved). **Wave:** advances-17. **Commit:** `d87abf186`
on `slice/N2356-shockwave-draw-rows` (base `9282b27a`). **Files:** 5,
+958/−1.

## Source

Java: ShockwaveTower.java:23-40 (draw: heatRegion additive + shape poly
with heat² lerp), :124-131 (drawSelect/drawPlace waveColor dash circle).
16 exact exprs, all verified verbatim.

## Implementation

Two new pure draws following the SourceBlockDrawState pattern:
`source_shockwave_tower_draw_state` (heatRegion additive + shape polygon
with heat² color lerp) and `source_shockwave_tower_draw_select_state`
(drawSelect/drawPlace waveColor dash circle — verified drawPlace uses
waveColor, not Pal.placing).

## Commits

- Slice: `d87abf186` (5 files, +958/−1).
- Integration cherry-pick: `841829d85` (clean).

## Tests

Targeted (new module `tests.test_c07_shockwave_tower_draw_rows`): 3/4 PASS +
proof test FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). Exact-evidence 16/16. Siblings 8 modules
Ran 32 (24 PASS + 8 proof Godot-absent), 0 other errors.
Full gate (wave advances-17 integration, PID 12882, 10:58–11:23): Ran
6468 tests in 1457.080s, FAILED (failures=293, skipped=5), 0 errors —
293/293 Godot-absent `AssertionError: unexpectedly None` (287 inherited +
6 new proof tests N2351–N2354, N2356–N2357; N2355 has no proof test).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+2/+4** → 11987/1789/1722/3236 (brief est
+2/+1/+1/+2 low — 2 pures = 2 contracts + 4 schemas, 3 result fields).
Audit stays 1336.
DEFERRED **326 → 324 (−2+0)**: resolved #69 + #204, no new entry.

## Godot debt

- NEW proof `C07ShockwaveTowerDrawRowsProof` (6 keys:
  `draw_heat_call_additive`, `draw_live_frame_values`,
  `draw_place_dash_circle_wave_color`, `draw_select_dash_circle`,
  `draw_shape_color_lerp`, `draw_shape_poly_geometry`) — written but NEVER
  run; debt in GOAL.md §5.
- No old proof needs a re-run.
