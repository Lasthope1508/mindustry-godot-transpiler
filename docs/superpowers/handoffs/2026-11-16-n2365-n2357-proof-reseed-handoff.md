# Handoff N2365 — N2357 proof re-seed (100 cells)

## What this slice did

Re-seeded the N2357 proof's small pair from 40 to 100 cells apart
(100 × 8 = 800 > 700 stays idle) after the N2364 tile-size fix made
the 40-cell pair link. Coordinator-serial, 5 files, +57/−39, commit
`678a3df5a` on the integration branch.

## Key facts for the next agent

- Small_b (68,26) → (128,26); large pair unchanged (40 cells, 320 <
  2100 still links). The driver computes distance purely from cell
  coords × 8, no world lookup.
- Updated the N2364 test pin (incl. its tail section, which asserted
  the OLD fixture) + the N2357 test comment + the N2245 register
  tilesize description (:493).
- SSOT +0. Targeted Ran 9 (7 PASS + 2 proof).

## Godot debt (this slice)

- No new proof. **N2357 proof needs a re-run** (fixture changed).
