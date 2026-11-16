# Handoff N2399 — RegenProjector heal application

## What this slice did

New pure `source_regen_projector_heal_application_state` →
`{applications, applied_count, skipped_count, recently_healed:
false}`; the tick wires it AFTER the flush write-back. Heal is
capped at max health. 5 files, +1042/−10, commit `4eacbb73d` on
`slice/N2399-regen-projector-heal-application`.

## Key facts for the next agent

- **Health is NOT in frames:** it lives on sprite metas
  `source_block_health` / `source_block_max_health` — the helper
  edits meta directly through the shared `repair_sprite`. No
  no_frame outcome; the analogue is no_sprite (`World.build`
  null).
- `recentlyHealed()` DEFERS (the tick has no time input —
  PortGame does not expose elapsed/Time.time).
- **Deviation:** frame targets keep their pre-heal health
  snapshot until the next scan `tile_changes` (documented in
  DEFERRED).
- SSOT +4/+1/+1/+2. DEFERRED #274 resolved, #273 rewritten in
  place, + 2 new entries (recentlyHealed timestamp + targets
  health snapshot refresh).

## Godot debt (this slice)

- NEW proof `C07RegenProjectorHealApplicationProof` (6 keys) —
  never run.
