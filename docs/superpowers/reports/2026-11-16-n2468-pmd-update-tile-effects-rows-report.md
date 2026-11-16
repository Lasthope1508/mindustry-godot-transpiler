# Report N2468 — PayloadMassDriver updateTile effects / sound / shake rows

**Slice:** N2468 — PayloadMassDriver updateTile effects: two
pure-only pures model the receive + shoot effect/sound/shake call
records (pitch rolls caller-supplied, no RNG in pures).
**Wave:** advances-31. **Commit:** `83a41ab4f` on
`slice/N2468-pmd-update-tile-effects-rows` (base `43a5c79ad`).
**Files:** 5, +974/−0.

## Source

PayloadMassDriver.java (core/src/mindustry/world/blocks/payloads/):
- Fields: shootEffect = Fx.shootBig2 :32; smokeEffect =
  Fx.shootPayloadDriver :33; receiveEffect = Fx.payloadReceive :34;
  shootSound = Sounds.massdriver :35; receiveSound =
  Sounds.massdriverReceive :36; shootSoundVolume = 0.7f :37; shake
  = 3f :38; transferEffect = new Effect(11f, 600f, ...) :40
  (lifetime 11f); length = 89/8f = 11.125 (:25).
- Receive branch :173-181: `boolean pos = effectDelayTimer > 0;
  effectDelayTimer -= Time.delta; if(effectDelayTimer <= 0 && pos
  && lastOther != null){ var other = lastOther; float cx =
  Angles.trnsx(other.turretRotation, length), cy = Angles.trnsy(
  other.turretRotation, length); receiveEffect.at(x - cx/2f, y -
  cy/2f, turretRotation); reloadCounter = 1f; Effect.shake(shake,
  shake, this); receiveSound.at(x, y, 1f + Mathf.range(0.2f),
  shootSoundVolume); }`
- Shoot branch :292-304: `if(charge >= chargeTime){ float cx =
  Angles.trnsx(turretRotation, length), cy = Angles.trnsy(
  turretRotation, length); shootEffect.at(x + cx, y + cy,
  turretRotation); smokeEffect.at(x, y, turretRotation);
  Effect.shake(shake, shake, this); shootSound.at(x, y,
  Mathf.random(0.9f, 1.1f), shootSoundVolume); transferEffect.at(
  x + cx, y + cy, turretRotation, new PayloadMassDriverData(x + cx,
  y + cy, other.x - cx, other.y - cy, payload));
  other.effectDelayTimer = transferEffect.lifetime; ... }`
- Effect.shake args = intensity/duration (Effect.java:210-212 —
  N2444 precedent); Mathf.range(r) = random(−r, r) (arc
  Mathf.java:220-222); Mathf.random(a, b) = uniform in [a, b].

## Implementation

Two pure-only pures (no tick wiring — the N2444 precedent):
1. `source_payload_mass_driver_receive_effects_state(
   effect_delay_crossed, last_other, x, y, turret_rotation, length,
   pitch_roll)` → `{receive_effect_call, receive_sound_call,
   shake_call, reload_counter_after}`. Gate: effect_delay_crossed
   (the timer was > 0 and is now ≤ 0 — caller-evaluated) &&
   last_other != null. last_other is null-or-Dict
   {turret_rotation}. cx/cy = trns(last_other.turretRotation,
   length); effect at (x − cx/2f, y − cy/2f, turretRotation) with
   token "Fx.payloadReceive"; sound pitch = 1f + pitch_roll (roll
   in [−0.2, 0.2]), volume 0.7f; shake = {intensity: 3.0, duration:
   3.0}; reload_counter_after = 1f when fired (a STATE stamp,
   reported not wired — the state-branches advance N2246 does not
   call effects), else null. All calls null when the gate fails.
2. `source_payload_mass_driver_shoot_effects_state(charge_fired, x,
   y, turret_rotation, length, pitch_roll, other_x, other_y,
   payload)` → `{shoot_effect_call, smoke_effect_call,
   transfer_effect_call, shoot_sound_call, shake_call,
   effect_delay_timer_after}`. Gate: charge_fired (charge >=
   chargeTime — caller-evaluated). cx/cy = trns(turretRotation,
   length); shoot effect at (x + cx, y + cy, turretRotation) token
   "Fx.shootBig2"; smoke at (x, y, turretRotation) token
   "Fx.shootPayloadDriver"; sound pitch = pitch_roll (roll in
   [0.9, 1.1]), volume 0.7f; shake = {3.0, 3.0}; transfer effect
   CALL {x: x + cx, y: y + cy, rotation: turretRotation, data:
   {from: {x: x + cx, y: y + cy}, to: {x: other_x − cx, y: other_y
   − cy}, payload}}; effect_delay_timer_after = 11f
   (transferEffect.lifetime) when fired, else null. All calls null
   when the gate fails.

**Shape notes (brief-driven, differing from N2444 in 2 places):**
shake = {intensity, duration} (NOT x/y like N2444); effect tokens
use the full "Fx.*" form ("Fx.payloadReceive" / "Fx.shootBig2" /
"Fx.shootPayloadDriver" — N2444 used bare "launchPod"); sound
tokens are bare ("massdriver" / "massdriverReceive", per N2444);
transfer token is "transferEffect" (the field name, not an Fx.*).
Sound calls carry volume 0.7f (Java `.at(x, y, pitch, volume)`
4-arg); effect calls carry rotation (Java `.at(...,
turretRotation)`). transferEffect is a CALL record with the
PayloadMassDriverData params (the N2396 precedent — the callee's
geometry is NOT ported).

**Verify-first findings:**
- **Brief line cites off by 1:** receive is :173-181 (brief
  :172-182; pos :173, sound :181); shoot gate :292, stamp
  effectDelayTimer :304 (brief :293-301). The DEFERRED entry's
  cites (:177-181 / :296-301) are correct. Real line numbers used.
- **DEFERRED #147 overlaps the shoot half:** entry "PayloadMassDriver
  transfer effects / sound / shake rows (:295-301)" covers the same
  shoot lines as #144. The worker resolved ONLY #144 per the brief
  and left #147 for the coordinator — **retired at merge** (the
  N2444/#260 precedent): the shoot pure covers all five #147 items
  (shootEffect / smokeEffect / transferEffect.at / Effect.shake /
  shootSound). The N2468 ledger snapshot still contains #147 (245
  entries) — snapshots are slice-time, like N2444/#260.
- Fx tokens verified (shootBig2 Fx.java:1866, shootPayloadDriver
  :2189, payloadReceive :2677); Sounds verified via assets
  massdriver.ogg + massdriverReceive.ogg (Sounds is
  build-generated, no Sounds.java); Angles.trnsx/trnsy =
  len·cosDeg/sinDeg (Angles.java:66-72) via
  `source_angles_trns_vec` (N2246 already used it); N2245/N2246 do
  NOT call effects (state stamps only); all 30 EXACT_EXPRS match
  upstream verbatim. Driver docstring updated 3 "defer" spots →
  "live since N2468" (avoiding a stale-docstring fix at integration
  like N2444 needed).

## Commits

- Slice: `83a41ab4f` (5 files, +974/−0).
- Integration cherry-pick: `66192abeb` (clean).

## Tests

Targeted (new module
`tests.test_c07_payload_mass_driver_effects_rows`): 3/4 PASS
(registration, exact-evidence 30/30 exprs verbatim, row-state) +
proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). RED before GREEN
confirmed (failures=2, errors=2). Neighbours (8 PMD modules): Ran 33
(25 PASS + 8 proof Godot-absent), 0 errors.
Full gate (wave advances-31 integration, PID 8788, from 23:14): Ran 6846 tests in 1750.614s, FAILED (failures=386, skipped=5), 0 errors — 386/386 Godot-absent (379 inherited + 7 new proof tests N2462–N2468; Ran 6846 = 6818 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+10/+1/+2/+4** → 12351/1879/1828/3448 (exactly
as estimated — the largest slice of the wave). Receive 4 + shoot 6
symbols. Only payload shards changed, purely additive (+974/−0).
DEFERRED **#144 RESOLVED** (246→245, by entry TEXT; no new entry)
+ **#147 RETIRED AT MERGE** (fully covered by the shoot pure).

## Godot debt

- NEW proof `C07PayloadMassDriverEffectsRowsProof` (6 keys:
  `receive_fires`, `receive_gate`, `receive_pitch`, `shoot_fires`,
  `shoot_transfer`, `shoot_gate`) — written but NEVER run; debt in
  GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
