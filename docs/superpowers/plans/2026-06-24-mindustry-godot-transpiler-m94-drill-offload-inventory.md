# M94 Drill offload inventory migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- `mindustry-upstream/core/src/mindustry/world/modules/ItemModule.java`
- Lines checked:
  - `public void offload(Item item){`
  - `produced(item, 1);`
  - `other.handleItem(self(), item);`
  - `handleItem(self(), item);`
  - `items[item] += amount;`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for `BuildingComp.offload()` neighbor/fallback and `ItemModule.add()` storage.
- [x] Add RED Godot runtime structure tests for Drill internal inventory and source offload wiring.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_offload_inventory_fallback_source()` in `source_parity.py`.
- [x] Add `drill_items` and inventory helpers in `PortGame.gd`.
- [x] Route Drill output batch through `source_offload_to_inventory()` instead of direct core credit.
- [x] Use `drill_items_total()` in source item-capacity gate.
- [x] Expose Drill inventory through runtime summary.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify Godot LSP via MCP.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing source parity helper, missing `drill_items`, and old direct-core output wiring.
- Targeted GREEN passed for source parity, Drill inventory, and output-batch tests.
- Full suite first caught two old tests still expecting direct core credit; tests were updated to require `source_offload_to_inventory()`.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests`: `Ran 117 tests in 1.396s`, `OK`.
- MCP LSP diagnostics for `src/game/PortGame.gd`: `diagnostics: []`.
- MCP runtime proof with `_process` disabled:
  - `source_offload_to_inventory("copper", 4)` changes Drill copper count `5 -> 9`
  - Inventory delta is `4`
  - `drill_items_total() = 9`
  - `source_drill_output_batch(650, 650, 2, 10, 10) = {"amount": 0, "progress": 650}`
  - Debug output `errors: []`, stop output `finalErrors: []`

## Totals After This Beat

- Total tracked work items: 97
- Done: 97
- Not done: 0
- Blocked: 0
