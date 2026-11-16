# Report N2374 — LightBlock draw rows

**Slice:** N2374 — LightBlock draw / drawLight pures. **Wave:**
advances-19. **Commit:** `a969b12f3` on
`slice/N2374-light-block-draw-rows` (base `46b1b951b`). **Files:** 5,
+888/−4.

## Source

Java: LightBlock.java:96-102 (draw — topRegion + color alpha 0.6f),
:127-128 (drawLight — lightRadius * min(smoothTime, 2f) + brightness *
efficiency; lightRadius = radius*2.5f), :24 (topRegion @Load(\"@-top\")),
:112 (buildConfiguration color picker alpha 0.5f — NOT the draw
alpha). 15 exact exprs, all verified verbatim.

## Implementation

2 pures (draw + drawLight; NO drawSelect — LightBuild only overrides
draw/drawLight/updateTile); pure-only, no tick wiring (the N2356
pattern); color explicit param; lightRadius/brightness
caller-supplied, def-agnostic (illuminator 0.75f/140f → lightRadius
350).

⚠️ SCOPE CORRECTION: alpha 0.6f ≠ alpha 0.5f of the color picker
(buildConfiguration:112) — distinguished in code, proof, and register.

## Commits

- Slice: `a969b12f3` (5 files, +888/−4).
- Integration cherry-pick: `fdcd41dbb` (clean).

## Tests

Targeted (new module `tests.test_c07_light_block_draw_rows`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Exact-evidence 15/15.
Siblings Ran 8 (6 PASS + 2 proof Godot-absent), 0 other errors.
Full gate (wave advances-19 integration, PID 7308, 12:44–13:09): Ran 6522 tests in 1485.371s, FAILED (failures=306, skipped=5), 0 errors — 306/306 Godot-absent `AssertionError: unexpectedly None` (299 inherited + 7 new proof tests N2368–N2374; N2375 adds +1 pin test, N2376 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+2/+4** → 12020/1800/1731/3254. Audit stays
1336. DEFERRED **319 → 317** (the register base was the stale N2363
list at 319, not the merged 316 — the coordinator merged by entry
TEXT; −2: #123 + #119 drawLight — the brief allowed \"+ drawLight if
Java has it\", Java HAS it; no other slice holds drawLight).

## Godot debt

- NEW proof `C07LightBlockDrawRowsProof` (6 keys:
  `draw_top_region_rect`, `draw_color_alpha_06`,
  `draw_light_radius_clamp`, `draw_light_brightness_efficiency`,
  `draw_light_def_values`, `draw_live_frame_values`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
