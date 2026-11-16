# Handoff N2395 — Separator canDump itemFilter model

## What this slice did

2 pures: the filter pure reads catalog consumeItem rows +
`item_names_by_id` (exactly ConsumeItems.apply, no hardcoded
def); the canDump pure calls the generic `consumes_item_state`
directly. Separator → all-false (canDump always true);
Disassembler → scrap-only. 5 files, +956/−1, commit `32d0bce2f`
on `slice/N2395-separator-candump-item-filter`.

## Key facts for the next agent

- **Verify-first:** the separator has NO consumeItem key in the
  catalog, the disassembler has `[{scrap, 1}]`; item ids follow
  Items.load() (scrap id 8, 22 items).
- Cite canDump kept :175-177 for consistency (signature :177,
  return :178).
- SSOT +4/+1/+2/+4. DEFERRED #300 resolved (301→300).
- The N2388 sense pure docstring ("canDump stays deferred") went
  stale — fixed 1 line at integration (`293de3675`).

## Godot debt (this slice)

- NEW proof `C07SeparatorCanDumpItemFilterProof` (6 keys) —
  never run.
