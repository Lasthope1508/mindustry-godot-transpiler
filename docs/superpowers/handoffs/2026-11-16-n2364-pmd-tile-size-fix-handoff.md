# Handoff N2364 — PayloadMassDriver live link tile-size fix

## What this slice did

Replaced `game.get("tile_size")` (32, rendering px/tile) with the Java
constant 8.0 for PMD live-link logic distances — ranges were 4x too
short in tiles. 2 files, +106/−3, commit `a29f44f3c` on
`slice/N2364-pmd-tile-size-fix`.

## Key facts for the next agent

- **Game tile_size (32) vs Java tilesize (8):** drivers that read
  game.tile_size for LOGIC world coords get 4x-wrong distances.
  Boundary: 30 cells Java 240 < 700 in-range vs old port 960 > 700
  out; small 87 in / 88 out; large 262 in / 263 out.
- Fix slice: no new module/register; test added to the existing PMD
  module. SSOT +0.
- The fix broke the N2357 proof's small pair (40 cells now links) —
  re-seeded by N2365.
- MassDriver has the identical pattern (:504-505) — separate slice,
  pinned in the new test.

## Godot debt (this slice)

- No new proof. N2357 proof needs a re-run (see N2365).
