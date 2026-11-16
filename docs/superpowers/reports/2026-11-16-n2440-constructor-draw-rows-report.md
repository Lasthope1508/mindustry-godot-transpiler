# Report N2440 — Constructor payload / draw rows

**Slice:** N2440 — BlockProducer.draw() + Constructor.drawSelect()
+ payload placement effect: a new pure-only draw pure models the
base/out rects, the recipe shadow + blockbuild shader loop + scan
line, the payload call, the top rect, the select icon, and the
place effect. **Wave:** advances-28. **Commit:** `0e5af70e6` on
`slice/N2440-constructor-draw-rows` (base `682c75eb9`). **Files:**
5, +1284/−1.

## Source

draw() (BlockProducer.java:134-160): rect(region, x, y);
rect(outRegion, x, y, rotdeg()); if recipe != null:
Drawf.shadow(x, y, recipe.size * tilesize * 2f, progress /
recipe.buildTime); Draw(Layer.blockBuilding, shader loop: per
region in recipe.getGeneratedIcons(): Shaders.blockbuild.region/
time/progress = region/time/progress÷buildTime, rect(region, x, y,
recipe.rotate ? rotdeg() : 0), flush); z Layer.blockBuilding + 1;
color(Pal.accent, heat); Lines.lineAngleCenter(x + Mathf.sin(time,
10f, tilesize/2 * recipe.size + 1f), y, 90, recipe.size * tilesize
+ 1f); reset. Then drawPayload(); z Layer.blockBuilding + 1.1f;
rect(topRegion, x, y). drawSelect() (Constructor.java:77-87): if
recipe != null: dx = x − size*tilesize/2f, dy = y +
size*tilesize/2f; icon = recipe.uiIcon; mixcol(Color.darkGray, 1f);
rect(icon, dx − 0.7f, dy − 1f, scl*xscl*24f, scl*yscl*24f); reset;
rect(icon, dx, dy, scl*xscl*24f, scl*yscl*24f). placeEffect
(BlockProducer.java:116-119): on craft completion,
payload.block().placeEffect.at(x, y, payload.size() / tilesize).

## Implementation

One pure-only draw pure `source_constructor_draw_state` (13
explicit inputs, no tick wiring) — 9 result symbols: `base_call`,
`out_call` (rotdeg), `shadow_call` (null when no recipe),
`build_call` (shader loop: regions + time + progress ratio —
recorded as CALL + params, the shader is NOT ported),
`scan_call` (lineAngleCenter, arc 3-arg sin — NOT absin),
`payload_call` (drawPayload recorded, NOT ported), `top_call` (z
blockBuilding + 1.1f), `select_call` (drawSelect icon: null when
no recipe; shadow offset −0.7/−1, darkGray mixcol, 24f),
`place_effect_call` (null unless just_crafted AND a recipe is set).

**Verify-first findings:**
- **Place-effect scale = RECIPE size** (the brief's open
  question, resolved): `payload.size()` is `return build.block.size
  * tilesize;` (BuildPayload.java:86-88) → scale =
  payload.size()/tilesize = the recipe block size, NOT the
  producer size. The proof pins scale 2.0 (recipe size 2) and 4.0
  (recipe size 4).
- **4 explicit params beyond the brief** (Java needs them, not
  derivable from the listed inputs): `size_value` (the PRODUCER
  size for drawSelect dx/dy, Constructor.java:79 — not the recipe
  size) and `draw_scl` / `draw_xscl` / `draw_yscl` (the Draw
  statics in the 24f icon rect, Constructor.java:85). 13 inputs
  total.
- **Defs:** constructor size 3 / buildSpeed 0.6f
  (Blocks.java:6658-6667), large-constructor size 5 / buildSpeed
  0.75f (Blocks.java:6670-6680); **no drawer override** — draw()
  is the BlockProducerBuild override, no drawer field on
  Constructor/BlockProducer. Layer.blockBuilding = 40,
  Layer.blockOver = 35 (Layer.java:42/45) → scan z 41, top z
  41.1. rotdeg() = rotation * 90 (BuildingComp.java:582-584). The
  sin is arc 3-arg `sin(radians / scl) * mag` (Mathf.java:90-92)
  — NOT absin; scan magnitude recipe size 2 → 9, length 17; size
  4 → 17/33.
- Null convention per the brief: shadow/build/scan/select null
  when no recipe; payload null when no payload; place_effect null
  unless just_crafted AND a recipe is set (just_crafted + null
  recipe → null, pinned in the proof).

## Commits

- Slice: `0e5af70e6` (5 files, +1284/−1).
- Integration cherry-pick: `a50337706` (clean).

## Tests

Targeted (new module `tests.test_c07_constructor_draw_rows`): 3/4
PASS (registration, exact-evidence 53/53 exprs verbatim, row-state)
+ proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). RED confirmed
first (KeyError 'N2440' + missing pure + Godot-absent proof).
Full gate (wave advances-28 integration, PID 12844, from 20:00): Ran 6762 tests in 1613.764s, FAILED (failures=365, skipped=5), 0 errors — 365/365 Godot-absent (359 inherited + 6 new proof tests N2440–N2445; Ran 6762 = 6738 + 24 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+9/+1/+1/+2** → 12268/1859/1794/3380 (exactly
as estimated). Shards changed: `payload_api_contracts.json` +
`payload_slices.json` (+ 5 canonical files; audit report +
module manifest unchanged); audit stays 1336. DEFERRED **#9
RESOLVED** (266→265, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07ConstructorDrawRowsProof` (6 keys:
  `draw_no_recipe`, `draw_recipe_build`, `draw_shadow_math`,
  `draw_scan_line_sin`, `draw_select_icon`, `draw_place_effect`)
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
