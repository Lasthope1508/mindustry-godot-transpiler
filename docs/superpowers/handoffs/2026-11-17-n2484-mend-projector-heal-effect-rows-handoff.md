# Handoff N2484 — MendProjector heal effect rows

## What this slice did

One pure-only FX call record: `source_mend_projector_heal_effect_state`
returns {heal_effect_call} = {effect: "Fx.healBlockFull", x, y,
size, color: base_color, block: block_id} when healed, null
otherwise (N2397 precedent). Pure-only, no tick wiring. 5 files,
+826/−4, commit `e5daf198e` on
`slice/N2484-mend-projector-heal-effect-rows`.

## Key facts for the next agent

- **N2399 is RegenProjector, NOT MendProjector** — the brief
  was wrong; the healed verdict comes ONLY from the N2242 heal
  scan (damaged && !heal_suppressed && charge crossed).
- baseColor is "84f491" (MendProjector.java:23), neither def
  overrides; the token carries the STRING "baseColor".
- Size travels as the rotation arg of Effect.at(x, y, rotation,
  color, data) — the renderer does NOT read e.rotation, but the
  size is recorded faithfully because the CALL passes it.
- The effect fires PER healed building (eachBlock lambda
  :112-117).
- SSOT +1/+1/+1/+2 (exact est). DEFERRED #124 resolved
  (231→230). Neighbours #125 (mendSound) / #126
  (recentlyHealed) stay.

## Godot debt (this slice)

- NEW proof `C07MendProjectorHealEffectRowsProof` (6 keys)
  — never run. Live input composes the N2242 scan (charge 199
  + heat 1 = 200 ≥ reload 200, heal 4.0).
