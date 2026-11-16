# Report N2396 — MassDriver draw rows

**Slice:** N2396 — MassDriver draw rows: `draw` / `drawConfigure`
/ `drawPlace` / icons as pure rows (the draw half of old DEFERRED
#47 — the sense half went live in N2392). **Wave:** advances-22.
**Commit:** `5df8d003a` on `slice/N2396-mass-driver-draw-rows`
(base `78a74e152`). **Files:** 5, +1258/−1.

## Source

Java: MassDriver.java:230-242 (draw), :244-264 (drawConfigure),
:80-102 (drawPlace), :75-77 (icons). Verify-first: 4 cites fixed
at the start; the shadow offset uses Java INTEGER division (size
3 → 1); the drawPlace dash circle sits at x*tilesize WITHOUT
offset; absin at the doubled scale (12f, the N2372 precedent).

## Implementation

**3 pures** (draw / drawConfigure / drawPlace); icons are MERGED
into the draw pure as the result key `icon_regions` — a pure
`icons()` 0-arg FAILS the register because the validator requires
input keys non-empty (precedent for later icons() 0-arg slices).
Each draw call is registered separately (the N2372/N2373
precedent), which is why the symbol count exceeds the brief
estimate. The worker self-caught a `shooter_count` bug
(`arrow_calls.size()` is wrong when linked).

## Commits

- Slice: `5df8d003a` (5 files, +1258/−1).
- Integration cherry-pick: `68cb8b6d6` (clean).

## Tests

Targeted (new module `tests.test_c07_mass_driver_draw_rows`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly
None — NO Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-22 integration, PID 7151, from 14:50):
Ran 6602 tests in 1564.685s, FAILED (failures=326, skipped=5), 0 errors — 326/326 Godot-absent `AssertionError: unexpectedly None` (319 inherited + 7 new proof tests N2394–N2400; N2401 adds no test)..

## SSOT / DEFERRED

SSOT single-slice **+9/+1/+3/+6** → 12077/1820/1752/3296 (brief
estimated +5 symbols — each draw call registered separately).
Audit stays 1336. DEFERRED **#301 RESOLVED** (301→300, by entry
TEXT).

## Godot debt

- NEW proof `C07MassDriverDrawRowsProof` (6 keys:
  `draw_base_shadow`, `draw_configure_link`, `draw_place_range`,
  `draw_place_link_line`, `draw_icons`,
  `draw_live_frame_values`) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run.
