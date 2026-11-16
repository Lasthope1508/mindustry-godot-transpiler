# Handoff N2389 — LaunchPad sense rows

## What this slice did

New pure `source_launch_pad_sense_state` — progress =
`clampf(launch_counter / launch_time, 0, 1)`; other sensors delegate
via caller-supplied `super_value`. Pure-only. 5 files, +884/−1,
commit `6006da177` on `slice/N2389-launch-pad-sense-rows`.

## Key facts for the next agent

- **launchTime is a def input:** 1200f (launch-pad), 1800f
  (advanced-launch-pad), 1f (class default).
- **Progress CLAMPED** (Java-exact, LaunchPad.java:99).
- SSOT +2/+1/+1/+2. DEFERRED 306→305 (#50 resolved).
- Advanced-launch-pad def verification is a separate slice (#49).

## Godot debt (this slice)

- NEW proof `C07LaunchPadSenseRowsProof` (6 keys) — never run.
