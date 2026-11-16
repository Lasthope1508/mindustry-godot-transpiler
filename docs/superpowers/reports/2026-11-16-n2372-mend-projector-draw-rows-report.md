# Report N2372 — MendProjector draw rows

**Slice:** N2372 — MendProjector draw / drawSelect / drawPlace /
drawLight pures. **Wave:** advances-19. **Commit:** `41aa653de` on
`slice/N2372-mend-projector-draw-rows` (base `46b1b951b`). **Files:**
5, +1220/−5.

## Source

Java: MendProjector.java:122-170 (draw / drawSelect / drawPlace /
drawLight), :107 (realRange = range + phaseHeat * phaseRangeBoost),
:126-129 (sense), :133-137 (drawSelect range display);
Blocks.java:1919-1942 (lightRadius / brightness defs — neither def
overrides, lightRadius 50f driver constant); Mathf.java:78-80 (absin).
28 exact exprs, all verified verbatim.

## Implementation

3 pures (draw_rows + drawSelect/drawPlace shared + drawLight r50 ×
smoothEff); pure-only, no tick wiring (the N2356 pattern). Lod via
explicit `lod_l2` / `lod_alpha2` params (defaults true/1.0); `f` is
reported even when hidden (Java computes f before the guard).

⚠️ SCOPE CORRECTIONS: (1) The pure was renamed `draw_state` →
`draw_rows_state` — the `source_mend_projector_draw_state_*` schemas
already existed (older display path) and the first register run
OVERWROTE 11 display keys; after the rename the re-run was purely
additive. Always check whether a schema name already exists before
registering a new pure. (2) absin is Java-exact at DOUBLED scale:
Java `absin(in,scl,mag) = (sin(in,scl*2f,mag)+mag)/2f`
(Mathf.java:78-80) vs the port helper
`(sin(v/scl)*0.5+0.5)*mag` — helper(v,s) == Java(v,s/2). The pures
pass doubled scale (100/PI2 for draw, 8f for select).

## Commits

- Slice: `41aa653de` (5 files, +1220/−5).
- Integration cherry-pick: `9a265923b` (clean).

## Tests

Targeted (new module `tests.test_c07_mend_projector_draw_rows`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 28/28.
Siblings Ran 32 (24 PASS + 8 proof Godot-absent), 0 other errors.
Full gate (wave advances-19 integration, PID 7308, 12:44–13:09): Ran 6522 tests in 1485.371s, FAILED (failures=306, skipped=5), 0 errors — 306/306 Godot-absent `AssertionError: unexpectedly None` (299 inherited + 7 new proof tests N2368–N2374; N2375 adds +1 pin test, N2376 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+5/+1/+3/+6** → 12023/1800/1732/3256. Audit stays
1336. DEFERRED **316 → 315** (−1: #1 rewritten to sense-only + #23
REMOVED — its only open item was the drawSelect display).

## Godot debt

- NEW proof `C07MendProjectorDrawRowsProof` (7 keys:
  `draw_top_region_alpha`, `draw_square_geometry`, `draw_lod_guard`,
  `draw_select_dash_circle`, `draw_place_dash_circle`,
  `draw_light_radius_alpha`, `draw_live_frame_values`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through (backlog, NOT touched here): the display path
  `SourceMendProjectorDisplayState.draw_state` (and Overdrive's) pass
  undoubled 50/PI2 to `source_absin`, oscillating 2× Java speed —
  needs its own slice.
