# Handoff N2367 — Schema-sync fold of write-back + offload advance keys

## What this slice did

Folded all 9 write-back/offload advance keys into their owning result
schemas + contract return_keys, and registered the 5 keys that had no
symbol. Coordinator-serial, 20 files, +453/−63, commit `d155bbf5d` on
the integration branch.

## Key facts for the next agent

- Folded: N2360×2 → N2282, N2361×2 → N2281, N2362 `dump_deliveries`
  → N2288, N2363×2 → N2289, N2353 offload×2 → N2222. Schemas 5→7 /
  5→7 / 5→6 / 5→7 / 8→10; contracts match.
- New symbols (5): `dump_deliveries` (N2362), N2363×2, offload×2
  (N2353, owned by the Separator advance — N2353 tests allow mixed
  owners).
- **Fold mechanics:** the owning registers use merged keys for
  schema/contract but the symbol loop iterates the ORIGINAL outputs
  only — `upsert_source_symbols` wholesale-replaces, so folding keys
  into the symbol loop would steal the write-back slices' symbol
  ownership. Verified: N2360/N2361 symbols still carry their
  write-back tests.
- SSOT 12013→12018 (+5 symbols); ledger/contracts/schemas counts
  unchanged. Targeted 11 modules Ran 44 (33 PASS + 11 proof).

## Godot debt (this slice)

- No new proof, no re-run (registration-only slice).
