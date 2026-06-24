# M103 Maximum accepted and stack migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from default `getMaximumAccepted()` and `handleStack()`:
  - `public int getMaximumAccepted(Item item){`
  - `return block.itemCapacity;`
  - `public void handleStack(Item item, int amount, @Nullable Teamc source){`
  - `noSleep();`
  - `items.add(item, amount);`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for default max accepted and stack handling snippets.
- [x] Add RED Godot runtime structure test for max accepted and stack count state.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_maximum_accepted_stack_source()` in `source_parity.py`.
- [x] Add `source_building_maximum_accepted()` in `PortGame.gd`.
- [x] Add `source_building_handle_stack_count()` in `PortGame.gd`.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_building_maximum_accepted_stack_source()` and missing source maximum/stack helpers.
- Targeted GREEN passed for source parity and runtime structure tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`: `Ran 135 tests in 1.506s`, `OK`.
- MCP editor bridge connected.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` in this beat.
- MCP runtime proof with `_process` disabled:
  - `source_building_maximum_accepted(10)` returns `10`.
  - `source_building_maximum_accepted(4000)` returns `4000`.
  - `source_building_handle_stack_count(0, 5)` returns `5`.
  - `source_building_handle_stack_count(7, 3)` returns `10`.
  - Debug output `errors: []`, stop output `finalErrors: []`.

## Totals After This Beat

- Total tracked work items: 106
- Done: 106
- Not done: 0
- Blocked: 0
