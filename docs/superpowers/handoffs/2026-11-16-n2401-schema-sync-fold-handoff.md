# Handoff N2401 — Schema-sync fold (N2398 offload keys)

## What this slice did

Serial (coordinator): folded the N2398 `offload_neighbour_index`
+ `cdump` keys into the owning N2223 result schema + contract
return_keys (7→9 keys), N2367/N2376/N2384/N2393 pattern. 4 files,
+50/−4, commit `10e74700b`.

## Key facts for the next agent

- **Split schema/contract from the symbol loop:** the owning
  register uses merged keys for the schema upsert + contract
  return_keys ONLY; the symbol loop iterates the ORIGINAL
  outputs — `upsert_source_symbols` wholesale-replaces, so
  folding into the symbol loop would steal the N2398 slice's
  ownership (verified intact).
- No test pins return_keys or schema keys — no pin update needed
  (the N2393 precedent, unlike N2377 in N2384).
- SSOT +0. **Write-back + offload keys are now FULLY
  schema-synced (N2367 + N2376 + N2384 + N2393 + N2401) — no fold
  backlog left.**

## Godot debt (this slice)

- None.
