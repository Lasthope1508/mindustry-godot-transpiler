# Report N2445 — UnitCargoLoader drawPlace rows

**Slice:** N2445 — UnitCargoLoader.drawPlace(): a new pure-only
draw-place pure models the cap warning text. canPlaceOn is NOT
re-ported (live since N2330). **Wave:** advances-28. **Commit:**
`c4999282e` on `slice/N2445-ucl-draw-place-rows` (base
`682c75eb9`). **Files:** 5, +791/−1.

## Source

drawPlace (UnitCargoLoader.java:70-75): super.drawPlace(x, y,
rotation, valid); if !Units.canCreate(Vars.player.team(),
unitType): drawPlaceText(Core.bundle.get("bar.cargounitcap"), x,
y, valid). canPlaceOn (:66-68): super && Units.canCreate(team,
unitType) — LIVE since N2330.

## Implementation

One pure-only pure `source_unit_cargo_loader_draw_place_state(tile_x,
tile_y, valid, can_create)` (no tick wiring). `can_create` is a
bool caller-supplied — Units.canCreate is a team/indexer query
(the caller-supplied precedent N2435). 1 registered result key:
`warning_call` (null when can_create; {method: "drawPlaceText",
text: "bar.cargounitcap", x: tile_x, y: tile_y, valid} — recorded
as CALL, the N2396 precedent). super.drawPlace is recorded in the
docstring only, NOT modeled (the N2439 precedent). Rotation is
NOT a param because Java passes it only to `super.drawPlace`.

**Verify-first findings:**
- Bundle key exact: `bar.cargounitcap = Cargo Unit Cap Reached`
  (`mindustry-upstream/core/assets/bundles/bundle.properties:
  1278`).
- **drawPlaceText x/y are tile coords:** the 4-arg overload
  (Block.java:531-532) delegates to the 5-arg overload, which
  converts inside — `float dx = x * tilesize + offset, dy = y *
  tilesize + offset + size * tilesize / 2f + 3;`
  (Block.java:546) — so the record carries tile coords as passed.
  The 4-arg overload also picks color `valid ? Pal.accent :
  Pal.remove` with the line always drawn; the record carries
  `valid` so the caller can derive the color (the color itself is
  not a record field, per the brief's record shape).
- `Units.canCreate` verified at Units.java:115-117; `unitType =
  UnitTypes.manifold` at UnitCargoLoader.java:24.

## Commits

- Slice: `c4999282e` (5 files, +791/−1).
- Integration cherry-pick: `1b8fb207d` (clean).

## Tests

Targeted (new module
`tests.test_c07_unit_cargo_loader_draw_place_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on
this VM (user order 2026-11-15). RED confirmed first (KeyError
'N2445' + missing pure + Godot-absent proof).
Full gate (wave advances-28 integration, PID 12844, from 20:00): Ran 6762 tests in 1613.764s, FAILED (failures=365, skipped=5), 0 errors — 365/365 Godot-absent (359 inherited + 6 new proof tests N2440–N2445; Ran 6762 = 6738 + 24 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 12260/1859/1794/3380 (exactly
as estimated; 1 symbol:
`source_unit_cargo_loader_draw_place_state_result.warning_call`,
Variant null-or-CALL-record). Register touched only the 4
canonical generated files (no shard changes). DEFERRED **#241
RESOLVED** (266→265, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07UnitCargoLoaderDrawPlaceRowsProof` (6 keys:
  `draw_place_warning_null`, `draw_place_warning_present`,
  `draw_place_warning_text`, `draw_place_warning_xy`,
  `draw_place_warning_valid_true`,
  `draw_place_warning_valid_false`) — written but NEVER run;
  debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
