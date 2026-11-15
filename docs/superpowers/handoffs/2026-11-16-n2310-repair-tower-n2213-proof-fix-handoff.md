# Handoff N2310 — RepairTower N2213 proof fix

## What this slice did

Fixed the stale N2213 proof (`C07RepairTowerShouldConsumeProof`): seeded ozone
0.1 before EACH tick (re-seed + re-fetch meta before the gate-true tick). 1
file, +23/−4, commit `5fa4b0f3` on
`slice/N2310-repair-tower-n2213-proof-fix`.

## Key facts for the next agent

- N2250's REQUIRED ozone row folds live-tick efficiency to 0 when the proof
  seeds no ozone — the `efficiency_folds_power_when_gate_true` key asserted 0.5.
- This proof needs a re-seed before the second tick (unlike N2309, whose
  second tick asserts 0.0 anyway).
- Verified: `source_set_state` mutates in place (SourceLiquidModuleState.gd:29)
  — the re-seed lands on the same store the tick reads.
- Fix slice: no code, no SSOT, no DEFERRED change. Only the proof .gd changed.
- Expected values unchanged.

## Godot debt (this slice)

- RE-RUN of proof N2213 (`C07RepairTowerShouldConsumeProof`).
