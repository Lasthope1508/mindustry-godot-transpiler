# Handoff N2384 — Schema-sync fold (advances-20 write-back keys)

## What this slice did

Serial (coordinator): folded the 8 write-back advance keys into
their owning result schemas + contract return_keys (N2286/N2285/
N2287 3→5 keys, N2293 6→8 keys), N2367/N2376 pattern. 9 files,
+196/−21, commit `b1cfc01c7`.

## Key facts for the next agent

- **Split schema/contract from the symbol loop:** the owning
  registers use merged keys for the schema upsert + contract
  return_keys ONLY; the symbol loop iterates the ORIGINAL
  outputs — `upsert_source_symbols` wholesale-replaces, so
  folding into the symbol loop would steal the write-back
  slices' ownership (verified intact).
- The N2377 registration test pinned the PRE-fold 3 keys —
  updated to 5 (the N2366 pin-update precedent).
- SSOT +0. **Write-back + offload keys are now FULLY
  schema-synced (N2367 + N2376 + N2384) — no fold backlog left.**

## Godot debt (this slice)

- None.
