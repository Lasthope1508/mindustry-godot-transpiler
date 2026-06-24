# M96 Drill dump accept capacity migration

## Source anchor

- `mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java`
- Lines checked from `dump(Item todump)`:
  - `if(other.acceptItem(self(), todump) && canDump(other, todump)){`
  - `other.handleItem(self(), todump);`
  - `items.remove(todump, 1);`
- `mindustry-upstream/core/src/mindustry/world/blocks/storage/CoreBlock.java`
- Lines checked from `CoreBuild` item acceptance:
  - `return state.rules.coreIncinerates || items.get(item) < getMaximumAccepted(item);`
  - `return state.rules.coreIncinerates ? Integer.MAX_VALUE/2 : storageCapacity;`

## Checklist

- [x] Read upstream Java before coding.
- [x] Add RED source parity test for `BuildingComp.dump(Item)` accept guard and `CoreBlock.acceptItem()` capacity semantics.
- [x] Add RED Godot runtime structure test requiring `source_core_accept_item()` before Drill inventory removal.
- [x] Prove RED failure before production code.
- [x] Add `verify_building_dump_accept_source()` in `source_parity.py`.
- [x] Add `source_core_accept_item()` in `PortGame.gd`.
- [x] Guard `source_dump_drill_item_to_core()` before `remove_drill_item()`.
- [x] Run targeted GREEN tests.
- [x] Run full Python suite.
- [x] Verify runtime behavior via MCP runtime port `7777`.
- [x] Update main migration checklist/spec.

## Verification

- Targeted RED failed for missing `verify_building_dump_accept_source()` and missing `source_core_accept_item()`/guard.
- Targeted GREEN passed for source parity and Drill dump capacity tests.
- `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`: `Ran 121 tests in 1.436s`, `OK`.
- MCP editor bridge connected.
- MCP LSP diagnostics for `src/game/PortGame.gd` timed out on `initialize` in this beat.
- MCP runtime proof with `_process` disabled:
  - Core capacity `4000`.
  - Full core: dump returned `false`; Drill copper `3 -> 3`; Core copper `4000 -> 4000`.
  - Open core: dump returned `true`; Drill copper `3 -> 2`; Core copper `3999 -> 4000`.
  - Debug output `errors: []`, stop output `finalErrors: []`.

## Totals After This Beat

- Total tracked work items: 99
- Done: 99
- Not done: 0
- Blocked: 0
