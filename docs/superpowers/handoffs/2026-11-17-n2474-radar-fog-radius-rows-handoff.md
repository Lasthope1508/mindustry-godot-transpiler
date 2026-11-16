# Handoff N2474 — Radar fogRadius rows

## What this slice did

One pure-only pure (no tick wiring): `source_radar_fog_radius_
state` computes fogRadius() = field * progress * smoothEfficiency
in Java-exact order. 5 files, +735/−1, commit `65e83b4d0` on
`slice/N2474-radar-fog-radius-rows`.

## Key facts for the next agent

- **Field values:** class default 10 (constructor :33), field
  default −1 (Block.java:348), def `radar` 34 (Blocks.java:1991).
  The pure takes the field as an input.
- **No tick wiring yet** — the caller wires this pure's output into
  the N2190 advance (replacing the inline fog_radius_now) and the
  N2427 draw pure.
- **Formula order is pinned with `==` exact** — 0.1×3×3 L-to-R =
  0.9000000000000001; do not reorder.
- SSOT +1/+1/+1/+2 (exact est). DEFERRED #124 resolved (238→237).

## Godot debt (this slice)

- NEW proof `C07RadarFogRadiusRowsProof` (6 keys) — never run.
