# Handoff N2441 — BaseShield drawShield rows

## What this slice did

One pure-only draw pure `source_base_shield_draw_shield_state`
(no tick wiring): shield poly (animated vs static branch) +
hit-tinted color + select dash circle. 4 result symbols. New
consts SIDES 24 / LAYER_SHIELDS 125. 5 files, +893/−2, commit
`9afd5ac83` on `slice/N2441-base-shield-draw-shield-rows`.

## Key facts for the next agent

- **Defs:** shield-projector overrides nothing;
  large-shield-projector only radius 400f. Sides/shieldColor are
  consts/params.
- **Static fill alpha 0.09 + clamp(0.08*hit) is NOT clamped**
  (0.09..1.09 in Java) — recorded exactly.
- **dashCircle uses the FIELD radius**, survives broken.
  drawPlace is BaseShield.java:76-80 (not :77-82).
- SSOT +4/+1/+1/+2 (exact est). DEFERRED #12 resolved (266→265).

## Godot debt (this slice)

- NEW proof `C07BaseShieldDrawShieldRowsProof` (6 keys) — never
  run.
