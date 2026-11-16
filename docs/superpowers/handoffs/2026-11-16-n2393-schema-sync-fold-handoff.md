# Handoff N2393 — Schema-sync fold (N2386 dump_deliveries)

## What this slice did

Serial (coordinator): folded the N2386 `dump_deliveries` key into
the owning N2293 result schema + contract return_keys (8→9 keys),
N2367/N2376/N2384 pattern. 4 files, +32/−7, commit `e52c13f93`.

## Key facts for the next agent

- **Split schema/contract from the symbol loop:** the owning
  register uses merged keys for the schema upsert + contract
  return_keys ONLY; the symbol loop iterates the ORIGINAL
  outputs — `upsert_source_symbols` wholesale-replaces, so
  folding into the symbol loop would steal the N2386 slice's
  ownership (verified intact).
- The N2386 registration test pins only the ledger
  `source_symbols` list — no pin update needed (unlike N2377 in
  N2384).
- SSOT +0. **Write-back + offload keys are now FULLY
  schema-synced (N2367 + N2376 + N2384 + N2393) — no fold backlog
  left.**

## Godot debt (this slice)

- None.
