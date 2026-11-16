# Report N2438 — ImpactReactor drawPlan rows

**Slice:** N2438 — ImpactReactor drawPlan() (DrawMulti: DrawRegion
"-bottom" + DrawPlasma + DrawDefault): a new pure-only plan pure
models the bottom plan rect, the default plan region, the generator
delegation, the (empty) plasma member, and the team overlay.
**Wave:** advances-27. **Commit:** `cc9ac3318` on
`slice/N2438-impact-reactor-draw-plan-rows` (base `91ee0f1dc`).
**Files:** 5, +858/−2.

## Source

DrawRegion drawPlan (DrawRegion.java:58-63): the "-bottom" plan
rect. DrawDefault drawPlan → block.drawDefaultPlanRegion
(DrawDefault.java:17-19; Block.java:856-867). PowerGenerator.
drawPlanRegion (PowerGenerator.java:84-85): delegates to
`drawer.drawPlan(this, plan, list)`. DrawPlasma has NO drawPlan()
override (nor does its parent DrawFlame) — the call lands on the
DrawBlock no-op base (DrawBlock.java:36-38).

## Implementation

One pure-only plan pure `source_impact_reactor_draw_plan_state`
(the N2419 separate plan-pure precedent) — 5 result symbols:
`plan_generator_call`, `plan_bottom_call`, `plan_plasma_call`,
`plan_call`, `plan_team_call`. The pure mirrors the N2419 Separator
plan pure exactly: same 7 inputs, same param names (`plan_drawx`,
`plan_drawy`, `plan_rotation`, `plan_world_context`,
`player_present`, `team_region_found`, `team_matches`).

**Verify-first findings (all 4 Java files read full before coding):**
1. **DrawPlasma draws NOTHING in the plan** — no `drawPlan()`
   override in DrawPlasma nor its parent DrawFlame; the call lands
   on the DrawBlock no-op base. `plan_plasma_call` is the empty
   dict recording that fact — the 5th symbol that makes the +5
   estimate land. The brief's "only bottom + default + generator"
   describes the members that *draw*; the empty plasma dict
   completes the DrawMulti member iteration in the result shape.
2. **PowerGenerator.drawPlanRegion draws NO region of its own** —
   it only delegates (`drawer.drawPlan(this, plan, list);`).
   `plan_generator_call` records the delegation (drawer + member
   order), not a rect.
3. **DrawDefault DOES have the team overlay** (via
   `Block.drawDefaultPlanRegion`, Block.java:856-867) —
   `plan_team_call` is kept.
4. Plan rotation folds to 0 in both rects (ImpactReactor sets no
   `rotate`, Block.java:120 default false); `drawPlanConfig` is
   the base no-op, so there is no config call. Icons are not
   repeated (live since N2430).

## Commits

- Slice: `cc9ac3318` (5 files, +858/−2).
- Integration cherry-pick: `912d3452b` (clean).

## Tests

Targeted (new module
`tests.test_c07_impact_reactor_draw_plan_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on
this VM (user order 2026-11-15). RED confirmed first (2 failures
+ 2 errors, incl. `KeyError: 'N2438'`). All 21 EXACT_EXPRS
verified verbatim against upstream.
Full gate (wave advances-27 integration, PID 4530, from 19:02): Ran 6738 tests in 1537.145s, FAILED (failures=359, skipped=5), 0 errors — 359/359 Godot-absent (352 inherited + 7 new proof tests N2433–N2439; Ran 6738 = 6710 + 28 new tests, exact arithmetic). Gate run 1 (PID 2236) invalid — VM restart #14 wiped javalang (Ran 6055, errors=15, all javalang-import).

## SSOT / DEFERRED

SSOT single-slice **+5/+1/+1/+2** → 12223/1852/1786/3364 (exactly
as estimated). Shards touched by the register (all reverted):
`source_api_contracts.json`, `source_state_schema.json`,
`source_slice_ledger.json`, `source_symbol_registry.json`,
`source_modules/power_api_contracts.json`,
`source_modules/power_slices.json`. Audit total unchanged.
DEFERRED **#272 RESOLVED** (273→272, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07ImpactReactorDrawPlanRowsProof` (6 keys:
  `draw_plan_bottom`, `draw_plan_default`, `draw_plan_generator`,
  `draw_plan_team_on`, `draw_plan_team_off`, `draw_plan_rotation`)
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
