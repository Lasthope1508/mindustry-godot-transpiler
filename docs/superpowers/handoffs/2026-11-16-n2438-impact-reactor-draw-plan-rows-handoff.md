# Handoff N2438 — ImpactReactor drawPlan rows

## What this slice did

One pure-only plan pure `source_impact_reactor_draw_plan_state`
(N2419 precedent, no tick wiring): generator delegation + bottom
plan rect + (empty) plasma member + default plan region + team
overlay. Mirrors the N2419 Separator plan pure exactly (same 7
inputs, same param names). 5 files, +858/−2, commit `cc9ac3318`
on `slice/N2438-impact-reactor-draw-plan-rows`.

## Key facts for the next agent

- **DrawPlasma draws NOTHING in the plan** (no override — the
  DrawBlock no-op base); `plan_plasma_call` is the empty dict
  recording that.
- **PowerGenerator.drawPlanRegion only delegates** (no region of
  its own). **DrawDefault DOES have the team overlay.**
- **Plan rotation folds to 0** (no `rotate` set). Icons not
  repeated (live N2430).
- SSOT +5/+1/+1/+2 (exact est). DEFERRED #272 resolved (273→272).

## Godot debt (this slice)

- NEW proof `C07ImpactReactorDrawPlanRowsProof` (6 keys) — never
  run.
