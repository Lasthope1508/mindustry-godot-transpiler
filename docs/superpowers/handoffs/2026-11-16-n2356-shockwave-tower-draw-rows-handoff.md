# Handoff N2356 — ShockwaveTower draw rows

## What this slice did

Added the ShockwaveTower draw rows (heatRegion additive + shape poly heat²
lerp; drawSelect/drawPlace waveColor dash circle). 5 files, +958/−1, commit
`d87abf186` on `slice/N2356-shockwave-draw-rows`.

## Key facts for the next agent

- Two pure draws following the SourceBlockDrawState pattern:
  `source_shockwave_tower_draw_state` (heatRegion additive + shape polygon
  with heat² color lerp) and `source_shockwave_tower_draw_select_state`
  (drawSelect/drawPlace waveColor dash circle).
- Verified drawPlace uses waveColor, not Pal.placing.
- SSOT +3/+1/+2/+4 (2 pures = 2 contracts + 4 schemas, 3 result fields).
  DEFERRED 326→324 (−2+0, #69 + #204).

## Godot debt (this slice)

- NEW proof `C07ShockwaveTowerDrawRowsProof` (6 keys) — never run.
