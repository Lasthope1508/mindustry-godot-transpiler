# Handoff N2376 — Schema-sync fold of write-back advance keys

## What this slice did

Folded the 4 advances-19 write-back advance keys into their owning
result schemas + contract return_keys (N2367 pattern). 7 files,
+112/−11, commit `06a79067c` on the integration branch
(coordinator-serial).

## Key facts for the next agent

- N2368 `dump_deliveries` → N2276 (4→5 keys); N2369
  `dump_deliveries` → N2294 (4→5); N2371 `dump_neighbour_index` +
  `dumped_liquid` → N2284 (3→5). The routing `handled_index` was
  already folded by N2371 itself.
- **Split schema/contract from the symbol loop:** merged keys for
  schema/contract, ORIGINAL outputs only for symbols — otherwise the
  wholesale-replace upsert steals the write-back slices' ownership.
  Verified: all 4 symbols still carry their write-back tests/proofs.
- SSOT +0 (12038/1806/1738/3268 unchanged). No test pins return_keys
  or schema keys for these advances — only ledger lists (unchanged).
- Write-back + offload keys are now fully schema-synced (N2367 +
  N2376) — no remaining fold backlog for advances-17/18/19.

## Godot debt (this slice)

- No new proof, no re-run.
