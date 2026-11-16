# Handoff N2378 — Pump dumpLiquid neighbour write-back

## What this slice did

The Pump dump advance exposes `dump_neighbour_index` +
`dumped_liquid` (both return paths); the tick wires the shared N2371
helper when dumped_amount > 0 and the index is ≥ 0. 5 files,
+897/−13, commit `9bec948b8` on
`slice/N2378-pump-dump-liquid-write-back`.

## Key facts for the next agent

- **liquid_drop is a String name, not an id/dict:**
  `source_floor_liquid_drop_state` returns `"water"` / `"oil"` /
  `"cryofluid"` / `"slag"` / `"arkycite"` or null, so
  `dumped_liquid = str(liquid_drop)` — the dumped liquid VARIES
  BY TILE (unlike the Fracker's def constant "oil"). `""` on the
  null-drop path.
- `cell` is already bound before the enabled block — no
  `dump_cell` workaround needed.
- SSOT +2/+1/+0/+0. DEFERRED 311→310 (#241 resolved).
- The schema/contract fold landed in N2384.

## Godot debt (this slice)

- NEW proof `C07PumpLiquidNeighbourWriteBackProof` (3 keys) —
  never run.
