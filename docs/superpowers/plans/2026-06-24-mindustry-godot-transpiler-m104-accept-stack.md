# M104 Accept stack migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from `acceptStack()`:
  - `public int acceptStack(Item item, int amount, Teamc source){`
  - `if(acceptItem(self(), item) && block.hasItems && (source == null || source.team() == team)){`
  - `return Math.min(getMaximumAccepted(item) - items.get(item), amount);`
  - `return 0;`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for `acceptStack()` guard and result snippets.
- [x] Add RED Godot runtime structure test for accept-stack state helper.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_accept_stack_source()` in `source_parity.py`.
- [x] Add `source_building_accept_stack_state()` in `PortGame.gd`.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_building_accept_stack_source()` and missing `source_building_accept_stack_state()`.
- Targeted GREEN passed for source parity and runtime structure tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`: `Ran 137 tests in 1.440s`, `OK`.
- MCP editor bridge connected.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` in this beat.
- MCP runtime proof with `_process` disabled:
  - `source_building_accept_stack_state(false, true, true, 10, 3, 5)` returns `0`.
  - `source_building_accept_stack_state(true, false, true, 10, 3, 5)` returns `0`.
  - `source_building_accept_stack_state(true, true, false, 10, 3, 5)` returns `0`.
  - `source_building_accept_stack_state(true, true, true, 10, 3, 5)` returns `5`.
  - `source_building_accept_stack_state(true, true, true, 10, 8, 5)` returns `2`.
  - Debug output `errors: []`, stop output `finalErrors: []`.

## Totals After This Beat

- Total tracked work items: 107
- Done: 107
- Not done: 0
- Blocked: 0
