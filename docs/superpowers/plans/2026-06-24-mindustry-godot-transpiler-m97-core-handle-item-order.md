# M97 Core handle item order migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/world/blocks/storage/CoreBlock.java`
- Lines checked from `CoreBuild.handleItem()`:
  - `public void handleItem(Building source, Item item){`
  - `if(items.get(item) >= storageCapacity || incinerate){`
  - `}else{`
  - `super.handleItem(source, item);`
- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from base `handleItem()`:
  - `items.add(item, 1);`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for `CoreBlock.handleItem()` capacity gate and base `BuildingComp.handleItem()` add-one behavior.
- [x] Add RED Godot runtime structure test for `source_core_handle_item()` and dump order.
- [x] Prove RED failure before production code.
- [x] Add `verify_core_handle_item_source()` in `source_parity.py`.
- [x] Add `source_core_handle_item()` in `PortGame.gd`.
- [x] Change `source_dump_drill_item_to_core()` to handle core before removing Drill inventory.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_core_handle_item_source()` and missing `source_core_handle_item()`.
- Targeted GREEN passed for source parity and core handle/dump order tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`: `Ran 123 tests in 1.413s`, `OK`.
- MCP editor bridge connected.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` in this beat.
- MCP runtime proof with `_process` disabled:
  - Core capacity `4000`.
  - Full core: `source_core_handle_item("copper") = false`, core stayed `4000`.
  - Open core: `source_core_handle_item("copper") = true`, core `3999 -> 4000`.
  - Dump: `source_dump_drill_item_to_core("copper") = true`, Drill/core `2/3999 -> 1/4000`.
  - Debug output `errors: []`, stop output `finalErrors: []`.

## Totals After This Beat

- Total tracked work items: 100
- Done: 100
- Not done: 0
- Blocked: 0
