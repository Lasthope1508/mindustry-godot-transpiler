# Report N2436 — BeamDrill draw / drawSelect rows

**Slice:** N2436 — BeamDrill draw() + drawSelect(): a new pure-only
draw pure models the base/top rects, the per-facing laser loop
(centered vs laser branches, boost gates), the Lod.l2 sparks with
caller-supplied rolls, the glow, the select call, and the icons.
**Wave:** advances-27. **Commit:** `a0833ef8a` on
`slice/N2436-beam-drill-draw-rows` (base `91ee0f1dc`). **Files:** 5,
+1520 lines (driver +402).

## Source

drawSelect (BeamDrill.java:231-234): drawItemSelection(lastItem).
draw() (:275-357): rect(block.region, x, y); rect(topRegion, x, y,
rotdeg()); if isPayload() return; per facing tile i < size: face =
facing[i] (null → skip), drop = face.wallDrop() (null → continue),
p = lasers[i]; width = (laserWidth + absin(Time.time + i*5 +
(id%9)*9, glowScl, pulseIntensity)) * warmup; mixcol(glowColor,
absin(Time.time + i*5 + id*9, glowScl, glowIntensity)); centered
(|p−face| == 0): scl(width), laserCenter when boostWarmup < 0.99,
laserCenterBoost when boostWarmup > 0.01; else the laser branch:
Drawf.laser(laser, laserEnd, lsx, lsy, lx, ly, width) + the boost
variant when boostWarmup > 0.001. Lod.l2 sparks: rand.setState(i,
id); spark = sparkColor lerp boostHeatColor by boostWarmup; j <
sparks: fin = (Time.time/sparkLife + rand.random(sparkRecurrence+1))
% sparkRecurrence; or = rand.range(2f); v1 = (sparkRange*fin, 0)
.rotated(rotdeg() + rand.range(sparkSpread)); if fin ≤ 1:
lineAngle(..., slope(fin) * sparkSize). The glow: if
glowRegion.found(): additive, color(heatColor lerp boostHeatColor,
warmup * (heatColor.a * (1 − heatPulse + absin(heatPulseScl,
heatPulse)))), rect(glowRegion, rotdeg()).

## Implementation

One pure-only draw pure `source_beam_drill_draw_state` (21
caller-supplied inputs, the tick never calls it) — 8 result
symbols: `base_call`, `top_call`, `laser_calls`, `glow_call`,
`select_call`, `icon_regions`, `draw_rotation`, `payload_return`.
The payload early return skips lasers + glow and keeps base/top/
select/icons. The sparks take caller-supplied rolls (3/spark in
Java order: random, range(2), range(spread); the fin gate ≤ 1; the
slope is the inline triangle). The select call records
`drawItemSelection(lastItem)`; icons() = `["region", "topRegion"]`.

**Findings beyond the brief:**
1. **Def override found (brief said verify-first):**
   large-plasma-bore overrides `laserWidth = 0.7f`
   (Blocks.java:3061) over the 0.65f class default — so
   `laser_width` is a caller-supplied input, not a constant. All
   other draw fields take class defaults (no def overrides) and
   ride driver constants.
2. **Brief shape gap:** the brief's facing entry `{world_x,
   world_y, drop}` lacks tile coords, but the centered check
   `|p.x − face.x| + |p.y − face.y| == 0` reads Tile tile coords
   — the worker added `tile_x`/`tile_y` alongside world coords,
   documented in register rule + driver docstring.
3. **Two asymmetries preserved exactly** (the proof checks the
   0.01/0.99 boundaries): the width absin reads `(id % 9)*9`
   while mixcol reads `id*9`; the center boost gate is `> 0.01`
   while the laser boost gate is `> 0.001`.
4. **Slope verified, not guessed:** `Mathf.slope(fin) = 1 −
   |fin − 0.5| * 2` (arc Mathf.java:594-596), triangle 0→1→0,
   computed inline (SourceMathState has no slope helper).
5. **Self-fix during the slice:** the first register run failed
   `source-backed requires java_method` — the worker had dropped
   `java_method` from the symbol dict vs the N2431 pattern;
   fixed, reverted generated/, clean re-run.

## Commits

- Slice: `a0833ef8a` (5 files, +1520).
- Integration cherry-pick: `854ece461` (clean).

## Tests

Targeted (new module `tests.test_c07_beam_drill_draw_rows`): 3/4
PASS (registration, exact-evidence incl. arc-upstream sources,
row-state) + proof test FAIL exactly AssertionError: unexpectedly
None — NO Godot binary on this VM (user order 2026-11-15). RED
confirmed first (KeyError 'N2436' + pure-not-found + Godot-absent
proof). **Neighbours BeamDrill (per the brief's pin warning):**
all 10 `test_c07_beam_drill_*` modules incl. N2339 facing scan,
N2352 facing-tile fill, N2405 dump neighbour live fill, N2363
timer-dump write-back → Ran 40, 30 PASS, 10 failures all
Godot-absent proof tests, 0 errors — no pin breaks. Duplicate-`var`
sweep on the new pure: none (48 vars, the N2416 lesson); no
`sqrtf`.
Full gate (wave advances-27 integration, PID 4530, from 19:02): Ran 6738 tests in 1537.145s, FAILED (failures=359, skipped=5), 0 errors — 359/359 Godot-absent (352 inherited + 7 new proof tests N2433–N2439; Ran 6738 = 6710 + 28 new tests, exact arithmetic). Gate run 1 (PID 2236) invalid — VM restart #14 wiped javalang (Ran 6055, errors=15, all javalang-import).

## SSOT / DEFERRED

SSOT single-slice **+8/+1/+1/+2** → 12226/1852/1786/3364 (exactly
as estimated). Audit stays 1336. DEFERRED **#143 RESOLVED**
(273→272, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07BeamDrillDrawRowsProof` (6 keys: `draw_base_top`,
  `draw_laser_centered`, `draw_laser_branch_boost`,
  `draw_sparks_rolls`, `draw_glow`, `draw_select`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
