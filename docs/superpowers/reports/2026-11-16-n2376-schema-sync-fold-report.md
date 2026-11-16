# Report N2376 — Schema-sync fold of write-back advance keys

**Slice:** N2376 — Fold the 4 advance result keys exposed by the
advances-19 write-back slices into their owning result schemas +
contract return_keys (all 4 symbols were already registered by their
slices). **Wave:** advances-19 (coordinator-serial). **Commit:**
`06a79067c` on `integration/wave-advances-19-n2368-n2374` (no slice
branch — coordinator-serial after integration). **Files:** 7,
+112/−11.

## Source

Java: BuildingComp.java:1053-1061 (dumpAccumulate), :1057
(`res |= dump(item);`), :896 (proximity get for the liquid routing),
:918 (`next.handleLiquid(self(), liquid, flow)`); Fracker.java:42
(`dumpLiquid(result);`); MassDriver.java:163-166 (dump gate);
PayloadDeconstructor.java:111-115 (dumpRate 4).

## Implementation

Schema + contract fold for all 4 keys (the N2367 pattern — symbols
were already registered, so no new symbols):
- N2368 PayloadDeconstructor dump: `dump_deliveries` (Array) → N2276
  schema/contract (4 → 5 keys).
- N2369 MassDriver dump: `dump_deliveries` (Array) → N2294
  schema/contract (4 → 5 keys).
- N2371 Fracker dumpLiquid: `dump_neighbour_index`, `dumped_liquid`
  → N2284 schema/contract (3 → 5 keys). The routing `handled_index`
  was already folded by N2371 into the owning routing register
  (contract return_keys + result schema) — NOT touched here.

Design: the 3 owning registers split schema/contract (merged keys)
from the symbol loop (ORIGINAL outputs only) —
`upsert_source_symbols` does `symbols.update(entries)`, a wholesale
replace, so folding the keys into the symbol loop would have stolen
the write-back slices' symbol ownership. Verified after the re-runs:
all 4 symbols still carry their write-back slices' tests/proofs.

## Tests

Targeted 6 modules (3 owning + 3 write-back) Ran 24 (18 PASS + 6
proof Godot-absent), 0 other errors. No new proof test.
Full gate (wave advances-19 integration, PID 7308, 12:44–13:09): Ran 6522 tests in 1485.371s, FAILED (failures=306, skipped=5), 0 errors — 306/306 Godot-absent `AssertionError: unexpectedly None` (299 inherited + 7 new proof tests N2368–N2374; N2375 adds +1 pin test, N2376 adds no test).

## SSOT / DEFERRED

SSOT **12038/1806/1738/3268 unchanged (+0)** — the fold adds keys to
existing schemas/contracts, not new schemas/contracts/symbols. Audit
stays 1336. DEFERRED 0 (no DEFERRED change).

## Godot debt

- No new proof.
- No old proof needs a re-run.
- The write-back + offload advance keys are now fully schema-synced
  (N2367 + N2376) — no remaining fold backlog for the advances-17/18/19
  write-back slices.
