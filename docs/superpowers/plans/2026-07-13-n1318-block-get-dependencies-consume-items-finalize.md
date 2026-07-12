# N1318 Block GetDependencies ConsumeItems Finalize

## Scope

- Slice: `N1318`
- Title: `Generated Block getDependencies ConsumeItems bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.getDependencies(Cons<UnlockableContent> cons)`
- Godot owner: `PortGame.source_block_get_dependencies_consume_items_state`
- Generated owner: `Block.java_method_getDependencies_119`
- Runtime proof: `/root/Main.generated_block_get_dependencies_consume_items_bridge_state`

## Source Evidence

```java
if(c instanceof ConsumeItems i){
    for(ItemStack stack : i.items){
        cons.get(stack.item);
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1318`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_getDependencies_119` preserves ConsumeItems guard, item-stack loop, and `cons.get(stack.item);`.
- [x] Added RED status assertion for `N1318`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1318` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1319` stayed `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1318` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed requirements plus non-optional `ConsumeItems` dependencies become `dependency_items=["copper","lead","graphite","silicon"]`.
- [x] Godot TCP source proof confirmed `consume_items_indices=[0,3]` and `consume_item_dependency_items=["graphite","silicon"]`.
- [x] Godot TCP source proof confirmed optional `ConsumeItems` index `1` is skipped and non-`ConsumeItems` index `2` adds no item dependency.
- [x] Godot TCP empty proof confirmed empty dependency and consume-items arrays.
- [x] Godot TCP generated bridge proof confirmed `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_get_dependencies_consume_items_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_get_dependencies_consume_items_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "test_port_game_exposes_source_block_get_dependencies_consume_items_state or test_port_game_exposes_generated_block_get_dependencies_consume_items_bridge_state"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k test_block_get_dependencies_consume_items_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_block_get_dependencies_consume_items_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_get_dependencies_consume_items`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, 'tools/mindustry_godot_transpiler'); from mindustry_port import source_ssot; report = source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']}); raise SystemExit(1 if report['errors'] else 0)"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 394.16s (0:06:34)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1318")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_get_dependencies_consume_items_state(requirements, consume_builder)`: `dependency_items=["copper","lead","graphite","silicon"]`, `consume_loop_indices=[0,1,2,3]`, `skipped_optional_indices=[1]`, `non_optional_indices=[0,2,3]`, `consume_items_indices=[0,3]`, `consume_item_dependency_items=["graphite","silicon"]`.
  - TCP `/root/Main.source_block_get_dependencies_consume_items_state([], [])`: `dependency_items=[]`, `consume_items_indices=[]`, `consume_item_dependency_items=[]`.
  - TCP `/root/Main.generated_block_get_dependencies_consume_items_bridge_state(requirements, consume_builder)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `996`
- Not done: `77`
- Source-backed remaining: `39`
- Other remaining: `38`
- Progress: `92.82%`
- Remaining: `7.18%`
- Current next source-backed finalize slice: `N1319 Generated Block getContentType bridge state`
- Current next source-backed owner: `PortGame.source_block_get_content_type_state`
