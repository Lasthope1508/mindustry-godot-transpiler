# Handoff N2444 — LaunchPad launch FX rows

## What this slice did

One pure-only FX pure `source_launch_pad_launch_effect_state`
(no tick wiring): sound_call (padLaunch, pitch 1f + roll) +
fx_call (launchPod) + shake_call (3f, 3f), all null unless
launched. `launched` + `pitch_roll` are caller-supplied (no RNG
in the pure). 5 files, +823/−1, commit `c6b57ab17` on
`slice/N2444-launch-pad-launch-effect-rows`.

## Key facts for the next agent

- **Effect.shake args = intensity/duration** (Effect.java:
  210-212), both 3f. **Mathf.range(r) = random(−r, r)**.
- **Sounds is build-generated** (no Sounds.java in upstream) —
  padLaunch verified via the .ogg asset + LaunchPad.java:34.
- **#260 retired at merge** (its own text said only these three
  rows remained). LaunchPad docstring stale items fixed at
  integration (4dc97d683).
- SSOT +3/+1/+1/+2 (exact est). DEFERRED #131 resolved (266→265).

## Godot debt (this slice)

- NEW proof `C07LaunchPadLaunchEffectProof` (6 keys) — never run.
