# Handoff N2354 — Accelerator launch-drain per-battery scaling

## What this slice did

Wired the Accelerator launch drain through the existing per-battery scaling
(`use_batteries_state`) via a one-shot request helper. 7 files, +562/−4,
commit `65f88ab47` on `slice/N2354-accelerator-per-battery-drain`.

## Key facts for the next agent

- **Scope correction:** the pure scaling the brief proposed was ALREADY live
  (`use_batteries_state`, SourcePowerGraphBatteryDistributionState.gd:107-143,
  Java-exact, SSOT-registered) — the slice became wiring-only.
- One-shot helper `source_accelerator_take_launch_drain_request_for_cell_state`
  takes the `launch_drain_request` and applies the drain at runtime through
  the existing `use_batteries_state`.
- The 1-tick delay launch→drain is documented (the graph updates before the
  driver tick).
- SSOT +3/+1/+1/+2 (3 result keys of the helper). DEFERRED 326→325 (−1+0,
  #326).
- Follow-through (backlog): the N2134 enabled stamp is not wired into the
  factory runtime path — a disabled battery still counts as enabled in the
  live-loop distribution + drain; needs its own slice.

## Godot debt (this slice)

- NEW proof `C07AcceleratorLaunchDrainProof` (7 keys) — never run.
