# N1351 Block Reinitialize Consumers Item Liquid Filters Finalize

## Scope

- Slice: `N1351`
- Title: `Generated Block reinitializeConsumers item liquid filters bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.reinitializeConsumers()`
- Godot owner: `PortGame.source_block_reinitialize_consumers_item_liquid_filters_state`
- Generated owner: `Block.java_method_reinitializeConsumers_124`
- Runtime proof: `/root/Main.generated_block_reinitialize_consumers_item_liquid_filters_bridge_state`

## Source Evidence

```java
public void reinitializeConsumers(){
    itemFilter = new boolean[content.items().size];
    liquidFilter = new boolean[content.liquids().size];
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1351`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed `PortGame.source_block_reinitialize_consumers_item_liquid_filters_state` is backed by exact source expressions.
- [x] Confirmed generated `Block.java_method_reinitializeConsumers_124` has `item_liquid_filters` bridge mode.
- [x] Added RED status assertion for `N1351`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1351` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1351` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `content_items_size=3`, `content_liquids_size=2`, `item_filter_size=3`, `liquid_filter_size=2`, and all filter entries `false`.
- [x] Godot TCP zero-size source proof confirmed empty item/liquid filters.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for `3,2` and `0,0`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_reinitialize_consumers_item_liquid_filters_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_reinitialize_consumers_item_liquid_filters_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_reinitialize_consumers_item_liquid_filters or generated_block_reinitialize_consumers_item_liquid_filters"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_reinitialize_consumers_item_liquid_filters`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_reinitialize_consumers_item_liquid_filters`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_reinitialize_consumers_item_liquid_filters`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 396.35s (0:06:36)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1351")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_block_reinitialize_consumers_item_liquid_filters_state(3, 2)`: `item_filter_size=3`, `liquid_filter_size=2`, filters all `false`.
  - TCP `/root/Main.source_block_reinitialize_consumers_item_liquid_filters_state(0, 0)`: empty item/liquid filters.
  - TCP `/root/Main.generated_block_reinitialize_consumers_item_liquid_filters_bridge_state(3, 2)`: `matches=true`.
  - TCP `/root/Main.generated_block_reinitialize_consumers_item_liquid_filters_bridge_state(0, 0)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1026`
- Not done: `47`
- Source-backed remaining: `35`
- Active remaining: `12`
- Progress: `95.62%`
- Remaining: `4.38%`
- Current next active slice: `N1352 Generated Block reinitializeConsumers outputs power bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_reinitialize_consumers_outputs_power_state`
