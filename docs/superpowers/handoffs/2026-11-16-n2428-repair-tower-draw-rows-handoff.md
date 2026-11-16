# Handoff N2428 — RepairTower draw rows

## What this slice did

Two pure-only pures (N2419 precedent, no tick wiring):
`source_repair_tower_draw_state` (super always present + circle /
square / glow gated on warmup > 0.001 + select/place) and
`source_repair_tower_stats_state` (range_blocks / repair_per_second
/ range_value / warmup_value). 5 files, +1132/−1, commit
`00616ae12` on `slice/N2428-repair-tower-draw-rows`.

## Key facts for the next agent

- **Stats pure adds 4 symbols** (2 stat rows + 2 accessors) — the
  brief counted only the draw pure's 6.
- **Def overrides only range 100f + healAmount 1.5f**; all draw
  constants are class defaults. Offset 4.0 (size-2 def).
- **Absin doubled scale** (glowScl×2). drawPlace needs tile_x/
  tile_y inputs (place center (84,164) for tile (10,20)).
- SSOT +10/+1/+2/+4 (est +6). DEFERRED #52 resolved (280→279).

## Godot debt (this slice)

- NEW proof `C07RepairTowerDrawRowsProof` (6 keys) — never run.
