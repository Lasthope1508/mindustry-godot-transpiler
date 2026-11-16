# Handoff N2377 — SolidPump dumpLiquid neighbour write-back

## What this slice did

The SolidPump dump advance exposes `dump_neighbour_index` +
`dumped_liquid` ("water", def constant); the tick wires the shared
N2371 helper when dumped_amount > 0 and the index is ≥ 0. 5 files,
+913/−9, commit `b5cd8a13a` on
`slice/N2377-solid-pump-dump-liquid-write-back`.

## Key facts for the next agent

- `dumped_liquid` is the def constant `"water"` (Blocks.java:2922);
  `dumped_amount` already existed — no duplicate key.
- Tick reads `origin_cell` inline as `dump_cell` (`cell` binds after
  the enabled block — the N2363 note). Failed write-back drops the
  water, no fallback (N2353 precedent).
- SSOT +2/+1/+0/+0. DEFERRED 311→310 (#244 resolved).
- The schema/contract fold landed in N2384.
- FLAG: the N2371 proof pins `cursor_after == 1` for 1-neighbour
  cases but the code gives 0 (full cycle) — fixed by N2385.

## Godot debt (this slice)

- NEW proof `C07SolidPumpDumpLiquidWriteBackProof` (3 keys) —
  never run.
