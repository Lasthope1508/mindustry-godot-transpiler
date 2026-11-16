# Handoff N2487 — ForceProjector shieldConsumer absorb FX rows

## What this slice did

One pure-only FX call record: `source_force_projector_shield_consumer_absorb_fx_state`
returns {hit_sound_call, absorb_effect_call} — {token:
"shieldHit", x, y, pitch: 1.0 + pitch_roll, volume: 0.12} +
{effect: "Fx.absorb", x, y}; both null when not absorbed.
Pure-only, no tick wiring. 5 files, +842/−2, commit `a538381b3`
on `slice/N2487-force-projector-shield-consumer-absorb-fx-rows`.

## Key facts for the next agent

- The def overrides NEITHER hitSound, hitSoundVolume, NOR
  absorbEffect (Blocks.java:1964-1976).
- **The record uses the "token" key form** (N2468 precedent)
  — note the split: N2469/N2444 use "sound".
- Effect.at(Position) fires at bullet x/y, rotation 0, no
  extra args (Effect.java:105-107).
- Pitch roll in [−0.1, 0.1], caller-supplied, NO RNG in the
  pure.
- absorbExplosion :272 is a DIFFERENT call site (live since
  N2482), untouched.
- SSOT +2/+1/+1/+2 (exact est). DEFERRED #231 resolved
  (231→230). No new entry.

## Godot debt (this slice)

- NEW proof `C07ForceProjectorShieldConsumerAbsorbFxProof` (6
  keys) — never run. Live input composes the live N2235
  advance (FX fires for "inside" at (50, 50), null for
  "corner" at (95, 50)).
