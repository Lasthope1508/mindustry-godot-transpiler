# Handoff N2302 — WallCrafter N2223 proof fix (FIX slice)

## What this slice did

Fixed the stale N2223 proof (`C07WallCrafterUpdateTileProof`): N2301 stamps
`frame["efficiency_factor"]` unconditionally each enabled tick from
`frame["wall_edge_tiles"]`, overwriting the proof's seeded 1.0 with 0.0 (empty
edge). The fix seeds `wall_edge_tiles` summing to 1.0 (2 solid tiles × 0.5 —
the live-tick crusher is cliff-crusher size 2, Blocks.java:3007). 1 file,
+14/−7, commit `eb9c292b` on `slice/N2302-wall-crafter-n2223-proof-fix`.

## Key facts for the next agent

- Pure-call keys (:56-67) were NOT stale — they call the advance directly with
  explicit inputs. Only live-tick/frame-seeded keys go stale when a later slice
  stamps a frame key unconditionally (N2300/N2301 lesson).
- Expected values unchanged (eff 1.0 / time 0.5).
- Test module untouched; targeted 3/4 PASS + proof Godot-absent.
- SSOT +0/+0/+0/+0; DEFERRED unchanged.

## Godot debt (this slice)

RE-RUN of proof N2223 (`C07WallCrafterUpdateTileProof`) — fixture changed.
