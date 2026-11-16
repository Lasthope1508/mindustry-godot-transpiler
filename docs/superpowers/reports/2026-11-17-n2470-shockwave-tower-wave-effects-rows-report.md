# Report N2470 — ShockwaveTower wave effects / sound / shake rows

**Slice:** N2470 — ShockwaveTower wave effect / shoot sound / shake
+ per-target hit effect as pure-only call records. **Wave:**
advances-32. **Commit:** `c47d68982` on
`slice/N2470-shockwave-tower-wave-effects-rows` (base `99a167e15`).
**Files:** 5, +873/−2.

## Source

ShockwaveTower.java (core/src/mindustry/world/blocks/defense/):
the updateTile STATE is already live since N2247 — the N2247
advance runs the fire gate + bullet scan + wave damage + fire reset
+ heat decay (:73-104) — but the advance fires SILENTLY (pure
result only). The wave effect / sound / shake rows (:84-86) and the
per-target hit effect (:95) were never modeled. Fields: range =
110f (:25), shake = 2f (:29), shootSound = Sounds.shockwaveTower
(:32-33), waveColor = Pal.accent (:35-36).

## Implementation

One pure-only pure (no tick wiring — the N2468 precedent):
`source_shockwave_tower_wave_effects_state(fired, x, y,
range_value, pitch_roll, targets)` → {wave_effect_call,
shoot_sound_call, shake_call, hit_effect_calls}:
wave_effect_call {token "Fx.pointShockwave", x, y, range:
range_value, color "Pal.accent"} + shoot_sound_call {token
"shockwaveTower" (bare, the N2444/N2468 sound-token precedent),
pitch 1f + pitch_roll, volume 1.0} + shake_call {intensity 2.0,
duration 2.0} + hit_effect_calls (an Array of {token
"Fx.hitSquaresColor", x, y, color "Pal.accent"} — ONE per target,
empty when targets is empty). All calls null (hit list empty) when
the gate fails.

**Scoping (all source-backed):**
- The fire gate is the N2247 advance's — the pure takes `fired`
  (the N2247 fire verdict, true exactly when targets.size > 0
  inside the gate) as a caller-evaluated bool and does NOT recompute
  the gate (the N2397 precedent). The wave effect is the 4-arg .at
  with range + color (the range is the tower range, taken as a
  param).
- The hit effect fires ONCE per target, AFTER the wave damage
  branch for that target (:90-93) — but the damage application
  itself (#142) is NOT in scope: the pure takes targets as a
  caller-supplied Array of Dicts {x, y} and reports one hit call per
  target, in order. A non-Dict entry is skipped (the N2247 advance
  skips non-Dict candidates the same way).

**Verify-first findings:**
- Events.fire is :99, not :97 (guard :98) — out of scope (#40).
- The def range is 170f (Blocks.java:2043) over the class 110f —
  the pure takes range_value as a param, so either value works.

## Commits

- Slice: `c47d68982` (5 files, +873/−2).
- Integration cherry-pick: `5eed805ea` (clean).

## Tests

Targeted (new module
`tests.test_c07_shockwave_tower_wave_effects_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (11 ShockwaveTower modules): Ran 44
(33 PASS + 11 proof Godot-absent), 0 errors.
Full gate (wave advances-32 integration, PID 1721, from 00:31): Ran 6874 tests in 1607.276s, FAILED (failures=393, skipped=5), 0 errors — 393/393 Godot-absent (386 inherited + 7 new proof tests N2469–N2475; Ran 6874 = 6846 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+1/+2 → 12372/1885/1837/3466** (exactly as
estimated). DEFERRED **#141 RESOLVED** (238→237, by entry TEXT).

## Godot debt

- NEW proof `C07ShockwaveTowerWaveEffectsRowsProof` (6 keys:
  `hit_empty`, `hit_per_target`, `wave_fires`, `wave_gate`,
  `wave_pitch`, `wave_range_color`) — written but NEVER run; debt
  in GOAL.md §5.
- No old proof needs a re-run.
