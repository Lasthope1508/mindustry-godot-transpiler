# Report N2420 — LaunchPad draw / drawLiquid / icons rows

**Slice:** N2420 — LaunchPad draw() + icons(): a new pure-only draw
pure models the bottom/liquid, light loop, shadow, pod, and icons.
**Wave:** advances-25. **Commit:** `ad76ea5bb` on
`slice/N2420-launch-pad-draw-rows` (base `e4e57bca3`). **Files:** 5,
driver +124.

## Source

draw() (LaunchPad.java:104-136 — the brief/entry said :104–140, but
acceptItem starts at :138): if hasLiquids && drawLiquid != null:
color(bottomColor), Fill.square(x, y, size*tilesize/2f - liquidPad),
LiquidBlock.drawTiledFrames(size, x, y, liquidPad×4, drawLiquid,
liquids.get(drawLiquid)/liquidCapacity). super.draw(). If
lightRegion.found(): progress = min(items.total()/itemCapacity,
launchCounter/launchTime); 4×lightSteps loop: alpha =
Mathf.curve(progress, j/lightSteps, (j+1)/lightSteps); offset =
-(j-1)*lightStep; color(Pal.metalGrayDark, lightColor, alpha);
rect(lightRegion, x + d8edge(i).x*offset, y + d8edge(i).y*offset,
i*90). Drawf.shadow(x, y, size*tilesize); rect(podRegion). icons()
(:78-81): `{previewRegion}`.

## Implementation

One pure-only draw pure `source_launch_pad_draw_state` (16 explicit
params) + helper `_launch_pad_mathf_curve` (the FIRST Mathf.curve in
the port — no curve helper existed) + const
`SOURCE_LAUNCH_PAD_D8EDGE` [(1,1),(-1,1),(-1,-1),(1,-1)]. 6 result
symbols in Java draw order: `liquid_call` (Variant, null unless BOTH
hasLiquids and drawLiquid hold), `super_draw_call`, `light_calls`
(Array 4×lightSteps, each entry alpha/offset/x/y/rotation/progress/
color_from/color_to), `shadow_call`, `pod_call`, `icon_regions`
(["previewRegion"], N2396 precedent).

Def constants verify-first: lightColor `eab678`, lightStep 1f,
lightSteps 3, liquidPad 2f, bottomColor Pal.darkerMetal (`565666`),
drawLiquid null by default / oil only on the advanced def
(`liquidCapacity = 40f`). The per-tile truncation loop inside
drawTiledFrames (LiquidBlock.java:44-72) is recorded as a CALL (the
N2396 precedent), not ported tile-by-tile — that is the callee's
geometry. Theoretical edge (not guarded): itemCapacity = 0 +
items_total = 0 makes GDScript `minf(NaN, x)` differ from Java
`Math.min` (Java returns NaN); unreachable in practice (defs 100,
class default 10).

**Integration note:** this pure takes `liquid_capacity` as an
explicit input, which broke the N2400 verification pin
(`assertNotIn('liquid_capacity')`) — fixed by serial N2424 (the pin
now asserts exactly 2 occurrences: param + alpha ratio; still no
catalog/frame supplier for the Java 40f).

## Commits

- Slice: `ad76ea5bb` (5 files).
- Integration cherry-pick: `d9a891f74` (clean).

## Tests

Targeted (new module `tests.test_c07_launch_pad_draw_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Proof uses progress 0.25 (exact binary fraction)
to avoid float fragility: alpha j=0 is 0.75, j=1/2 are 0; offsets
1.0/0.0/-1.0; shadow 32.0/24.0; square half-size 14.0 (size 4).
Full gate (wave advances-25 integration, PID 9433, from 17:08): Ran 6682 tests in 1574.715s, FAILED (failures=345, skipped=5), 0 errors — 345/345 Godot-absent (338 inherited + 7 new proof tests N2417-N2423; N2416/N2424 add no proof test).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+1/+2** → 12137/1838/1770/3332 (exactly as
estimated). Audit stays 1336. DEFERRED **#45 RESOLVED** (286→285, by
entry TEXT; no new entry).

## Godot debt

- NEW proof `C07LaunchPadDrawRowsProof` (6 keys:
  `draw_liquid_branch`, `draw_light_progress`, `draw_light_loop`,
  `draw_shadow_pod`, `draw_icons`, `draw_super_base`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring; the N2400
  pin update in N2424 changed no proof file).
