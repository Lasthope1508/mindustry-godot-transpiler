# Handoff N2447 — UAM onRemoved/drawSelect rows

## What this slice did

One pure-only pure
`source_unit_assembler_module_select_remove_state` (no tick
wiring): select_call (Drawf.selected, Pal.accent) + remove_call
(removeModule CALL record). Link is the N2351 {block, cell}
format; link without cell reads as null. 5 files, commit
`013a9818f` on `slice/N2447-uam-on-removed-draw-select-rows`.

## Key facts for the next agent

- **Pin break fixed by serial N2454** (N2432 precedent): the
  N2348 tier_stamp test pinned 'onRemoved / drawSelect still
  defer' — both are live now.
- **Cite correction:** onRemoved is :125-131, not :111-115 as
  the #29 entry said. TODO "draw area?" has no Java behaviour.
- SSOT +2/+1/+1/+2 (exact est). DEFERRED #29 resolved (258→257).

## Godot debt (this slice)

- NEW proof `C07UnitAssemblerModuleSelectRemoveRowsProof` (6 keys)
  — never run.
