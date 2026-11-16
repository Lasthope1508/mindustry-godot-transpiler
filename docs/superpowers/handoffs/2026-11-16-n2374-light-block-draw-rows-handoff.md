# Handoff N2374 — LightBlock draw rows

## What this slice did

LightBlock draw / drawLight pures (pure-only, no tick wiring; NO
drawSelect — LightBuild only overrides draw/drawLight/updateTile).
5 files, +888/−4, commit `a969b12f3` on
`slice/N2374-light-block-draw-rows`.

## Key facts for the next agent

- Alpha 0.6f (draw) ≠ alpha 0.5f (color picker, :112) — distinguished
  in code/proof/register.
- lightRadius/brightness caller-supplied, def-agnostic (illuminator
  0.75f/140f → lightRadius 350).
- SSOT +2/+1/+2/+4. DEFERRED 319→317 (#123 + #119; stale N2363 base —
  merge by entry TEXT).

## Godot debt (this slice)

- NEW proof `C07LightBlockDrawRowsProof` (6 keys) — never run.
