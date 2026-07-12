# N1300 Block Consume Items Varargs Finalize

## Scope

- Slice: `N1300`
- Title: `Generated Block consumeItems varargs bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.consumeItems(ItemStack...)`
- Godot owner: `PortGame.source_block_consume_items_varargs_state`
- Generated owner: `Block.java_method_consumeItems_108`
- Runtime proof: `/root/Main.generated_block_consume_items_varargs_bridge_state`

## Source Evidence

```java
public ConsumeItems consumeItems(ItemStack... items){
    return consume(new ConsumeItems(items));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1300`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_consumeItems_108` preserves `public ConsumeItems consumeItems(ItemStack... items){`, `return consume(new ConsumeItems(items));`, `new ConsumeItems(items)`, `consume(new ConsumeItems(items))`, explicit `ItemStack... items`, and `consume_called`.
- [x] Added RED status assertion for `N1300`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_consume_items_varargs_result`.
- [x] Flipped `N1300` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_consume_items_varargs_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1300` canonical and nested status are `done`.
- [x] Godot TCP item varargs proof confirmed `matches=true`, `constructed_consume.type=ConsumeItems`, preserved copper/lead items, and `consume_called=true`.
- [x] Godot TCP empty varargs proof confirmed `matches=true`, preserved empty items array, `constructed_consume.type=ConsumeItems`, and `consume_called=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_items_varargs_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_items_varargs_bridge_state`
  - Result: failed as expected because `var block_consume_items_varargs_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_items_varargs_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_items_varargs_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_consume_items_varargs`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 385.64s (0:06:25)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1300")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_consume_items_varargs_bridge_state([{"item":"copper","amount":3},{"item":"lead","amount":2}])`: `matches=true`, preserved items, `constructed_consume.type=ConsumeItems`, `consume_called=true`.
  - TCP `/root/Main.generated_block_consume_items_varargs_bridge_state([])`: `matches=true`, preserved empty items array, `constructed_consume.type=ConsumeItems`, `consume_called=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `975`
- Not done: `98`
- Source-backed remaining: `60`
- Other remaining: `38`
- Progress: `90.87%`
- Remaining: `9.13%`
- Current first numeric non-done ledger slice: `N462`
- Current next source-backed finalize slice: `N1301 Block.consumeCoolant(float)`
- Current next source-backed owner: `PortGame.source_block_consume_coolant_single_state`
