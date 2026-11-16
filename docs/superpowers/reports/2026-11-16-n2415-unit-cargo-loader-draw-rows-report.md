# Report N2415 — UnitCargoLoader draw rows

**Slice:** N2415 — UnitCargoLoader draw rows: a new pure-only
draw pure models draw() — base rect + Drawf.construct (unit
null) or the poly ring (unit present). **Wave:** advances-24.
**Commit:** `2b39225c4` on
`slice/N2415-unit-cargo-loader-draw-rows` (base `a0e246e1f`).
**Files:** 5, +994/−1.

## Source

draw() (UnitCargoLoader.java:146-162): `Draw.rect(block.region,
x, y);` then if `unit == null`: on Layer.blockOver,
`Drawf.construct(this, unitType.fullIcon, 0f, buildProgress,
warmup, totalProgress);` — else: `Draw.z(Layer.bullet - 0.01f);
Draw.color(polyColor); Lines.stroke(polyStroke * readyness);
Lines.poly(x, y, polySides, polyRadius, Time.time *
polyRotateSpeed); Draw.reset(); Draw.z(Layer.block);`
Drawf.construct delegation (Drawf.java:574-579): (Building,
TextureRegion, rotation, progress, alpha, time) → Pal.accent →
sized overload, size = block.size × tilesize − 4f = 3×8−4 =
20f; shader rect (progress buildProgress, alpha warmup, shader
time −totalProgress/20f) + scan line `Lines.lineAngleCenter(t.x
+ Mathf.sin(time, 20f, size / 2f), t.y, 90, size)`.

## Implementation

One pure-only draw pure
`source_unit_cargo_loader_draw_state` (no tick wiring — draw
is presentation, stated in the docstring): base rect
(block.region at x,y) + EITHER construct call (unit null: icon,
rotation 0f, progress, alpha, time, Pal.accent, size 20f,
shader time, scan line) OR poly ring (unit present: sides 6,
radius 8f, rotation = time×1f, stroke = 1.8×readyness,
Pal.accent, z Layer.bullet−0.01f). Def constants added;
documented limits updated to "Draw rows live (N2415)" (bar +
read/write still defer). drawSelect/drawConfigure not added
(not overridden, not in the entry).

**Verify-first:** def constants polyStroke 1.8f / polyRadius 8f
/ polySides 6 / polyRotateSpeed 1f / polyColor Pal.accent
(:27-30, no def override — def Blocks.java:2270-2283 sets only
size 3 / unitBuildTime / consumers / itemCapacity). The sin is
the arc 3-arg form `return sin(radians / scl) * mag;`
(Mathf.java:90-92) → offset sin(totalProgress/20f)×10f. **No
absin here** — the N2372/N2382 double-scale precedent does not
apply. Frame keys confirmed from the driver: `unit` (null or
dict, N2211 gate), `build_progress` / `total_progress` /
`warmup` / `readyness` (N2234 advance). UnitCargoLoader has NO
`icons()` override — the only icon is `unitType.fullIcon`
(manifold) in the construct call, so it rides the draw pure as
the `construct_icon` result key (symbolic token
`"unitType.fullIcon"`, the literal Java expr), per the N2396
precedent. Time convention follows N2396/N2372: `time_value`
is caller-supplied (draw never runs in the tick); the pure
takes explicit params, no frame dict.

## Commits

- Slice: `2b39225c4` (5 files, +994/−1).
- Integration cherry-pick: `899141cb1` (clean).

## Tests

Targeted (new module
`tests.test_c07_unit_cargo_loader_draw_rows`): 3/4 PASS
(registration, exact-evidence — all 30 exact exprs verified
verbatim in upstream — row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM
(user order 2026-11-15).
Full gate (wave advances-24 integration, PID 1736, from 16:29): Ran 6651 tests in 1446.605s, FAILED (failures=338, skipped=5), 0 errors — 338/338 Godot-absent (333 inherited + 5 new proof tests N2410, N2411, N2412, N2414, N2415; N2409/N2413 add no proof test). Gate run 1 (PID 21111, from 16:13) was killed by VM restart #13 ~16:29 after ~16 min (no footer); javalang reinstalled, gate re-run.

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+1/+2** → 12114/1833/1765/3322
(exactly as estimated; 6 result symbols: base_call,
construct_call, construct_icon, poly_call, poly_rotation,
poly_stroke). Audit stays 1336. DEFERRED **#3 RESOLVED**
(291→290, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07UnitCargoLoaderDrawRowsProof` (6 keys:
  `draw_base_rect`, `draw_construct_branch`,
  `draw_construct_progress`, `draw_poly_branch`,
  `draw_poly_rotation`, `draw_poly_stroke`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
