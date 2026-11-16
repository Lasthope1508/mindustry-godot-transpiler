# Report N2393 — Schema-sync fold (N2386 dump_deliveries)

**Slice:** N2393 — SERIAL (coordinator): fold the 1 advance result
key exposed by the N2386 item write-back slice into its owning
result schema + contract return_keys. **Wave:** advances-21
(serial follow-through). **Commit:** `e52c13f93` on
`integration/wave-advances-21-n2386-n2392`. **Files:** 4, +32/−7.

## Source

Java: BuildingComp.java:1056-1058 (the dumpAccumulate
`while(dumpAccum >= 1f)` loop — the `dump_deliveries` expr `res |=
dump(item);`). Metadata copied verbatim from the N2386 register
(`source=BUILDING_COMP` explicit — this register's `f()` defaults
to PAYLOAD_UNLOADER).

## Implementation

The owning register (N2293 Unloader dump) splits schema/contract
(merged keys) from the symbol loop (ORIGINAL outputs only),
following the N2367/N2376/N2384 pattern —
`upsert_source_symbols` wholesale-replaces, so folding the key
into the symbol loop would steal the N2386 slice's symbol
ownership. Verified after the re-run: `dump_deliveries` still
carries the N2386 tests/proof.

- N2386 Unloader dump: `dump_deliveries` → N2293 schema/contract
  (8 → 9 keys).

**No pin update needed:** the N2386 registration test pins only
the ledger `source_symbols` list, not return_keys or schema keys
(unlike N2377 in N2384, which pinned the PRE-fold 3 keys).

## Commits

- Serial: `e52c13f93` (4 files, +32/−7) — 1 owning register + 3
  generated files (contracts + schema).

## Tests

Targeted: 3 modules (N2293 owning + N2380 liquid + N2386 item)
Ran 12 (9 PASS + 3 Godot-absent proofs), 0 other errors.
Full gate (wave advances-21 integration, PID 20509, from 14:01):
Ran 6575 tests in 1517.133s, FAILED (failures=319, skipped=5), 0 errors — 319/319 Godot-absent `AssertionError: unexpectedly None` (312 inherited + 7 new proof tests N2386–N2392; N2393 adds no test).

## SSOT / DEFERRED

SSOT **+0** (12068/1819/1749/3290 unchanged — the symbol was
already registered by N2386). DEFERRED 0. With N2367 + N2376 +
N2384 + N2393, the write-back + offload advance keys are now FULLY
schema-synced — no remaining fold backlog.

## Godot debt

- No new proof. No re-run needed.
