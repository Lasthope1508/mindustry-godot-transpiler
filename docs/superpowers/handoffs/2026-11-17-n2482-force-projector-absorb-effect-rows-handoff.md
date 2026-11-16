# Handoff N2482 — ForceProjector absorbEffect FX row

## What this slice did

One pure-only FX call record (no tick wiring):
`source_force_projector_absorb_effect_state(absorb, ex, ey)` →
{absorb_effect_call} — {effect: "Fx.absorb", ex, ey} when
absorb, null otherwise. The absorb verdict is caller-supplied
(from the N2423 pure). 5 files, +761/−4, commit `0550a6665` on
`slice/N2482-force-projector-absorb-effect-rows`.

## Key facts for the next agent

- **The single force-projector def does NOT override
  absorbEffect** (Blocks.java:1964-1976, grep-verified).
- Call record uses the N2469 "Fx.<name>" form (not the N2470
  "token" key form); position is the explosion (ex, ey).
- **The shieldConsumer bullet path is a DIFFERENT call site**
  (:64-65, per absorbed BULLET in deflectBullets, hitSound =
  Sounds.shieldHit + absorbEffect.at(bullet)) — NEW DEFERRED
  entry, not this pure.
- The N2423 pure and its proof are unchanged.
- SSOT +1/+1/+1/+2 (exact est). DEFERRED #233 resolved + 1 new
  entry (234→234).

## Godot debt (this slice)

- NEW proof `C07ForceProjectorAbsorbEffectProof` (6 keys) —
  never run.
