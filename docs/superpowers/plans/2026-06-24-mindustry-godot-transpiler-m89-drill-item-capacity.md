# M89 Drill item capacity default migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/world/Block.java`
  - `public int itemCapacity = 10;`
- `mindustry-upstream/core/src/mindustry/world/blocks/production/Drill.java`
  - `hasItems = true;`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for Block default item capacity and Drill `hasItems`.
- [x] Add RED content registry test requiring `mechanical-drill` to inherit `itemCapacity=10`.
- [x] Prove RED failure before production code.
- [x] Add `verify_drill_item_capacity_source()` in `source_parity.py`.
- [x] Teach `content_registry.py` to read implementation `hasItems` assignments.
- [x] Apply `Block.itemCapacity` default when `hasItems=true` and block initializer does not override `itemCapacity`.
- [x] Regenerate `content_registry.json` and `MindustryContentRegistry.gd`.
- [x] Run full Python suite.
- [x] Verify Godot LSP via MCP.
- [x] Verify runtime capacity through MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_drill_item_capacity_source` and missing `mechanical-drill` capacity metadata.
- Targeted GREEN passed for source parity and content registry tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests`: `Ran 108 tests in 1.416s`, `OK`.
- MCP LSP diagnostics for `src/game/PortGame.gd`: `diagnostics: []`.
- MCP LSP diagnostics for `src/generated/MindustryContentRegistry.gd`: `diagnostics: []`.
- MCP runtime proof with `_process` disabled:
  - `source_block_item_capacity("mechanical-drill") = 10`
  - `source_block_item_capacity("core-shard") = 4000`
  - Runtime summary loaded `417` blocks
  - Debug output `errors: []`, stop output `finalErrors: []`

## Totals After This Beat

- Total tracked work items: 92
- Done: 92
- Not done: 0
- Blocked: 0
