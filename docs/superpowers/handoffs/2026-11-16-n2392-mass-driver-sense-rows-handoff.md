# Handoff N2392 — MassDriver sense rows

## What this slice did

New pure `source_mass_driver_sense_state` — progress =
`clampf(1.0 - reload_counter, 0, 1)`; other sensors delegate via
caller-supplied `super_value`. Pure-only. 5 files, +873/−1, commit
`d7ad85d79` on `slice/N2392-mass-driver-sense-rows`.

## Key facts for the next agent

- **reloadCounter counts DOWN** (fire() resets to 1f, decay drains
  it): fresh 1.0 → progress 0, ready 0.0 → progress 1. NOT
  reloadCounter/reload.
- SSOT +2/+1/+1/+2. DEFERRED #47 REWRITTEN IN PLACE (draw /
  drawConfigure / drawPlace / icons remain) — count stays 306.
- Draw half stays deferred (MassDriver.java:230-242, 244-264,
  80-102, 75-77); `senseObject` / `sense(Content)` overloads not
  modeled.

## Godot debt (this slice)

- NEW proof `C07MassDriverSenseRowsProof` (6 keys) — never run.
