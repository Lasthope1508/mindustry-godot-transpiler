# Report N2430 — ImpactReactor draw rows

**Slice:** N2430 — ImpactReactor draw() + drawLight + icons(): a
new pure-only draw pure models the DrawMulti drawer (bottom /
plasma / base + plasma + liquid light + icons). **Wave:**
advances-26. **Commit:** `6c09a608e` on
`slice/N2430-impact-reactor-draw-rows` (base `cc1fe2ed0`). **Files:**
5, +1089/−1.

## Source

The class default drawer is DrawMulti (DrawRegion "-bottom" +
DrawPlasma + DrawDefault); the def `impact-reactor`
(Blocks.java:2632-2645) does **not** override the drawer — unlike
the N2419 Separator lesson, the class default IS the live drawer
here. DrawPlasma.draw: the plasma rect scaled by warmup with
absin time; DrawPlasma.drawLight + the super liquid light
(GeneratorBuild.drawLight, PowerGenerator.java:145-148). icons():
the DrawMulti finalIcons.

## Implementation

One pure-only draw pure `source_impact_reactor_draw_state` (12
inputs, pure-only, no tick wiring) — 5 result symbols:
`bottom_call`, `plasma_call`, `base_call`, `light_call`,
`icon_regions`. Documented limits (6) updated to "Draw rows live
(N2430)".

**Verify-first findings:**
1. **Def does not override the drawer** — the class default
   DrawMulti applies (the N2419 check was run and came out the
   other way).
2. **No RNG**: DrawPlasma.draw/drawLight roll nothing; the
   DrawFlame parent has `Mathf.random` but is fully overridden,
   so it never runs.
3. **Absin double-scale applied** (the helper = Java absin at
   scale/2); the proof pins the peak at time 2π (r₀ 19.5→22,
   alpha₀ 0.45→0.6).
4. **Light has both halves** (GeneratorBuild.drawLight,
   PowerGenerator.java:145-148): the DrawPlasma light + the super
   liquid light (cryofluid, alpha 0.2, radius size×30=120) — both
   in `light_call`.
5. **`lightRadius = 115f` is NOT used for a placed reactor** — it
   only feeds `Block.drawEnvironmentLight` for tiles without a
   building (BlockRenderer.java:842-844); a tile with a building
   calls `entity.drawLight()` instead.
6. **drawPlan is NOT ported in this slice** (the N2419 separate
   plan-pure precedent) → a new DEFERRED entry was added for the
   ImpactReactor drawPlan rows (net DEFERRED stays 280 in the
   register). `drawSelect` is the shared BuildingComp default, no
   family override.
7. Plasma `r` needs the atlas size (`width * scl()`) → the
   caller-supplied `plasma_region_sizes` input (a missing entry
   reads 0.0). No duplicate `var`, no `sqrtf` in the new/edited
   file.

## Commits

- Slice: `6c09a608e` (5 files, +1089/−1).
- Integration cherry-pick: `a297857f4` (clean).

## Tests

Targeted (new module `tests.test_c07_impact_reactor_draw_rows`):
3/4 PASS (registration, exact-evidence, row-state) + proof test
FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). RED confirmed first (2 errors
ledger + 1 fail missing pure + 1 Godot-absent).
Full gate (wave advances-26 integration, PID 16270, from 17:50): Ran 6710 tests in 1603.985s, FAILED (failures=352, skipped=5), 0 errors — 352/352 Godot-absent (345 inherited + 7 new proof tests N2425–N2431; N2432 adds no proof test; Ran 6710 = 6682 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+5/+1/+1/+2** → 12176/1845/1778/3348 (exactly
as estimated). Audit stays 1336. DEFERRED **#86 RESOLVED + 1 new
entry ADDED** (ImpactReactor drawPlan rows — the N2419 separate
plan-pure precedent): the register list is 280 (280−1+1).

## Godot debt

- NEW proof `C07ImpactReactorDrawRowsProof` (6 keys:
  `draw_bottom`, `draw_plasma_warmup_time`, `draw_base`,
  `draw_plasma_light`, `draw_plasma_cold`, `draw_plasma_time_peak`)
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
