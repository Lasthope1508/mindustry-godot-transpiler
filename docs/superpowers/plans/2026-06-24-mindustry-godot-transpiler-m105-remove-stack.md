# M105 Remove stack migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from `removeStack()`:
  - `public int removeStack(Item item, int amount){`
  - `if(items == null) return 0;`
  - `amount = Math.min(amount, items.get(item));`
  - `noSleep();`
  - `items.remove(item, amount);`
  - `return amount;`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for `removeStack()` snippets.
- [x] Add RED Godot runtime structure test for remove-stack state helper.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_remove_stack_source()` in `source_parity.py`.
- [x] Add `source_building_remove_stack_state()` in `PortGame.gd`.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.
- [x] Run `git diff --check`.
- [x] Stage only touched files and commit.

## Verification

- Targeted RED failed for missing `verify_building_remove_stack_source()` and missing `source_building_remove_stack_state()`.
- Targeted GREEN passed for source parity and runtime structure tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`: `Ran 139 tests in 1.454s`, `OK`.
- MCP editor bridge connected.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` in this beat.
- MCP runtime proof with `_process` disabled:
  - `source_building_remove_stack_state(false, 7, 3)` returns `{removed=0, remaining=7}`.
  - `source_building_remove_stack_state(true, 7, 3)` returns `{removed=3, remaining=4}`.
  - `source_building_remove_stack_state(true, 2, 5)` returns `{removed=2, remaining=0}`.
  - Debug output `errors: []`, stop output `finalErrors: []`.
- `git diff --check`: exit `0` with CRLF normalization warnings only.

## Totals After This Beat

- Total tracked work items: 108
- Done: 108
- Not done: 0
- Blocked: 0
