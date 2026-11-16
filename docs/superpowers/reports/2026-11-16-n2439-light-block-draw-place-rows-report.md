# Report N2439 — LightBlock drawPlace / changePlacementPath / minimapColor rows

**Slice:** N2439 — LightBlock drawPlace() + changePlacementPath()
+ minimapColor(): a new pure-only draw-place pure models the
placement dash circle, the node radius, and the minimap color.
draw()/drawLight() are untouched (live since N2374). **Wave:**
advances-27. **Commit:** `3e620901a` on
`slice/N2439-light-block-draw-place-rows` (base `91ee0f1dc`).
**Files:** 5.

## Source

drawPlace (LightBlock.java:48-53): super.drawPlace(x, y, rotation,
valid); Drawf.dashCircle(x * tilesize + offset, y * tilesize +
offset, radius * 0.75f, Pal.placing). changePlacementPath (:55-59):
placeRadius2 = Mathf.pow(radius * 0.7f / tilesize, 2f) * 3;
Placement.calculateNodes(points, this, rotation, (point, other) ->
point.dst2(other) <= placeRadius2). minimapColor (:61-66): build =
(LightBuild)tile.build; return build == null ? 0 : build.color |
0xff. The color field: `public int color = Pal.accent.rgba();`
(LightBlock.java:68) — a config value, caller-supplied.

## Implementation

One pure-only pure `source_light_block_draw_place_state(tile_x,
tile_y, rotation, valid, radius, offset, build_color)` — 5 result
keys, 4 registered symbols: `super_place_call` (recorded, NOT a
registered symbol — the N2374/N2396 precedent), `dash_call`
(center x*8+offset, radius*0.75f, Pal.placing), `place_radius2`
(pow(radius*0.7/8, 2)*3), `calculate_nodes_call` (CALL record:
callee + rotation + predicate threshold; the node algorithm is NOT
ported, the N2396 precedent), `minimap_color` (0 when build null,
else color | 0xff). No tick wiring. Driver docstring: documented
limits now include "(7) DrawPlace rows live (N2439)".

**Verify-first findings (all source-backed):**
- offset = 0 for LightBlock: `offset = ((size + 1) % 2) *
  tilesize / 2f;` (Block.java:761) with the Block default `public
  int size = 1;` (Block.java:215) — LightBlock sets no size. The
  proof checks offset 0 (center 80,160 for tile 10,20) and offset
  4.0 (center 84,164) to prove offset flows through.
- `Pal.placing` IS the accent color (`placing = accent,`,
  Pal.java:95) — the dash call records the `Pal.placing` token.
- tilesize 8 (Vars.java:135); the calculateNodes signature
  verified (Placement.java:92); the illuminator def radius 140f
  (Blocks.java:6766) → dash radius 105.0, placeRadius2 450.1875;
  the class default 200f → 150.0 / 918.75.

## Commits

- Slice: `3e620901a` (5 files).
- Integration cherry-pick: `868f15054` (clean).

## Tests

Targeted (new module `tests.test_c07_light_block_draw_place_rows`):
3/4 PASS (registration, exact-evidence, row-state) + proof test
FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). RED confirmed first (KeyError
N2439 + missing pure + Godot-absent proof). 17 exact exprs, all
verified verbatim across 6 upstream sources (LightBlock/Block/Vars/
Pal/Placement/Blocks.java).
Full gate (wave advances-27 integration, PID 4530, from 19:02): Ran 6738 tests in 1537.145s, FAILED (failures=359, skipped=5), 0 errors — 359/359 Godot-absent (352 inherited + 7 new proof tests N2433–N2439; Ran 6738 = 6710 + 28 new tests, exact arithmetic). Gate run 1 (PID 2236) invalid — VM restart #14 wiped javalang (Ran 6055, errors=15, all javalang-import).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+1/+2** → 12222/1852/1786/3364 (exactly
as estimated; 4 symbols: dash_call, place_radius2,
calculate_nodes_call, minimap_color — super_place_call is recorded
but not registered). Audit stays 1336. Power shard changed
(additive): `power_api_contracts.json` +59, `power_slices.json`
+20. DEFERRED **#96 RESOLVED** (273→272, by entry TEXT; no new
entry).

## Godot debt

- NEW proof `C07LightBlockDrawPlaceRowsProof` (6 keys:
  `draw_place_dash_circle`, `draw_place_super_recorded`,
  `draw_place_radius2_math`, `draw_place_calculate_nodes`,
  `minimap_color_null`, `minimap_color_or_ff`) — written but NEVER
  run; debt in GOAL.md §5. Mirrored from the N2374 proof; the
  preload + scene file are statically asserted in the row-state
  test.
- No old proof needs a re-run (pure-only, no tick wiring).
