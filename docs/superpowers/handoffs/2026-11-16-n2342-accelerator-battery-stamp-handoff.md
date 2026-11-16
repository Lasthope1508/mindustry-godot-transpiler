# Handoff N2342 — Accelerator battery_stored graph stamp

## What this slice did

Stamped the live battery total onto accelerator frames at the graph
distribute step, so the N2271 canLaunch gate reads a live
`battery_stored`. 6 files, +779/−0, commit `06919307` on
`slice/N2342-accelerator-battery-stamp`.

## Key facts for the next agent

- Pure
  `SourcePlacedPowerGraphState.source_accelerator_set_battery_stored_for_cell_state(game,
  cell, battery_stored)` → `{stored, reason}` (live_frame / no_sprite /
  not_accelerator / no_frame). Stamps ONLY accelerator frames (meta key
  `source_accelerator_building`).
- Wiring DONE: the call is at SourceFactoryRuntimeState.gd:1129, next to
  the :1107 power_status stamp; the battery total is available at the
  distribute step (post-use/charge batteries in battery_distribute_state).
- No preload cycle (verified by script over the 55-file closure).
- Generated JSON left uncommitted (correct pattern — coordinator merges).
- DEFERRED net 0 (#236 rewritten in place — per-battery proportional
  scaling still waits). SSOT +2/+1/+1/+2 (pure returns 2 keys).

## Godot debt (this slice)

- NEW proof `C07AcceleratorBatteryStampProof` (6 keys) — never run.
