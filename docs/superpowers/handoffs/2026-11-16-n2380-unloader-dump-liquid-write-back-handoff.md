# Handoff N2380 — PayloadUnloader dump LIQUID neighbour write-back

## What this slice did

The Unloader dump advance exposes `dump_neighbour_index` +
`dumped_liquid_name` (String); the tick wires the shared N2371
helper when dumped_liquid > 0 and the index is ≥ 0. LIQUID half
only. 5 files, +1019/−10, commit `2b39a7bc0` on
`slice/N2380-unloader-dump-liquid-write-back`.

## Key facts for the next agent

- **Key collision:** the old `dumped_liquid` key is the FLOAT
  amount dumped — its meaning is untouched; the name rides the
  NEW key `dumped_liquid_name`.
- **Name via frame input:** the tick stamps
  `frame["liquid_names_by_id"]` (from `catalog.get_many("liquid")`,
  index == id — the PayloadLoader precedent); the pure resolves
  `liquid_names_by_id[int(current)]`. No signature change — the
  N2293 test pins the exact tick call string + count==2.
- SSOT +2/+1/+0/+0. DEFERRED #258 rewritten in place (liquid
  live, item half still waits) — count stays 311.
- The schema/contract fold landed in N2384.
- Follow-through: the Unloader ITEM write-back needs its own
  slice (`dump_item_state` already returns `handled_index`).

## Godot debt (this slice)

- NEW proof `C07PayloadUnloaderDumpLiquidWriteBackProof` (3 keys)
  — never run.
