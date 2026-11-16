# Report N2426 — WallCrafter draw / icons / drawPlanRegion / drawPlace rows

**Slice:** N2426 — WallCrafter draw() + drawPlanRegion + drawPlace +
icons(): a new pure-only draw pure models the base/top rects, the
rotator loop, the plan region, the place drillspeed text, and the
icons. **Wave:** advances-26. **Commit:** `e7dd7ecf1` on
`slice/N2426-wall-crafter-draw-rows` (base `cc1fe2ed0`). **Files:**
5, +1018/−1.

## Source

draw() (WallCrafter.java:231-250): rect(region) + rect(topRegion);
the rotator loop over the edge tiles — for each edge tile:
`Draw.rect(rotatorRegion, vx, vy, rotdeg() + (i * 90))` (:243) AND
a second `Draw.rect(rotatorRegion, vx, vy);` (:244, no rotation,
same vx/vy, z Layer.blockOver). drawPlace (:167-169): the cpos
callback runs for EVERY edge tile (before the solid check) and the
drillspeed text uses `Strings.fixed(drillTime, 2)` + bundle
`bar.drillspeed = Drill Speed: {0}/s` (bundle.properties:1279).
drawPlanRegion + icons() (:251+): base + top + rotator regions.

## Implementation

One pure-only draw pure `source_wall_crafter_draw_state` — 6 result
symbols: `base_call`, `top_call`, `rotator_calls` (one entry per
edge tile: rotation + the second unrotated rect), `plan_call`,
`place_call`, `icon_regions`.

**Findings beyond the brief (all verify-first):**
1. **The second rect in the rotator loop is REAL** (the brief
   suspected it): `Draw.rect(rotatorRegion, vx, vy);` (:244) — no
   rotation, same vx/vy + z Layer.blockOver (35). Modeled as
   `rotator_call` in every entry.
2. **`Strings.fixed` TRUNCATES, it does not round** (arc
   Strings.java:735: `(int)(d * 10^places + 0.0001f)`) — the pure
   uses `floor(v*100+0.0001)/100`; the proof has a discriminating
   probe (1.099 → "1.09", rounding would give "1.10").
3. **rotdeg() = rotation × 90** (BuildingComp.java:582-584); d4x
   `{1,0,-1,0}` / d4y `{0,1,0,-1}` (arc Geometry.java:23-24);
   tilesize 8.
4. **N2419 drawer check: PASS** — no def overrides draw
   (Blocks.java:3002-3035 only set fields); WallCrafter has no
   drawer field (extends Block directly).
5. **The cpos callback runs for EVERY edge tile** (:167-169, before
   the solid check) — the loop draws the full `size` rotators even
   when a tile is not solid (unlike the N2301 efficiency fill,
   which only adds solid tiles). The pure truncates to exactly
   `size` entries, skips an entry missing cx/cy (the N2329
   precedent) but keeps the sign by index.
6. All proof values were verified by an independent Python
   simulation, including the edge-tile coordinates from the
   getEfficiency switch for tile (10,20) at all 4 rotations. No
   other WallCrafter test pins the old limits text. Documented
   limits (4) updated to "Draw rows live (N2426)"; setBars stays
   deferred separately.

## Commits

- Slice: `e7dd7ecf1` (5 files, +1018/−1).
- Integration cherry-pick: `3c6d3deef` (clean).

## Tests

Targeted (new module `tests.test_c07_wall_crafter_draw_rows`): 3/4
PASS (registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this
VM (user order 2026-11-15). RED confirmed first (2 failures + 2
errors before GREEN).
Full gate (wave advances-26 integration, PID 16270, from 17:50): Ran 6710 tests in 1603.985s, FAILED (failures=352, skipped=5), 0 errors — 352/352 Godot-absent (345 inherited + 7 new proof tests N2425–N2431; N2432 adds no proof test; Ran 6710 = 6682 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+1/+2** → 12177/1845/1778/3348 (**variance
vs the +5 estimate:** the brief listed 6 result keys and the est
counted 5 — +6 is correct). Audit stays 1336. DEFERRED **#37
RESOLVED** (280→279, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07WallCrafterDrawRowsProof` (6 keys:
  `draw_base_top`, `draw_rotator_loop`, `draw_place_drillspeed`,
  `draw_plan_region`, `draw_icons`, `draw_rotation_branch`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
