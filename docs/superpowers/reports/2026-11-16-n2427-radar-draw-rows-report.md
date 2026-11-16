# Report N2427 — Radar draw / drawSelect / icons + drawPlace rows

**Slice:** N2427 — Radar draw() + drawSelect + drawPlace + icons():
a new pure-only draw pure models the base/region/glow, the select
dash circle, the place dash circle, and the icons. **Wave:**
advances-26. **Commit:** `3c7ef85fd` on
`slice/N2427-radar-draw-rows` (base `cc1fe2ed0`). **Files:** 5.

## Source

draw() (Radar.java:85-90): rect(region) rotating at
`rotateSpeed * totalProgress`; the glow rect with absin scale
(`glowScl`, `glowMag`) and alpha from `glowAlpha`. drawSelect
(:91+): `Drawf.dashCircle(x, y, fogRadius() * tilesize,
Pal.accent)` — note the METHOD call. drawPlace (:42-46): the dash
circle at the FIELD `fogRadius * tilesize`. icons() (:59-63):
`{region}` + glow.

## Implementation

One pure-only draw pure `source_radar_draw_state` — 6 result
symbols: `base_call`, `region_call`, `glow_call`, `select_call`,
`place_call`, `icon_regions`.

**Findings beyond the brief (all verify-first):**
1. **fogRadius() the METHOD really differs from the FIELD** —
   method = fogRadius × progress × smoothEfficiency
   (Radar.java:55-57), field = def 34. The pure takes BOTH inputs
   (`fog_radius` for place, `fog_radius_live` for select); the
   proof pins half-discovery select 136 vs place 272.
2. **Absin double-scale verified by the arc formula** (the
   N2372/N2382 precedent): the pure passes `glow_scl×2.0` into
   `source_absin`; the proof pins t=0 → 0.3 / alpha 0.7 and
   t=5π → 0.6 / alpha 1.0.
3. **3 extra inputs:** `tile_x`/`tile_y` (drawPlace takes tile
   coords), `fog_radius_live`, `glow_alpha`. SSOT has no Color
   type — colors ride as String tokens.

## Commits

- Slice: `3c7ef85fd` (5 files).
- Integration cherry-pick: `6a8a30dc4` (clean).

## Tests

Targeted (new module `tests.test_c07_radar_draw_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15).
Full gate (wave advances-26 integration, PID 16270, from 17:50): Ran 6710 tests in 1603.985s, FAILED (failures=352, skipped=5), 0 errors — 352/352 Godot-absent (345 inherited + 7 new proof tests N2425–N2431; N2432 adds no proof test; Ran 6710 = 6682 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+6/+1/+1/+2** → 12177/1845/1778/3348 (**variance
vs the +5 estimate:** the brief listed 6 result keys). Audit stays
1336. DEFERRED **#44 + #45 RESOLVED** (280→278, by entry TEXT; no
new entry).

## Godot debt

- NEW proof `C07RadarDrawRowsProof` (6 keys:
  `draw_base_region_rotation`, `draw_glow_absin`,
  `draw_icons_merged`, `draw_place_dash_circle`,
  `draw_select_dash_circle`, `draw_total_progress_zero_edge`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
