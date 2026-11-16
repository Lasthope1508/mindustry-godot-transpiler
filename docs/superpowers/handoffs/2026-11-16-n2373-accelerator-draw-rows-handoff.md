# Handoff N2373 — Accelerator draw rows

## What this slice did

Accelerator draw / drawLight / drawSelect pures. 5 files, +1189/−1,
commit `4bd69a218` on `slice/N2373-accelerator-draw-rows`.

## Key facts for the next agent

- Core-nucleus size 5 (shadow r80, not 4). chargeRings belong to
  drawLaunchGlobalZ, NOT draw(). drawSelect is :249-256.
- Launching branch :180-194 still defers (launchTime untracked);
  getCursor waits on the canLaunch environment-half slice.
- SSOT +5/+1/+3/+6 (above estimate — drawLight separates cleanly).
  DEFERRED 316→316 (net 0; #106 + #107 rewritten in place).
- Proof values verified numerically in Python.

## Godot debt (this slice)

- NEW proof `C07AcceleratorDrawRowsProof` (6 keys) — never run.
- Follow-through: launchTime/cloudSeed slice (#175); canLaunch
  environment-half slice; launch-sequence slice (drawLaunch /
  drawLaunchGlobalZ / drawLanding).
