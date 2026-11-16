# Report N2419 — Separator draw / drawLight / icons / drawPlanRegion rows

**Slice:** N2419 — Separator drawer rows: two pure-only draw pures
model the full DrawMulti composition (bottom / liquid tile / spinner /
base + light + icons + plan). **Wave:** advances-25. **Commit:**
`fa6b62d82` on `slice/N2419-separator-draw-rows` (base `e4e57bca3`).
**Files:** 5, driver +343/−1.

## Source

Separator.java:25 declares `drawer = new DrawDefault()`, but **BOTH
defs override it with the same DrawMulti** (Blocks.java:1246
separator / :1266 disassembler): `new DrawMulti(new
DrawRegion("-bottom"), new DrawLiquidTile(), new DrawRegion("-spinner",
3, true), new DrawDefault())`. A DrawDefault-only port would be wrong
for both live blocks, so this slice ports the whole composition (every
Java line readable in place, no other slice needed). draw()
(Separator.java:105): `drawer.draw(this)`; drawLight() (:114-117):
super.drawLight() + drawer.drawLight(this); icons() (:71-73):
`drawer.finalIcons(this)`; drawPlanRegion() (:66-69):
`drawer.drawPlan(this, plan, list)`.

## Implementation

Two pures (the N2396 two-pure precedent):
- `source_separator_draw_state` (13 inputs, 6 results): `bottom_call`
  (rect `-bottom`, rot 0), `liquid_call` (size² tiles at ±relx·8,
  alpha amount/capacity, frame `fluidFrames[gas?1:0][animFrame]`,
  empty when alpha < 1/255), `spinner_call` (spinSprite, rot
  mod(totalProgress·3, 90), 2nd rect at r−90, alpha r/90),
  `base_call` (block.region, drawrot = 0 — Separator doesn't set
  rotate), `draw_light_call` (super.drawLight ONLY — **no DrawMulti
  member overrides drawLight**; radius size·30, opacity
  lightColor.a·visualLiquid, visual lerp clamp(0.06·delta) toward
  1/0 at the 0.01 threshold; slag light alpha 0.4 so the gate opens),
  `icon_regions` = `["block.name-bottom", "block.name-spinner",
  "block.region"]` (DrawLiquidTile contributes nothing).
- `source_separator_draw_plan_state` (7 inputs, 4 results):
  `plan_bottom_call`, `plan_spinner_call` (spin at 0), `plan_call`
  (fullIcon, rot 0), `plan_team_call` (overlay only when worldContext
  + player + teamRegion found; team color only when team_matches).

Def values verified: liquidCapacity separator 40 / disassembler 72
(Block.java:1406-1419). Pures placed at end of file, old logic
untouched (N2402/N2413 intact).

## Commits

- Slice: `fa6b62d82` (5 files).
- Integration cherry-pick: `c7f99c95b` (clean).

## Tests

Targeted (new module `tests.test_c07_separator_draw_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). 50/50 EXACT_EXPRS verbatim (incl. 2 arc Mathf
exprs via arc-upstream, the N2373 precedent). No duplicate `var` in
the new pures; no wrong `*f` builtins (only valid `fmod`/`clampf`).
Full gate (wave advances-25 integration, PID 9433, from 17:08): Ran 6682 tests in 1574.715s, FAILED (failures=345, skipped=5), 0 errors — 345/345 Godot-absent (338 inherited + 7 new proof tests N2417-N2423; N2416/N2424 add no proof test).

## SSOT / DEFERRED

SSOT single-slice **+10/+1/+2/+4** → 12141/1838/1771/3334 (**variance
vs the +5/+1/+1/+2 estimate:** the brief assumed DrawDefault; the
DrawMulti composition needs 2 pures with 10 result symbols). Audit
stays 1336. DEFERRED **#36 RESOLVED** (286→285, by entry TEXT; no new
entry).

## Godot debt

- NEW proof `C07SeparatorDrawRowsProof` (**9 keys**, not 6:
  `draw_bottom`, `draw_liquid`, `draw_spinner`, `draw_base`,
  `draw_light`, `draw_light_visual`, `draw_icons`,
  `draw_plan_region`, `draw_plan_team`) — written but NEVER run;
  debt in GOAL.md §5. Proof arithmetic hand-checked (tiles ±4,
  spinner 30/−60, visual 0→0.06, opacity 0.024, radius 60).
- No old proof needs a re-run (pure-only, no tick wiring).
