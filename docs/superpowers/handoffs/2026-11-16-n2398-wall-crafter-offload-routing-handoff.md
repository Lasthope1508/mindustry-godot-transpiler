# Handoff N2398 — WallCrafter offload routing

## What this slice did

The N2223 advance routes offloaded items through the shared
`dump_item_state` (the N2283 pattern) and gains
`offload_neighbour_index` (−1 = stays home) + `cdump`
(post-offload cursor). The tick persists both keys AFTER the
advance write-back, `cdump` BEFORE timerDump (Java order offload
:214 before dump :220-221). Routed items land via the N2353
helper (amount 1). 5 files, +1033/−10, commit `de01819d3` on
`slice/N2398-wall-crafter-offload-neighbour-routing`.

## Key facts for the next agent

- **NOT an array:** offload stops after the first success, so a
  scalar index + cursor is Java-exact (unlike N2386).
- **No double-advance:** the N2223 advance never touched the
  cursor; `dump_item_state` advances it 1×/neighbour checked.
- `produced(item, 1)` DEFERS (0 grep `produced` in the driver,
  no sector/team/net input).
- SSOT +2/+1/+0/+0. DEFERRED #256 rewritten in place.
- The 7-key advance return pin was updated to 9 keys at
  integration (`293de3675`, the N2343 precedent); schema +
  contract fold landed in N2401.

## Godot debt (this slice)

- NEW proof `C07WallCrafterOffloadRoutingProof` (4 keys) — never
  run.
