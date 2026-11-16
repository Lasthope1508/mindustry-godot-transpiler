# Report N2384 — Schema-sync fold (advances-20 write-back keys)

**Slice:** N2384 — SERIAL (coordinator): fold the 8 advance result
keys exposed by the advances-20 write-back slices into their
owning result schemas + contract return_keys. **Wave:** advances-20
(serial follow-through). **Commit:** `b1cfc01c7` on
`integration/wave-advances-20-n2377-n2383`. **Files:** 9, +196/−21.

## Source

Java: BuildingComp.java:896 (`Building other =
proximity.get((i + dump) % proximity.size);` — the
dump_neighbour_index expr, shared by all 4 folds);
SolidPump.java:140 / Pump.java:179 / LiquidBridge.java:30 /
PayloadUnloader.java:105 (the dumped-liquid exprs). Metadata
copied verbatim from the slice registers (N2377/N2378/N2379/
N2380).

## Implementation

The 4 owning registers (N2286 SolidPump, N2285 Pump, N2287
LiquidBridge, N2293 Unloader) split schema/contract (merged keys)
from the symbol loop (ORIGINAL outputs only), following the
N2367/N2376 pattern — `upsert_source_symbols` wholesale-replaces,
so folding the keys into the symbol loop would steal the
write-back slices' symbol ownership. Verified after the re-run:
all 8 symbols still carry their write-back slices' tests/proofs.

- N2377 SolidPump dumpLiquid: `dump_neighbour_index`,
  `dumped_liquid` → N2286 schema/contract (3 → 5 keys).
- N2378 Pump dumpLiquid: `dump_neighbour_index`, `dumped_liquid`
  → N2285 schema/contract (3 → 5 keys).
- N2379 LiquidBridge doDump: `dump_neighbour_index`,
  `dumped_liquid_id` → N2287 schema/contract (3 → 5 keys).
- N2380 Unloader dump: `dump_neighbour_index`,
  `dumped_liquid_name` → N2293 schema/contract (6 → 8 keys).

**Pin update:** the N2377 registration test pinned the PRE-fold
contract/schema (3 keys, with a comment saying the fold waits for
a schema-sync slice) — updated to the folded 5 keys (the N2366
pin-update precedent). N2378/N2379/N2380 tests pin no owning
return_keys or schema keys.

## Commits

- Serial: `b1cfc01c7` (9 files, +196/−21) — 4 owning registers +
  1 test pin + 4 generated files (contracts + schema).

## Tests

Targeted: 8 modules (4 owning + 4 write-back) Ran 32 (24 PASS +
8 Godot-absent proofs), 0 other errors. The first run showed
Ran 32 failures=9 — the extra failure was exactly the N2377
pre-fold pin, fixed by the pin update above.
Full gate (wave advances-20 integration, PID 14748, 13:27–13:50): Ran 6547 tests in 1364.438s, FAILED (failures=312, skipped=5), 0 errors — 312/312 Godot-absent `AssertionError: unexpectedly None` (306 inherited + 6 new proof tests N2377–N2381 + N2383; N2382 adds +1 pin test, N2384/N2385 add no test).

## SSOT / DEFERRED

SSOT **+0** (12051/1812/1740/3272 unchanged — all 8 symbols were
already registered by the slices). DEFERRED 0. With N2367 + N2376
+ N2384, the write-back + offload advance keys are now FULLY
schema-synced — no remaining fold backlog for advances-17/18/19/
20.

## Godot debt

- No new proof. No re-run needed.
