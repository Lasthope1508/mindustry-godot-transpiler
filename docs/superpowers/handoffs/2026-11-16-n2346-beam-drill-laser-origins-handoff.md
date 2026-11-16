# Handoff N2346 — BeamDrill updateLasers origins

## What this slice did

Ported BeamDrill updateLasers: the nearbySide laser origins, stamped onto
the frame when the tile changes. 5 files, +1156/−6, commit `f26b7bd9` on
`slice/N2346-beam-drill-laser-origins`.

## Key facts for the next agent

- Pure `source_beam_drill_laser_origins_state(tile_x, tile_y, rotation,
  size)` → `{lasers: [{x, y}...]}`, one origin per laser in laser order.
  nearbySide geometry is driver-local inside the pure (no other caller in
  the port); corner = tile − (size−1)/2 with Java integer division;
  unmatched rotation keeps the fresh `new Point2()` default (0,0) — the
  Java no-default-switch behavior.
- Tick stamps `frame["lasers"]` + `frame["lasers_last_change"]` only when
  `tile_changes` moves (N2277 pattern, sentinel −2, first tick refreshes)
  + the BeamDrill.java:240 empty-lasers refresh; BEFORE the consumption
  fold + facing scan (Java order :364 before :365), NOT gated on enabled.
- Initial frame gains `"lasers": []` + `"lasers_last_change": -2`.
- **nearbySide is Block.java:936–944** (not :936–947 — :946–948 is
  `getEdges`); the drop-loop cross-reference is entry 187, not 190.
- **BeamDrill.java:240 lazy call found** — `if(lasers[0] == null)
  updateLasers();` in updateTile; updateLasers is not *only*
  onProximityUpdate.
- SSOT +1/+1/+1/+2 (1 symbol; 35 exact exprs). DEFERRED rewrite #329 in
  place, net 0.
- N2339 untouched (byte-identical, pinned). NO re-runs.
- **Next:** the live facing-tile fill slice can read `frame["lasers"]` as
  its ray origins (wiring point in the tick comment).

## Godot debt (this slice)

- NEW proof `C07BeamDrillLaserOriginsProof` (6 keys) — never run.
