# Report N2458 — DuctRouter handleStack / removeStack rows

**Slice:** N2458 — DuctRouter.handleStack() + removeStack(): one
pure-only pure models the current-item transfer. **Wave:**
advances-30. **Commit:** `13cd14473` on
`slice/N2458-duct-router-handle-stack-rows` (base `4e4dc1a7c`).
**Files:** 5, +885/−1.

## Source

removeStack() (DuctRouter.java:166-171): `int removed =
super.removeStack(item, amount); if(item == current) current =
null; return removed;`. handleStack (:173-177): `super.handleStack(
item, amount, source); current = item;`. handleItem (:179-185):
`current = item; progress = -1f; items.add(item, 1); noSleep();`
— NOT part of this slice (tracked under the N2324/N2332 entries).
BuildingComp.removeStack (:786-792): removed = `Math.min(amount,
items.get(item))`; `items == null → return 0`. BuildingComp.
handleStack (:795-798): `items.add(item, amount)`. ItemModule.add
(ItemModule.java:234-242): `+=` only, no clamp.

## Implementation

One pure-only pure (no tick wiring — the tick does not call these
yet):
`source_duct_router_handle_stack_state(action, item, amount,
current, items_count)` → `{current_after, removed_count,
items_count_after}`. Action ∈ {"handle_stack", "remove_stack"} (the
N2443/N2449 discriminated-input precedent). `item` is a Dict {name}
or null; `current` is null-or-Dict {name}. handle_stack: super adds
`amount` to the store (items_count_after = items_count + amount),
current_after = item, removed_count = 0. remove_stack: removed_count
= min(amount, items_count); items_count_after = items_count −
removed_count; current_after = null iff item == current (name
equality — Java `==` on Item is identity, the N2449 precedent).

**Verify-first findings (the brief was CORRECT on all 3 points,
no correction needed):**
- removeStack clamps min(amount, items.get(item)) and returns 0
  for a null store; handleStack adds the full amount, unclamped.
- `current` is `public @Nullable Item current;`
  (DuctRouter.java:80) — the same field the N2324 target pure
  reads (frame key `"current"`), aligned.
- **The clear is UNCONDITIONAL on the removed amount** —
  `if(item == current) current = null;` (:168) has no `removed > 0`
  guard, so removing 0 of the current item still clears it (the
  proof covers both cases).
- Documented deviations (not errors): the pure models the non-null
  store branch (the driver frame always has an items dict, so the
  `items == null` branch does not apply to a placed router);
  `noSleep()` is not modeled (no sleep state in the driver); item
  comparison is by name.

## Commits

- Slice: `13cd14473` (5 files, +885/−1).
- Integration cherry-pick: `2b5503368` (clean).

## Tests

Targeted (new module
`tests.test_c07_duct_router_handle_stack_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM
(user order 2026-11-15). RED confirmed first (KeyError 'N2458' +
pure missing + proof Godot-absent).
Full gate (wave advances-30 integration, PID 1777, from 22:30): Ran 6818 tests in 1589.793s, FAILED (failures=379, skipped=5), 0 errors — 379/379 Godot-absent (372 inherited + 7 new proof tests N2455–N2461; Ran 6818 = 6790 + 28 new tests, exact arithmetic; run 1 PID 13870 killed by VM restart #16 ~22:29, no footer).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 12315/1872/1813/3418 (exactly
as estimated). 3 symbols:
`source_duct_router_handle_stack_state_result.{current_after,
removed_count, items_count_after}`; 1 contract, 2 schemas (input +
result). DEFERRED **#253 RESOLVED** (253→252, by entry TEXT — the
last entry of the merged 253 base; no new entry).

## Godot debt

- NEW proof `C07DuctRouterHandleStackRowsProof` (6 keys:
  `handle_stack_sets_current`, `handle_stack_adds`,
  `remove_stack_clears`, `remove_stack_keeps_other`,
  `remove_stack_clamp`, `remove_stack_return`) — written but NEVER
  run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
