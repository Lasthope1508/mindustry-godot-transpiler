# Handoff N2423 — ForceProjector absorbExplosion rows

## What this slice did

One pure-only pure
`source_force_projector_absorb_explosion_state` (no tick wiring):
absorb gate (REUSE `is_in_regular_polygon` from N2235) + hit_value /
hit_set + buildup_delta (damage×2f). New const
SOURCE_FORCE_PROJECTOR_CRASH_DAMAGE_MULTIPLIER := 2.0. N2235
docstring updated (absorbExplosion live N2423, only FX defers).
5 files, +866/−1, commit `e14717dfd` on
`slice/N2423-force-projector-absorb-explosion`.

## Key facts for the next agent

- **Hit splits into 2 keys** (hit_value + hit_set) — the brief's
  design; the pure also takes the current `hit` as input.
- **Callers are explosion handling** (Damage.java:113,
  UnitComp.java:906), not updateTile — hence pure-only.
- **Stale base:** the register copied the N2415 list (290 entries);
  the coordinator merged by entry TEXT.
- SSOT +4/+1/+1/+2 (est +3). DEFERRED #148 resolved + 1 FX entry
  added.

## Godot debt (this slice)

- NEW proof `C07ForceProjectorAbsorbExplosionProof` (6 keys) —
  never run.
