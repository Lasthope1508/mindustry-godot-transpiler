# Handoff N2362 — ItemBridge doDump neighbour write-back

## What this slice did

The ItemBridge doDump advance exposes `dump_deliveries` (array); the
tick loops the deliveries calling the shared N2353 helper. 5 files,
+880/−5, commit `171386be4` on
`slice/N2362-item-bridge-dodump-write-back`.

## Key facts for the next agent

- **Multi-dump needs an array key:** a singular index+item pair would
  drop every delivery but one when dumpAccumulate fires multiple times
  per frame (ItemBridge.java:351). `dump_deliveries` = Array of
  {neighbour_index, item} in attempt order. TimerDump slices fire once
  per tick → scalar is correct there (N2360/N2361/N2363).
- SSOT +0/+1/+0/+0 (ledger only, reusing 5 N2288 symbols). DEFERRED
  324→323 (register built on the stale N2356 base 324 — merge by entry
  TEXT).
- The `dump_deliveries` symbol + schema/contract fold landed in N2367.

## Godot debt (this slice)

- NEW proof `C07ItemBridgeDoDumpWriteBackProof` (3 keys) — never run.
