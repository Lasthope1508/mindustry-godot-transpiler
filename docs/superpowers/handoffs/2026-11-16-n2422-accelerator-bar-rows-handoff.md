# Handoff N2422 — Accelerator bar rows

## What this slice did

One pure-only bar pure
`source_accelerator_power_buffer_bar_state(battery_stored,
power_buffer_requirement)` (no tick wiring): bar_present gate
(requirement > 0f) + `bar.powerbuffer` label with raw long amounts
+ Pal.powerBar + RAW fraction. 5 files, commit `7a40d42e1` on
`slice/N2422-accelerator-bar-rows`.

## Key facts for the next agent

- **Bar DOES clamp** (Bar.java constructor + draw, [0,1]) — the pure
  returns the raw fraction + a note.
- **UI.formatAmount is complex** (suffixes + markup) — the pure
  returns raw longs; formatting is a UI concern, not invented.
- **Absent-default:** requirement ≤ 0f → fraction 0.0 (documented
  port choice; Java never evaluates the lambda).
- SSOT +2/+1/+1/+2. DEFERRED #95 resolved (286→285).

## Godot debt (this slice)

- NEW proof `C07AcceleratorPowerBufferBarRowsProof` (6 keys) —
  never run.
