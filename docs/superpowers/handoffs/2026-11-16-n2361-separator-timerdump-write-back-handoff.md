# Handoff N2361 — Separator timerDump neighbour write-back

## What this slice did

The Separator timerDump advance exposes `dump_neighbour_index` /
`dumped_item`; the tick wires the shared N2353 helper after the
timerDump persist. 5 files, +855/−7, commit `c98355149` on
`slice/N2361-separator-timerdump-write-back`.

## Key facts for the next agent

- SCALAR index+item (timerDump fires once per tick).
- **DEFERRED numbering is 1-based** in the DEFERRED-after-*.py files —
  the SCOPE cited 0-based indices from a Python `enumerate` (all off by
  one); this slice resolves #242, not #241. Resolve DEFERRED by entry
  TEXT regardless.
- SSOT +2/+1/+0/+0. DEFERRED 320→319.
- Schema + contract fold landed in N2367.

## Godot debt (this slice)

- NEW proof `C07SeparatorTimerDumpWriteBackProof` (3 keys) — never run.
