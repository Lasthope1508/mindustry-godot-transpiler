# Handoff N2479 — Radar canPickup / progress() rows

## What this slice did

One pure-only accessor (no tick wiring): `source_radar_can_
pickup_progress_state(progress)` → {can_pickup: false, progress:
progress} — the port's first source-backed canPickup /
progress(). 5 files, +713/−4, commit `02274b134` on
`slice/N2479-radar-can-pickup-progress-rows`.

## Key facts for the next agent

- **The clamp lives in updateTile (:69), NOT in progress()** —
  the pure does NOT clamp, returns its input as-is.
- canPickup unconditionally false (base returns block.canPickup,
  default true — the override makes a radar unpickupable).
- Base progress() returns 0f — the override exposes the
  discovery fraction. Frame key is `progress` (since N2190).
- Numbering: in the 234-base this entry is #33 (old "#34" was
  238-base); forceUpdate is #123, read/write rows #32.
- SSOT +2/+1/+1/+2 (symbols +1 over est — 2 result keys).
  DEFERRED #33 resolved (234→233).

## Godot debt (this slice)

- NEW proof `C07RadarCanPickupProgressProof` (6 keys) — never
  run.
