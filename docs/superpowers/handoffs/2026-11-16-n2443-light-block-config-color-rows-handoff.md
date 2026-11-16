# Handoff N2443 — LightBlock config/color rows

## What this slice did

Two pure-only pures (N2387/N2437 precedent, no tick wiring):
`source_light_block_sense_color_state` (color → double-bits
denormal value, else super_value) +
`source_light_block_config_color_state` (configure/control action
→ color, minimap_updated, tapped_result, picker_call,
config_value). 7 result symbols. 5 files, +1045/−3, commit
`5dac58bf3` on `slice/N2443-light-block-config-color-rows`.

## Key facts for the next agent

- **Sense value = float(rgba8888) × 2^-1074** (double denormal,
  raw bits = color int) — verified exact over 200k random values
  + endpoints; float32 round-trip exact for every channel.
  GDScript zero-extends via `color & 0xffffffff`.
- **minimap_updated has NO color-changed condition** (Java wins
  over the brief): configured/control update the minimap whenever
  !headless — same-color configure still updates (pinned).
- **Control takes p1_bits** (caller-supplied raw low-32-bits) —
  GDScript has no double bitcast; the logic executor owns it.
- SSOT +7/+1/+2/+4 (exact est). DEFERRED #91 resolved (266→265).

## Godot debt (this slice)

- NEW proof `C07LightBlockConfigColorRowsProof` (6 keys) — never
  run.
