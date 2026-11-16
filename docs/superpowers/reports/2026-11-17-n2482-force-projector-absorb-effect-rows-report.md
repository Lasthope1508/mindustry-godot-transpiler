# Report N2482 — ForceProjector absorbEffect FX row

**Slice:** N2482 — ForceProjector absorbExplosion effect row
(DEFERRED #233). **Wave:** advances-33.
**Commit:** `0550a6665` on
`slice/N2482-force-projector-absorb-effect-rows` (base
`08b822909`). **Files:** 5, +761/−4.

## Source

ForceProjector.java (core/src/mindustry/world/blocks/defense/):
- absorbEffect Fx.absorb :49 (class default).
- absorbExplosion :269-277: `boolean absorb = !broken &&
  Intersector.isInRegularPolygon(sides, x, y, realRadius(),
  shieldRotation, ex, ey); if(absorb){ absorbEffect.at(ex, ey);
  hit = 1f; buildup += damage * crashDamageMultiplier; } return
  absorb;`
- The gate / hit / buildup are live since N2423
  (`source_force_projector_absorb_explosion_state`) — this
  slice is ONLY the absorbEffect.at FX.

## Implementation

One pure-only FX call record (no tick wiring — absorbExplosion
is explosion handling (Damage.explode / the unit crash path),
not updateTile; the effect call site waits for its own slice):
`source_force_projector_absorb_effect_state(absorb, ex, ey)` →
{absorb_effect_call} — when absorb is true: {effect:
"Fx.absorb", ex, ey}; null otherwise (the N2397 null-when-absent
precedent). The absorb verdict is a caller-supplied input (from
the N2423 pure's absorb result key). The N2423 pure and its
proof are unchanged by this slice.

**Verify-first findings:**
- **The single force-projector def does NOT override
  absorbEffect** (Blocks.java:1964-1976, verified by grep — no
  absorbEffect line in the def). The effect is Fx.absorb
  (`absorb = new Effect(12, e -> {`, Fx.java:1356); the 12-tick
  renderer body is the callee presentation — the pure records
  the CALL (the N2396 precedent).
- The call record uses the N2469 "Fx.<name>" form ({effect:
  "Fx.absorb", ex, ey} — not the N2470 "token" key form); the
  position is the explosion position (ex, ey), passed through
  untouched.
- **The shieldConsumer bullet path is a DIFFERENT call site**
  (ForceProjector.java:64-65, `paramBlock.hitSound.at(bullet.x,
  bullet.y, 1f + Mathf.range(0.1f), paramBlock.hitSoundVolume);`
  + `paramBlock.absorbEffect.at(bullet);`, hitSound =
  Sounds.shieldHit, :47, hitSoundVolume 0.12f, :48): it fires
  per absorbed BULLET in deflectBullets, not per explosion, so
  it defers under its own NEW DEFERRED entry, not this pure.

## Commits

- Slice: `0550a6665` (5 files, +761/−4).
- Integration cherry-pick: `088c197b0` (clean).

## Tests

Targeted (new module
`tests.test_c07_force_projector_absorb_effect_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (7 ForceProjector modules) Ran 28 (21
PASS + 7 proof Godot-absent), 0 errors.
Full gate (wave advances-33 integration, PID 8956, from 01:20): Ran 6902 tests in 1769.746s, FAILED (failures=400, skipped=5), 0 errors — 400/400 Godot-absent (393 inherited + 7 new proof tests N2476–N2482; Ran 6902 = 6874 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2 → 12383/1892/1845/3482** (exactly
as estimated). DEFERRED **#233 RESOLVED + 1 NEW ENTRY** (234→234,
by entry TEXT — new: "ForceProjector shieldConsumer absorb FX
rows" — the per-bullet sound + effect in deflectBullets).

## Godot debt

- NEW proof `C07ForceProjectorAbsorbEffectProof` (6 keys:
  `fx_on_absorb`, `fx_null_when_not_absorbed`, `fx_position`,
  `fx_token`, `fx_broken`, `fx_live_input`) — written but NEVER
  run; debt in GOAL.md §5.
- No old proof needs a re-run.
