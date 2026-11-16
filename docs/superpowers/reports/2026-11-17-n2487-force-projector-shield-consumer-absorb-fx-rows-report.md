# Report N2487 — ForceProjector shieldConsumer absorb FX rows

**Slice:** N2487 — ForceProjector shieldConsumer absorb FX rows
(DEFERRED #231). **Wave:** advances-34. **Commit:** `a538381b3`
on `slice/N2487-force-projector-shield-consumer-absorb-fx-rows`
(base `ad308cf7e`). **Files:** 5, +842/−2.

## Source

ForceProjector.java (core/src/mindustry/world/blocks/defense/):
the shieldConsumer bullet path :64-65
(`paramBlock.hitSound.at(bullet.x, bullet.y, 1f +
Mathf.range(0.1f), paramBlock.hitSoundVolume);` +
`paramBlock.absorbEffect.at(bullet);`); hitSound =
Sounds.shieldHit (:47); hitSoundVolume 0.12f (:48); absorbEffect
= Fx.absorb (:49). `deflectBullets` is :258-267;
`absorbExplosion` is :269-277 (effect call :272 — a DIFFERENT
call site, untouched). Sounds.shieldHit is build-generated, but
the asset is exact: core/assets/sounds/shieldHit.ogg (the N2444
precedent). `Effect.at(Position)` → `create(pos.getX(),
pos.getY(), 0, Color.white, null)` (Effect.java:105-107) —
fires at bullet x/y, rotation 0, no extra args. `Mathf.range(r)
= random(-r, r)` (arc Mathf.java:220-222), so the caller-supplied
roll is in [−0.1, 0.1]. The 4-arg `Sound.at(x, y, pitch,
volume)` is verified (arc Sound.java:188-189).

## Implementation

One pure-only FX call record (no tick wiring — the sound/effect
call sites wait for audio/effect slices, not a ForceProjector
deferral):
`source_force_projector_shield_consumer_absorb_fx_state(absorbed, bullet_x, bullet_y, pitch_roll)`
→ {hit_sound_call, absorb_effect_call} — hit_sound_call {token:
"shieldHit", x, y, pitch: 1.0 + pitch_roll, volume: 0.12},
absorb_effect_call {effect: "Fx.absorb", x, y}; both null when
not absorbed (the N2397 null-when-absent precedent). The N2423 /
N2482 pures and proofs are unchanged.

**Verify-first findings:**
- **The force-projector def overrides NEITHER hitSound,
  hitSoundVolume, NOR absorbEffect** (Blocks.java:1964-1976);
  the only `hitSound` overrides in Blocks.java are
  explosionTitan rows (:4655/:4689/:4749, other blocks).
- **The record uses the "token" key form** (the N2468
  precedent, brief-prescribed; the proof key `fx_sound_token`
  agrees) — note the precedent split: N2469 drillImpact and
  N2444 padLaunch use "sound", N2468 shockwaveTower uses
  "token".
- NO RNG in the pure (the N2421 precedent) — the pitch roll
  is caller-supplied.

## Commits

- Slice: `a538381b3` (5 files, +842/−2).
- Integration cherry-pick: `015d1b36e` (clean).

## Tests

Targeted (new module
`tests.test_c07_force_projector_shield_consumer_absorb_fx_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (7 ForceProjector modules) Ran 28 (21
PASS + 7 proof Godot-absent), 0 errors.
Full gate (wave advances-34 integration): run 1 (PID 16663, from 02:12) KILLED by VM restart #18 ~02:32 (no footer); run 2 (PID 1769, 02:33–03:08): Ran 6930 tests in 1643.573s, FAILED (failures=407, skipped=5), 0 errors — 407/407 Godot-absent (400 inherited + 7 new proof tests N2484–N2490; Ran 6930 = 6902 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2 → 12403/1899/1853/3498** (exactly as
estimated). DEFERRED **#231 RESOLVED** (231→230, by entry TEXT).
No new entry (sound/effect call sites wait for audio/effect
slices, not a ForceProjector deferral).

## Godot debt

- NEW proof `C07ForceProjectorShieldConsumerAbsorbFxProof` (6
  keys: `fx_on_absorb`, `fx_null_when_not_absorbed`,
  `fx_sound_token`, `fx_pitch_roll`, `fx_position`,
  `fx_live_input` — live input composes the live N2235 advance:
  absorbed ["center", "inside"], buildup delta 15.0, hit 1.0;
  FX fires for "inside" at (50, 50), null for "corner" at (95,
  50)) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
