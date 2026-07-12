# N1297 Block Consume Power Buffered Finalize

## Scope

- Slice: `N1297`
- Title: `Generated Block consumePowerBuffered bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.consumePowerBuffered(float)`
- Godot owner: `PortGame.source_block_consume_power_buffered_state`
- Generated owner: `Block.java_method_consumePowerBuffered_105`
- Runtime proof: `/root/Main.generated_block_consume_power_buffered_bridge_state`

## Source Evidence

```java
/**
 * Creates a consumer which stores power.
 * @param powerCapacity The maximum capacity in power units.
 */
public ConsumePower consumePowerBuffered(float powerCapacity){
    return consume(new ConsumePower(0f, powerCapacity, true));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1297`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_consumePowerBuffered_105` preserves `new ConsumePower(0f, powerCapacity, true)`, `0f`, `float powerCapacity`, `true`, `consume(new ConsumePower(0f, powerCapacity, true))`, and `consume_called`.
- [x] Added RED status assertion for `N1297`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_consume_power_buffered_result`.
- [x] Flipped `N1297` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_consume_power_buffered_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1297` canonical and nested status are `done`.
- [x] Godot TCP capacity `80.0` proof confirmed `matches=true`, `constructed_consume.type=ConsumePower`, `powerPerTick=0.0`, `capacity=80.0`, `buffered=true`, and `consume_called=true`.
- [x] Godot TCP capacity `250.5` proof confirmed `matches=true`, `constructed_consume.type=ConsumePower`, `powerPerTick=0.0`, `capacity=250.5`, `buffered=true`, and `consume_called=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_power_buffered_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_power_buffered_bridge_state`
  - Result: failed as expected because `var block_consume_power_buffered_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_power_buffered_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_power_buffered_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_consume_power_buffered`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 394.24s (0:06:34)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1297")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_consume_power_buffered_bridge_state(80.0)`: `matches=true`, `constructed_consume.type=ConsumePower`, `powerPerTick=0.0`, `capacity=80.0`, `buffered=true`, `consume_called=true`.
  - TCP `/root/Main.generated_block_consume_power_buffered_bridge_state(250.5)`: `matches=true`, `constructed_consume.type=ConsumePower`, `powerPerTick=0.0`, `capacity=250.5`, `buffered=true`, `consume_called=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total source-backed slices: `1073`
- Done: `972`
- Not done: `101`
- Source-backed remaining: `63`
- Other remaining: `38`
- Progress: `90.59%`
- Remaining: `9.41%`
- Current first unresolved ledger slice by numeric order: `N1298 Block.consumeItem(Item)`
- Current next owner: `PortGame.source_block_consume_item_single_state`
