# Handoff N2436 — BeamDrill draw rows

## What this slice did

One pure-only draw pure `source_beam_drill_draw_state` (21
caller-supplied inputs, no tick wiring): base/top + per-facing
laser loop (centered vs laser branches, boost gates) + Lod.l2
sparks (caller-supplied rolls, 3/spark in Java order) + glow +
select + icons. 5 files, +1520, commit `a0833ef8a` on
`slice/N2436-beam-drill-draw-rows`.

## Key facts for the next agent

- **large-plasma-bore overrides laserWidth 0.7f** (class default
  0.65f) → laser_width is a caller-supplied input.
- **Facing entries carry tile_x/tile_y too** (the centered check
  reads Tile coords, not world coords).
- **Asymmetries preserved:** width absin (id%9)*9 vs mixcol id*9;
  center boost gate > 0.01 vs laser boost gate > 0.001.
- **Slope = 1 − |fin−0.5|*2** (arc Mathf.java:594-596), inline.
- SSOT +8/+1/+1/+2 (exact est). DEFERRED #143 resolved (273→272).
  BeamDrill neighbours Ran 40, no pin breaks.

## Godot debt (this slice)

- NEW proof `C07BeamDrillDrawRowsProof` (6 keys) — never run.
