# Handoff N2386 — PayloadUnloader dump ITEM neighbour write-back

## What this slice did

The dump advance exposes `dump_deliveries` (ARRAY — one
`{"neighbour_index", "item"}` dict per successful dump, in attempt
order); the tick lands each delivery in the neighbour store through
the shared N2353 helper. 5 files, +1006/−16, commit `2c6d78e23` on
`slice/N2386-unloader-dump-item-write-back`.

## Key facts for the next agent

- **ARRAY, not scalar:** dumpAccumulate fires multiple times per
  frame (BuildingComp.java:1052, :1056-1058) and offloadSpeed 4
  runs it 4×/tick — a scalar pair would drop deliveries (the
  N2362/N2368/N2369 precedent).
- **Key collision:** `dump_neighbour_index` is ALREADY the liquid
  half's scalar key (N2380) — the item half does NOT reuse it.
- SSOT +1/+1/+0/+0 (brief estimated +2 on the scalar hypothesis).
  DEFERRED 306→305 (#304 resolved — both halves live now).
- Schema + contract fold landed in N2393.
- Live neighbour fill still deferred (acceptItem/canDump arrays are
  frame inputs, default []).

## Godot debt (this slice)

- NEW proof `C07PayloadUnloaderDumpItemWriteBackProof` (3 keys) —
  never run.
