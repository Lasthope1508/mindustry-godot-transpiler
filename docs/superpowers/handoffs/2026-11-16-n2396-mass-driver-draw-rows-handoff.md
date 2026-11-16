# Handoff N2396 — MassDriver draw rows

## What this slice did

3 pures (draw / drawConfigure / drawPlace); icons MERGED into
the draw pure as the result key `icon_regions` — a pure `icons()`
0-arg FAILS the register (validator requires input keys
non-empty). The draw half of old DEFERRED #47 (sense went live
in N2392). 5 files, +1258/−1, commit `5df8d003a` on
`slice/N2396-mass-driver-draw-rows`.

## Key facts for the next agent

- **Icons precedent:** 0-arg `icons()` cannot register — merge
  icons into the draw pure as a result key. Applies to later
  icons() slices.
- Shadow offset uses Java INTEGER division (size 3 → 1);
  drawPlace dash circle at x*tilesize WITHOUT offset; absin at
  the doubled scale (12f).
- SSOT +9/+1/+3/+6 (each draw call registered separately).
  DEFERRED #301 resolved (301→300).

## Godot debt (this slice)

- NEW proof `C07MassDriverDrawRowsProof` (6 keys) — never run.
