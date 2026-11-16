# Report N2444 — LaunchPad launch sound / FX rows

**Slice:** N2444 — LaunchPad.updateTile launch sound +
Fx.launchPod + Effect.shake: a new pure-only FX pure records the
three launch calls. The pod creation stays with N2238/N2397.
**Wave:** advances-28. **Commit:** `c6b57ab17` on
`slice/N2444-launch-pad-launch-effect-rows` (base `682c75eb9`).
**Files:** 5, +823/−1.

## Source

updateTile (LaunchPad.java:141-160): when (launchCounter +=
edelta()) >= launchTime && items.total() >= itemCapacity:
consume(); launchSound.at(x, y, 1f +
Mathf.range(launchSoundPitchRand)) (:149); LaunchPayload create +
stacks + set + lifetime 120f + team + add (LIVE since N2238/N2397
— NOT re-ported); Fx.launchPod.at(this) (:156); items.clear();
Effect.shake(3f, 3f, this) (:158); launchCounter = 0f. Fields
(:33-34): launchSoundPitchRand = 0.1f, launchSound =
Sounds.padLaunch.

## Implementation

One pure-only pure `source_launch_pad_launch_effect_state(launched,
x, y, pitch_roll)` (no tick wiring). `launched` is a bool
caller-supplied — the advance N2238/N2397 owns the launch
condition, the pure does NOT recompute it. `pitch_roll` is a
caller-supplied float in [−0.1, 0.1] (the Mathf.range roll — the
N2421 NO-RNG-in-pure precedent). 3 result keys, null unless
launched: `sound_call` {sound "padLaunch", x, y, pitch 1f +
roll}, `fx_call` {effect "launchPod", x, y}, `shake_call`
{intensity 3f, duration 3f, x, y}.

**Verify-first findings:**
- `Sounds.padLaunch` token exact: `Sounds` is a build-generated
  class (`mindustry.gen.Sounds`, no gen/ dir in the checkout) —
  the brief's "grep Sounds.java" does not apply (no such file in
  upstream); the token was verified via the asset
  `core/assets/sounds/block/padLaunch.ogg` + LaunchPad.java:34.
- `Fx.launchPod`: `launchPod = new Effect(50, e -> {` (Fx.java:
  2747); `Fx.launchPod.at(this);` (LaunchPad.java:156).
- `Effect.shake(3f, 3f, this);` (LaunchPad.java:158); the
  overload `shake(float intensity, float duration, Position loc)`
  (Effect.java:210-212) delegates to `shake(intensity, duration,
  x, y)` (:201) → arg 1 = intensity, arg 2 = duration, both 3f.
  The camera-distance falloff (:204-207) is callee behavior —
  the pure only records CALL params (the N2396 precedent).
- `Mathf.range(r) = random(-range, range)` (arc
  `arc-core/src/arc/math/Mathf.java:220-222`) → roll ∈ [−0.1,
  0.1].

**Follow-through (coordinator, at integration):** DEFERRED #260
("LaunchPad updateTile launch fire") says "only launchSound /
Fx.launchPod / Effect.shake remain" — after N2444 all three are
live, so **#260 is retired at merge** (the N2429 #109-subset
precedent; the worker kept it per brief and flagged it). The
LaunchPad driver docstring items (3)/(8) + the N2238/N2397 pure
docs still said "sound/effects still defer" — fixed at
integration (commit `4dc97d683`; no test pinned those phrases).

## Commits

- Slice: `c6b57ab17` (5 files, +823/−1).
- Integration cherry-pick: `00b5ca3d0` (clean).

## Tests

Targeted (new module `tests.test_c07_launch_pad_launch_effect`):
3/4 PASS (registration, exact-evidence, row-state) + proof test
FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). RED confirmed first (KeyError
'N2444' + missing pure + Godot-absent proof).
Full gate (wave advances-28 integration, PID 12844, from 20:00): Ran 6762 tests in 1613.764s, FAILED (failures=365, skipped=5), 0 errors — 365/365 Godot-absent (359 inherited + 6 new proof tests N2440–N2445; Ran 6762 = 6738 + 24 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 12262/1859/1794/3380 (exactly
as estimated); audit totalSourceFunctions stays 1336. Register
changed only the 4 canonical generated files (no shard).
DEFERRED **#131 RESOLVED** (266→265, by entry TEXT; no new entry).
#260 retired at merge by the coordinator (see above).

## Godot debt

- NEW proof `C07LaunchPadLaunchEffectProof` (6 keys:
  `effect_null_when_not_launched`, `effect_sound_pitch` (±0.1
  bounds), `effect_fx_call`, `effect_shake_params`,
  `effect_xy_passthrough`, `effect_live_frame_values` — full pad
  launch via the N2238 advance) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
