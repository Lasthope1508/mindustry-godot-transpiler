# Handoff N2379 — LiquidBridge doDump neighbour write-back

## What this slice did

The LiquidBridge doDump advance exposes `dump_neighbour_index` +
`dumped_liquid_id`; the tick wires the shared N2371 helper when
dumped_amount > 0. 5 files, +940/−8, commit `bfafb77b2` on
`slice/N2379-liquid-bridge-dodump-liquid-write-back`.

## Key facts for the next agent

- **The pure exposes the liquid ID, not a name:** the bridge dumps
  `liquids.current()` (any liquid, not a def constant) and the pure
  has no catalog input. The tick resolves the name through
  `liquid_names_by_id` (from `catalog.get_many("liquid")`, index =
  id — the PayloadLoader precedent) before calling the helper.
- Water is liquid id 0. Size-1 ring 0 offset (0,−1).
- SSOT +2/+1/+0/+0. DEFERRED 311→310 (#247 resolved).
- The schema/contract fold landed in N2384.

## Godot debt (this slice)

- NEW proof `C07LiquidBridgeDumpWriteBackProof` (3 keys) —
  never run.
