# Handoff N2458 — DuctRouter handleStack rows

## What this slice did

One pure-only pure `source_duct_router_handle_stack_state` (no
tick wiring): handle_stack (adds amount, current = item) /
remove_stack (removed = min(amount, count), current clears iff
item == current). handleItem NOT ported (tracked N2324/N2332). 5
files, +885/−1, commit `13cd14473` on
`slice/N2458-duct-router-handle-stack-rows`.

## Key facts for the next agent

- **Clear is unconditional:** removing 0 of the current item
  still clears it (no `removed > 0` guard in Java :168).
- **Brief was correct on all 3 points** (removeStack clamp,
  handleStack unclamped add, `current` = the N2324 field).
- SSOT +3/+1/+1/+2 (exact est). DEFERRED #253 resolved (253→252).

## Godot debt (this slice)

- NEW proof `C07DuctRouterHandleStackRowsProof` (6 keys) — never
  run.
