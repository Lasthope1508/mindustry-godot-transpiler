# Handoff N2461 — MassDriver link/config rows

## What this slice did

Three pure-only pures (no tick wiring): link_valid (delegates to
the existing private `_mass_driver_link_valid` helper) + config
(point2/integer/clear/none; tile is a Variant Dict-or-null) +
configure_tapped (exactly :266-282). The link is a PACKED INT. 5
files, +1023/−1, commit `7fa4cf5f5` on
`slice/N2461-mass-driver-link-config-rows`.

## Key facts for the next agent

- **Tap vs within use DIFFERENT metrics:** tap is dst <= range
  INCLUSIVE, linkValid is strict within — boundary dst == range
  LINKS on tap but FAILS within (pinned in proof).
- **Config pure takes `tile: Variant`** (Dict or null), not
  tile_x/tile_y ints — null tile is unrepresentable as ints.
  **`range` renamed `range_value`** (builtin shadowing).
- **shooterValid: no new entry** — already ported as a private
  helper, live in the N2237 tick.
- SSOT +6/+1/+3/+6 (exact est). DEFERRED #34 resolved (253→252).

## Godot debt (this slice)

- NEW proof `C07MassDriverLinkConfigRowsProof` (6 keys) — never
  run.
