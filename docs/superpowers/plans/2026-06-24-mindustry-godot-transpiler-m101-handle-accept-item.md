# M101 Handle and accept item migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from default `handleItem()` and `acceptItem()`:
  - `public void handleItem(Building source, Item item){`
  - `items.add(item, 1);`
  - `public boolean acceptItem(Building source, Item item){`
  - `return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for default item handle/accept snippets.
- [x] Add RED Godot runtime structure test for handle count and accept guard state.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_handle_accept_item_source()` in `source_parity.py`.
- [x] Add `source_building_handle_item_count()` in `PortGame.gd`.
- [x] Add `source_building_accept_item_state()` in `PortGame.gd`.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_building_handle_accept_item_source()` and missing source handle/accept helpers.
- Targeted GREEN passed for source parity and runtime structure tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`: `Ran 131 tests in 1.404s`, `OK`.
- MCP editor bridge connected.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` in this beat.
- MCP runtime proof with `_process` disabled:
  - `source_building_accept_item_state(false, 0, 10)` returns `false`.
  - `source_building_accept_item_state(true, 10, 10)` returns `false`.
  - `source_building_accept_item_state(true, 9, 10)` returns `true`.
  - `source_building_handle_item_count(0)` returns `1`.
  - `source_building_handle_item_count(7)` returns `8`.
  - Debug output `errors: []`, stop output `finalErrors: []`.

## Totals After This Beat

- Total tracked work items: 104
- Done: 104
- Not done: 0
- Blocked: 0
