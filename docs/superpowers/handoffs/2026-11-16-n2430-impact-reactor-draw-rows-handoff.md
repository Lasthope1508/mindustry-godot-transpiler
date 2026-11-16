# Handoff N2430 — ImpactReactor draw rows

## What this slice did

One pure-only draw pure `source_impact_reactor_draw_state` (12
inputs, no tick wiring): bottom / plasma / base + plasma + liquid
light + icons (class default DrawMulti — the def does NOT override
the drawer). 5 files, +1089/−1, commit `6c09a608e` on
`slice/N2430-impact-reactor-draw-rows`.

## Key facts for the next agent

- **Def does not override the drawer** (N2419 check came out the
  other way). **No RNG** (DrawFlame's random is fully overridden).
- **Light has both halves** (DrawPlasma + super liquid cryofluid,
  alpha 0.2, radius 120). **lightRadius 115f is only for
  unbuilt tiles** (drawEnvironmentLight).
- **drawPlan NOT ported** (N2419 precedent) → +1 DEFERRED entry.
  Plasma r needs atlas size → `plasma_region_sizes` input.
- SSOT +5/+1/+1/+2 (exact est). DEFERRED #86 resolved + 1 added.

## Godot debt (this slice)

- NEW proof `C07ImpactReactorDrawRowsProof` (6 keys) — never run.
