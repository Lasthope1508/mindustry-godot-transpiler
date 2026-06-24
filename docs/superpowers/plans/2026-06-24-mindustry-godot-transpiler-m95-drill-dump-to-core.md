# M95 Drill dump to core migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from `dump(Item todump)`:
  - `public boolean dump(Item todump){`
  - `if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;`
  - `other.handleItem(self(), todump);`
  - `items.remove(todump, 1);`
  - `return true;`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for `BuildingComp.dump(Item)` guard, neighbor handoff, inventory removal, and success return.
- [x] Add RED Godot runtime structure test for Drill dump timer and inventory-to-core transfer.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_dump_remove_source()` in `source_parity.py`.
- [x] Add `drill_dump_timer` in `PortGame.gd`.
- [x] Add `remove_drill_item()` in `PortGame.gd`.
- [x] Add `source_dump_drill_item_to_core()` in `PortGame.gd`.
- [x] Add `simulate_drill_dump()` using `source_drill_dump_interval()`.
- [x] Call `simulate_drill_dump(delta)` during factory simulation.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_building_dump_remove_source` and missing `drill_dump_timer`/dump helpers.
- Targeted GREEN passed for source parity and Drill dump tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests`: `Ran 119 tests in 1.398s`, `OK`.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` three times in this beat; MCP editor bridge remained connected.
- MCP runtime proof with `_process` disabled:
  - `source_dump_drill_item_to_core("copper") = true`
  - Drill copper `3 -> 2`
  - Core copper `2 -> 3`
  - Debug output `errors: []`, stop output `finalErrors: []`

## Totals After This Beat

- Total tracked work items: 98
- Done: 98
- Not done: 0
- Blocked: 0
