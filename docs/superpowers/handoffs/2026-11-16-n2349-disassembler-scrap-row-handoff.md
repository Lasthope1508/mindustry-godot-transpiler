# Handoff N2349 — Disassembler scrap item efficiency row

## What this slice did

Added the disassembler-only ConsumeItems scrap efficiency row (binary
1/0 on held scrap) to the Separator first pass. 5 files, +983/−2, commit
`79d467e2` on `slice/N2349-disassembler-scrap-row`.

## Key facts for the next agent

- Pure `source_separator_disassembler_scrap_row_state(frame,
  has_item_consumer, stacks, multiplier=1.0)` → `{has_item_row, row:
  {result, is_power: false}}` (the envelope N2153/N2268). Binary 1/0 on
  `items.has` of every stack at `round(amount * multiplier)`, via the
  shared `inventory.item_count` helper.
- Tick fold: stacks from catalog `consumeItem` rows, gated on
  `block.properties.has("consumeItem")`, appended to `required_results`
  after the liquid row — only the disassembler def folds it (separator has
  no `consumeItem`). No removal: scrap removal stays in the N2222 advance
  `consume()` (Consume.update is empty).
- SSOT +2/+1/+1/+2 (pure returns 2 keys; ledger java_source Separator.java
  per the N2268 family-pattern — consumer java_source breaks the
  `consumer_slices` shard). DEFERRED −1+0 (resolve scrap entry #218).
- **Cites (verified by this slice, fixed by the coordinator at
  integration):** disassembler def rows in content/Blocks.java —
  craftTime :1258, size :1259, itemCapacity :1260 (NOT :1261 — :1261 is a
  blank line), consumePower :1262, consumeItem :1263, consumeLiquid :1264.
  Entry #44 was off by +1 on 3 of 4 cites — rewritten in place in the
  merged DEFERRED snapshot.
- Follow-through: NO old proof stale, no re-run (all 6 C07Separator proofs
  tick the separator def only).

## Godot debt (this slice)

- NEW proof `C07SeparatorDisassemblerScrapRowProof` (6 keys) — never run.
