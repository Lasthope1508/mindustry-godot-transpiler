# N1317 Block GetDependencies ConsumeBuilder Optional Finalize

## Scope

- Slice: `N1317`
- Title: `Generated Block getDependencies consumeBuilder optional bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.getDependencies(Cons<UnlockableContent> cons)`
- Godot owner: `PortGame.source_block_get_dependencies_consume_builder_optional_state`
- Generated owner: `Block.java_method_getDependencies_119`
- Runtime proof: `/root/Main.generated_block_get_dependencies_consume_builder_optional_bridge_state`

## Source Evidence

```java
public void getDependencies(Cons<UnlockableContent> cons){
    //just requires items
    for(ItemStack stack : requirements){
        cons.get(stack.item);
    }

    //also requires inputs
    for(var c : consumeBuilder){
        if(c.optional) continue;
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1317`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_getDependencies_119` preserves method signature, inputs comment, consumeBuilder loop, and optional skip guard.
- [x] Added RED status assertion for `N1317`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1317` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1318` stayed `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1317` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `dependency_items=["copper","lead"]`, `consume_loop_indices=[0,1,2]`, `skipped_optional_indices=[1]`, and `non_optional_indices=[0,2]`.
- [x] Godot TCP empty proof confirmed empty dependency and consume index arrays.
- [x] Godot TCP generated bridge proof confirmed `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_get_dependencies_consume_builder_optional_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_get_dependencies_consume_builder_optional_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "test_port_game_exposes_source_block_get_dependencies_consume_builder_optional_state or test_port_game_exposes_generated_block_get_dependencies_consume_builder_optional_bridge_state"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k test_block_get_dependencies_consume_builder_optional_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_block_get_dependencies_consume_builder_optional_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_get_dependencies_consume_builder_optional`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, 'tools/mindustry_godot_transpiler'); from mindustry_port import source_ssot; report = source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']}); raise SystemExit(1 if report['errors'] else 0)"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 383.57s (0:06:23)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1317")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_get_dependencies_consume_builder_optional_state(requirements, consume_builder)`: `dependency_items=["copper","lead"]`, `consume_loop_indices=[0,1,2]`, `skipped_optional_indices=[1]`, `non_optional_indices=[0,2]`.
  - TCP `/root/Main.source_block_get_dependencies_consume_builder_optional_state([], [])`: `dependency_items=[]`, `consume_loop_indices=[]`, `skipped_optional_indices=[]`, `non_optional_indices=[]`.
  - TCP `/root/Main.generated_block_get_dependencies_consume_builder_optional_bridge_state(requirements, consume_builder)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `995`
- Not done: `78`
- Source-backed remaining: `40`
- Other remaining: `38`
- Progress: `92.73%`
- Remaining: `7.27%`
- Current next source-backed finalize slice: `N1318 Generated Block getDependencies ConsumeItems bridge state`
- Current next source-backed owner: `PortGame.source_block_get_dependencies_consume_items_state`
