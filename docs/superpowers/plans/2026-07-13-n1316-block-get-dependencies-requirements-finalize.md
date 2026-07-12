# N1316 Block GetDependencies Requirements Finalize

## Scope

- Slice: `N1316`
- Title: `Generated Block getDependencies requirements bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.getDependencies(Cons<UnlockableContent> cons)`
- Godot owner: `PortGame.source_block_get_dependencies_requirements_state`
- Generated owner: `Block.java_method_getDependencies_119`
- Runtime proof: `/root/Main.generated_block_get_dependencies_requirements_bridge_state`

## Source Evidence

```java
public void getDependencies(Cons<UnlockableContent> cons){
    //just requires items
    for(ItemStack stack : requirements){
        cons.get(stack.item);
    }
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1316`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_getDependencies_119` preserves method signature, requirements comment, requirements loop, and `cons.get(stack.item);`.
- [x] Added RED status assertion for `N1316`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1316` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1317` stayed `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper test passed.
- [x] Focused generated bridge test passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1316` canonical and nested status are `done`.
- [x] Godot TCP requirements proof confirmed dependency items match requirement item order.
- [x] Godot TCP empty requirements proof confirmed dependency items are empty.
- [x] Godot TCP generated bridge proof confirmed `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_get_dependencies_requirements_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_get_dependencies_requirements_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_source_block_get_dependencies_requirements_state`
  - Result: `1 passed, 1544 deselected`.
- Focused generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_get_dependencies_requirements_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k test_block_get_dependencies_requirements_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_block_get_dependencies_requirements_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_get_dependencies_requirements`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, 'tools/mindustry_godot_transpiler'); from mindustry_port import source_ssot; report = source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']}); raise SystemExit(1 if report['errors'] else 0)"`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 399.86s (0:06:39)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1316")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_get_dependencies_requirements_state(requirements)`: `dependency_items=["copper","lead","graphite"]`.
  - TCP `/root/Main.source_block_get_dependencies_requirements_state([])`: `dependency_items=[]`.
  - TCP `/root/Main.generated_block_get_dependencies_requirements_bridge_state(requirements)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `994`
- Not done: `79`
- Source-backed remaining: `41`
- Other remaining: `38`
- Progress: `92.64%`
- Remaining: `7.36%`
- Current next source-backed finalize slice: `N1317 Generated Block getDependencies consumeBuilder optional bridge state`
- Current next source-backed owner: `PortGame.source_block_get_dependencies_consume_builder_optional_state`
