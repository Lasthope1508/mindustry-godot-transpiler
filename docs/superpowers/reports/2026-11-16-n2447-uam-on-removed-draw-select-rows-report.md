# Report N2447 — UnitAssemblerModule onRemoved / drawSelect rows

**Slice:** N2447 — UnitAssemblerModule.drawSelect() + onRemoved():
one pure-only pure models the link highlight and the removeModule
call. **Wave:** advances-29. **Commit:** `013a9818f` on
`slice/N2447-uam-on-removed-draw-select-rows` (base `27b5ced7f`).
**Files:** 5.

## Source

drawSelect() (UnitAssemblerModule.java:118-123): `//TODO draw area?`
+ `if(link != null){ Drawf.selected(link, Pal.accent); }`.
onRemoved() (:125-131): `super.onRemoved(); if(link != null){
link.removeModule(this); }`.

## Implementation

One pure-only pure `source_unit_assembler_module_select_remove_state(link)`
(no tick wiring) — 2 result symbols: `select_call` (`{method:
"drawSelected", target: link, color: "Pal.accent"}` — Drawf.selected
Building overload, Drawf.java:330; accent = `Color.valueOf("ffd37f")`,
Pal.java:79) and `remove_call` (`{method: "removeModule", target:
link}` — CALL record, the N2396 precedent). The link is the N2351
frame-input format `{block, cell: Vector2i}`; a link without a cell
(or a non-Dictionary link) reads as null, defensive per N2351/N2358.
`super.onRemoved()` is recorded as `remove_super_expr`, not modeled.
The TODO "draw area?" has no Java behaviour and is not ported.
`removeModule` itself (UnitAssembler.java:358-360) is the assembler's
method — recorded as a call, not ported.

**Findings beyond the brief:**
1. **Expected pin break (coordinator serial fix N2454):** the
   required docstring update ("Select / remove rows live (N2447)")
   breaks `test_c07_unit_assembler_module_tier_stamp.py`, whose
   row-state test pins `'onRemoved / drawSelect still defer'`
   (line 158, the N2432 pin). The worker verified tier_stamp Ran 4,
   failures=2 (1 proof Godot-absent + 1 pin break) and did not touch
   that test (not its file). Fixed at integration by N2454.
2. **Minor in-scope doc fix:** the N2425 comment block in the same
   driver said drawSelect "is not ported" — now false, so the worker
   updated that sentence to point at N2447. N2425 draw_rows still
   3/4 PASS + proof Godot-absent.
3. **Cite correction:** the DEFERRED #29 entry cites onRemoved as
   :111-115, but the actual method is :125-131 (:111-115 is inside
   the acceptPayload/field area). Resolved by entry TEXT; the entry
   text itself is unchanged (it is gone now).

## Commits

- Slice: `013a9818f` (5 files).
- Integration cherry-pick: `9bca6ec75` (clean).

## Tests

Targeted (new module
`tests.test_c07_unit_assembler_module_select_remove_rows`): 3/4
PASS (registration, exact-evidence 12/12 exprs verbatim, row-state)
+ proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). RED confirmed
first (KeyError 'N2447' + pure not found).
Full gate (wave advances-29 integration, PID 5146, from 20:43): Ran 6790 tests in 3014.832s, FAILED (failures=372, skipped=5), 0 errors — 372/372 Godot-absent (365 inherited + 7 new proof tests N2447–N2453; Ran 6790 = 6762 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12293/1865/1802/3396 (exactly
as estimated). Generated output reverted per BRIEF-COMMON
(coordinator re-runs register at integration). DEFERRED **#29
RESOLVED** (258→257, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07UnitAssemblerModuleSelectRemoveRowsProof` (6 keys:
  `select_null`, `select_link`, `select_accent`, `remove_null`,
  `remove_link`, `link_no_cell_defensive`) — written but NEVER run;
  debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
