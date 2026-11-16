# Handoff N2368 — PayloadDeconstructor dump neighbour write-back

## What this slice did

The Deconstructor dump advance exposes `dump_deliveries` (array); the
tick wires the shared N2353 helper per delivery, amount 1, catalog
size. 5 files, +932/−5, commit `21397f7e7` on
`slice/N2368-deconstructor-dump-write-back`.

## Key facts for the next agent

- **Multi-dump needs an array key:** dumpRate 4 runs dumpAccumulate
  4×/tick, so a singular index+item pair would drop every delivery but
  one. `dump_deliveries` = Array of {neighbour_index, item} in attempt
  order (the N2362 shape).
- Size-5 ring 0 offset (−3,−1) pinned; deconstructor 5 / small 3.
- SSOT +1/+1/+0/+0. DEFERRED 319→318 (#238 resolved; register built
  on the stale N2363 base 319 — merge by entry TEXT).
- The schema/contract fold landed in N2376.

## Godot debt (this slice)

- NEW proof `C07PayloadDeconstructorDumpWriteBackProof` (3 keys) —
  never run.
