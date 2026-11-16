# Report N2401 — Schema-sync fold (N2398 offload keys)

**Slice:** N2401 — SERIAL (coordinator): fold the 2 advance
result keys exposed by the N2398 offload slice into their
owning result schema + contract return_keys. **Wave:**
advances-22 (serial follow-through). **Commit:** `10e74700b` on
`integration/wave-advances-22-n2394-n2400`. **Files:** 4,
+50/−4.

## Source

Java: WallCrafter.java:214 (offload) / :220-221 (dump) — the
`offload_neighbour_index` + `cdump` advance return. Metadata
copied verbatim from the N2398 register.

## Implementation

The owning register (N2223 WallCrafter advance) splits
schema/contract (merged keys) from the symbol loop (ORIGINAL
outputs only), following the N2367/N2376/N2384/N2393 pattern —
`upsert_source_symbols` wholesale-replaces, so folding the keys
into the symbol loop would steal the N2398 slice's symbol
ownership. Verified after the re-run: both symbols still carry
the N2398 tests/proof.

- N2398 WallCrafter offload: `offload_neighbour_index` + `cdump`
  → N2223 schema/contract (7 → 9 keys).

**No pin update needed:** no test pins return_keys or schema
keys (the N2393 precedent — unlike N2377 in N2384, which pinned
the PRE-fold 3 keys).

## Commits

- Serial: `10e74700b` (4 files, +50/−4) — 1 owning register + 3
  generated files (contracts + schema).

## Tests

Targeted: 3 modules (N2223 owning + N2283 timerDump + N2398
offload) Ran 12 (9 PASS + 3 Godot-absent proofs), 0 other
errors.
Full gate (wave advances-22 integration, PID 7151, from 14:50):
Ran 6602 tests in 1564.685s, FAILED (failures=326, skipped=5), 0 errors — 326/326 Godot-absent `AssertionError: unexpectedly None` (319 inherited + 7 new proof tests N2394–N2400; N2401 adds no test)..

## SSOT / DEFERRED

SSOT **+0** (12095/1825/1757/3306 unchanged — both symbols were
already registered by N2398). DEFERRED 0. With N2367 + N2376 +
N2384 + N2393 + N2401, the write-back + offload advance keys are
now FULLY schema-synced — no remaining fold backlog.

## Godot debt

- No new proof. No re-run needed.
