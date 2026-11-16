# Handoff N2485 — Accelerator progress / isCoreBuilt rows

## What this slice did

One pure-only accessor: `source_accelerator_progress_is_core_built_state`
returns {progress, is_core_built} — progress as-is, is_core_built
progress >= 1f (exact boundary). No tick wiring. 5 files, +725/−3,
commit `fd58bb692` on
`slice/N2485-accelerator-progress-is-core-built-rows`.

## Key facts for the next agent

- **The clamp lives in updateTile (:144), NOT in progress()**
  — the pure does NOT clamp; the proof pins 1.5 pass-through.
- **Write/read :310/:318 is RIGHT**; the driver comment
  :305/:311 was WRONG — fixed here, plus the launchDuration
  cite :324-325.
- **Accelerator.java is in campaign/, NOT defense/.**
- Frame progress key is `progress`, advanced + clamped by the
  N2191 advance (:143-144).
- SSOT +2/+1/+1/+2 (exact est). DEFERRED #64 resolved
  (231→230). Serialization defers, no new entry.

## Godot debt (this slice)

- NEW proof `C07AcceleratorProgressIsCoreBuiltRowsProof` (6 keys)
  — never run. Live input pins the N2191 advance (0.5 + 30/120
  → 0.75; clamp 0.999 + 60/120 → 1.0).
