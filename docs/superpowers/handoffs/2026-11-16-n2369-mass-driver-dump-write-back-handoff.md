# Handoff N2369 — MassDriver dump neighbour write-back

## What this slice did

The MassDriver dump advance exposes `dump_deliveries` (array); the
tick wires the shared N2353 helper after the dump write-back. 5 files,
+934/−7, commit `f946ba25a` on
`slice/N2369-mass-driver-dump-write-back`.

## Key facts for the next agent

- **Multi-dump needs an array key:** the dumpAccumulate while loop
  fires multiple times per frame — scalar would drop deliveries
  (the N2362 shape).
- Size-3 ring[0] offset (−2,−1) pinned; live neighbour is a size-1
  phase-conveyor (size-3 would overlap the 3×3 footprint).
- Tile-size :504-505 NOT touched — fixed separately as N2375.
- SSOT +1/+1/+0/+0. DEFERRED 319→318 (#279 resolved; register built
  on the stale N2363 base 319 — merge by entry TEXT).
- The schema/contract fold landed in N2376.

## Godot debt (this slice)

- NEW proof `C07MassDriverDumpWriteBackProof` (3 keys) — never run.
