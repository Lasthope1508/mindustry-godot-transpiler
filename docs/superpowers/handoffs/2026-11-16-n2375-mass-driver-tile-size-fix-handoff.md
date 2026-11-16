# Handoff N2375 — MassDriver live link tile-size fix

## What this slice did

The MassDriver live link now uses the Java tilesize constant 8.0
instead of the game tile_size 32 (the N2364 PMD precedent). Fix slice,
3 files, +108/−9, commit `9cbc1a0ba` on the integration branch
(coordinator-serial — conflicts with N2369 on the same driver).

## Key facts for the next agent

- Range 440f (Blocks.java:2172); boundary 30 cells Java 240 < 440 in
  / old port 960 > 440 out; 54 cells last in-range, 55 out (strict).
- **No re-seed, no re-run:** the AcceptItem pair is 2 cells apart
  (in-range under both maths); all other live-tick proofs tick
  unlinked. Pinned in the new test.
- The N2364 boundary pin in the PMD test module now asserts the
  MassDriver driver hard-codes 8.0 too.
- SSOT +0, DEFERRED 0 (no register).

## Godot debt (this slice)

- No new proof, no re-run.
