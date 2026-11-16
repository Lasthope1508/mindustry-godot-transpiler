# Report N2431 — BuildTurret draw rows

**Slice:** N2431 — BuildTurret draw(): a new pure-only draw pure
models the base rect, the shadow, the region, the warmup glow,
and the drawBuilding call. **Wave:** advances-26. **Commit:**
`a1d76dce8` on `slice/N2431-build-turret-draw-rows` (base
`cc1fe2ed0`). **Files:** 5.

## Source

draw() (BuildTurret.java:234-251): rect(baseRegion); the shadow
at the field elevation; rect(region, x, y, rotation-90); the glow
(heatColor Pal.accent.cpy().a(0.9f), additive, alpha = warmup ×
0.9); drawBuilding when efficiency > 0 (strict). icons()
(:88-90): `{baseRegion, region}` — NOT ported in this slice (see
below).

## Implementation

One pure-only draw pure `source_build_turret_draw_state` (9
explicit params) — 5 result symbols: `base_call`, `shadow_call`,
`region_call`, `glow_call`, `build_call`.

**Findings beyond the brief (all verify-first):**
1. **The shadow shift is the field elevation**, init-lifted
   `size/2f` = 1.5 for the size-3 build-tower — verified first,
   not the RepairTurret literal (the N2421 shadow is a different
   value for a different block).
2. **Glow effective_alpha = warmup × 0.9** (heatColor
   Pal.accent.cpy().a(0.9f), no def override).
3. **The build_call gate is strict > 0** (efficiency > 0, not ≥).
4. **icons() (BuildTurret.java:88-90) is NOT ported and NO
   DEFERRED entry covers it** — found by this slice; the
   coordinator added a new DEFERRED entry at merge (the N2423
   FX-entry precedent).

## Commits

- Slice: `a1d76dce8` (5 files).
- Integration cherry-pick: `bfb303cb5` (clean).

## Tests

Targeted (new module `tests.test_c07_build_turret_draw_rows`): 3/4
PASS (registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this
VM (user order 2026-11-15). 27 exact exprs, all verified verbatim.
Full gate (wave advances-26 integration, PID 16270, from 17:50): Ran 6710 tests in 1603.985s, FAILED (failures=352, skipped=5), 0 errors — 352/352 Godot-absent (345 inherited + 7 new proof tests N2425–N2431; N2432 adds no proof test; Ran 6710 = 6682 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+5/+1/+1/+2** → 12176/1845/1778/3348
(**variance vs the +4 estimate:** the brief listed 5 result keys —
1 symbol per key, the N2421 precedent). Audit stays 1336.
DEFERRED **#96 RESOLVED** (280→279, by entry TEXT) + the
coordinator added 1 new entry at merge for the unported icons()
(BuildTurret.java:88-90).

## Godot debt

- NEW proof `C07BuildTurretDrawRowsProof` (6 keys:
  `draw_base_shadow_region`, `draw_build_call`,
  `draw_build_no_call`, `draw_glow_found`, `draw_glow_not_found`,
  `draw_rotation_elevation`) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
