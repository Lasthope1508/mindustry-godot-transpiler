# N1293 Block Consume Power Finalize

## Scope

- Slice: `N1293`
- Title: `Generated Block consumePower bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.consumePower(float)`
- Godot owner: `PortGame.source_block_consume_power_state`
- Generated owner: `Block.java_method_consumePower_101`
- Runtime proof: `/root/Main.generated_block_consume_power_bridge_state`

## Source Evidence

```java
/**
 * Creates a consumer which directly uses power without buffering it.
 * @param powerPerTick The amount of power which is required each tick for 100% efficiency.
 * @return the created consumer object.
 */
public ConsumePower consumePower(float powerPerTick){
    return consume(new ConsumePower(powerPerTick, 0.0f, false));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1293`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_consumePower_101` preserves `new ConsumePower(powerPerTick, 0.0f, false)`, `consume(new ConsumePower(powerPerTick, 0.0f, false))`, explicit `float powerPerTick`, `capacity=0.0`, `buffered=false`, and `consume_called`.
- [x] Added RED status assertion for `N1293`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_consume_power_result`.
- [x] Flipped `N1293` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_consume_power_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1293` canonical and nested status are `done`.
- [x] Godot TCP `powerPerTick=1.8` proof confirmed `matches=true`, `constructed_consume.type=ConsumePower`, `capacity=0.0`, `buffered=false`, `consume_called=true`, and preserved `powerPerTick`.
- [x] Godot TCP `powerPerTick=0.5` proof confirmed `matches=true`, `constructed_consume.type=ConsumePower`, `capacity=0.0`, `buffered=false`, `consume_called=true`, and preserved `powerPerTick`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_power_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_power_bridge_state`
  - Result: failed as expected because `var block_consume_power_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_power_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_power_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_consume_power`
  - Result: `25 passed, 3992 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 392.83s (0:06:32)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1293")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_consume_power_bridge_state(1.8)`: `matches=true`, `constructed_consume.type=ConsumePower`, `powerPerTick=1.8`, `capacity=0.0`, `buffered=false`, `consume_called=true`.
  - TCP `/root/Main.generated_block_consume_power_bridge_state(0.5)`: `matches=true`, `constructed_consume.type=ConsumePower`, `powerPerTick=0.5`, `capacity=0.0`, `buffered=false`, `consume_called=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total source-backed slices: `1073`
- Done: `968`
- Not done: `105`
- Source-backed remaining: `67`
- Other remaining: `38`
- Progress: `90.21%`
- Remaining: `9.79%`
- Current first unresolved ledger slice by numeric order: `N1294 Block.consumePowerCond(float,Boolf)`
- Current next owner: `PortGame.source_block_consume_power_cond_state`
