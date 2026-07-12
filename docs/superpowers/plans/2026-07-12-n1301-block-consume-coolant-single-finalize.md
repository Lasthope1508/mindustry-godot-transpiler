# N1301 Block Consume Coolant Single Finalize

## Scope

- Slice: `N1301`
- Title: `Generated Block consumeCoolant single bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.consumeCoolant(float)`
- Godot owner: `PortGame.source_block_consume_coolant_single_state`
- Generated owner: `Block.java_method_consumeCoolant_109`
- Runtime proof: `/root/Main.generated_block_consume_coolant_single_bridge_state`

## Source Evidence

```java
public ConsumeCoolant consumeCoolant(float amount){
    return consume(new ConsumeCoolant(amount));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1301`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_consumeCoolant_109` preserves `public ConsumeCoolant consumeCoolant(float amount){`, `return consume(new ConsumeCoolant(amount));`, `new ConsumeCoolant(amount)`, `consume(new ConsumeCoolant(amount))`, explicit `float amount`, and `consume_called`.
- [x] Added RED status assertion for `N1301`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_consume_coolant_single_result`.
- [x] Flipped `N1301` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_consume_coolant_single_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1301` canonical and nested status are `done`.
- [x] Godot TCP small amount proof confirmed `matches=true`, `amount=0.2`, `constructed_consume.type=ConsumeCoolant`, `constructed_consume.amount=0.2`, and `consume_called=true`.
- [x] Godot TCP large amount proof confirmed `matches=true`, `amount=12.5`, `constructed_consume.type=ConsumeCoolant`, `constructed_consume.amount=12.5`, and `consume_called=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_coolant_single_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_coolant_single_bridge_state`
  - Result: failed as expected because `var block_consume_coolant_single_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_coolant_single_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_coolant_single_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_consume_coolant_single`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 400.21s (0:06:40)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1301")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_consume_coolant_single_bridge_state(0.2)`: `matches=true`, `amount=0.2`, `constructed_consume.type=ConsumeCoolant`, `constructed_consume.amount=0.2`, `consume_called=true`.
  - TCP `/root/Main.generated_block_consume_coolant_single_bridge_state(12.5)`: `matches=true`, `amount=12.5`, `constructed_consume.type=ConsumeCoolant`, `constructed_consume.amount=12.5`, `consume_called=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `976`
- Not done: `97`
- Source-backed remaining: `59`
- Other remaining: `38`
- Progress: `90.96%`
- Remaining: `9.04%`
- Current first numeric non-done ledger slice: `N462`
- Current next source-backed finalize slice: `N1302 Block.consumeCoolant(float,boolean,boolean)`
- Current next source-backed owner: `PortGame.source_block_consume_coolant_filtered_state`
