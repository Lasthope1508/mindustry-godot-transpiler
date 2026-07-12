# N1296 Block Consume Power Dynamic Displayed Finalize

## Scope

- Slice: `N1296`
- Title: `Generated Block consumePowerDynamic displayed bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.consumePowerDynamic(float,Floatf)`
- Godot owner: `PortGame.source_block_consume_power_dynamic_displayed_state`
- Generated owner: `Block.java_method_consumePowerDynamic_104`
- Runtime proof: `/root/Main.generated_block_consume_power_dynamic_displayed_bridge_state`

## Source Evidence

```java
/** Creates a consumer that consumes a dynamic amount of power. */
public <T extends Building> ConsumePower consumePowerDynamic(float displayed, Floatf<T> usage){
    return consume(new ConsumePowerDynamic(displayed, (Floatf<Building>)usage));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1296`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_consumePowerDynamic_104` preserves `new ConsumePowerDynamic(displayed, (Floatf<Building>)usage)`, `(Floatf<Building>)usage`, `consume(new ConsumePowerDynamic(displayed, (Floatf<Building>)usage))`, explicit `float displayed`, explicit `Floatf<T> usage`, and `consume_called`.
- [x] Added RED status assertion for `N1296`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_consume_power_dynamic_displayed_result`.
- [x] Flipped `N1296` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_consume_power_dynamic_displayed_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1296` canonical and nested status are `done`.
- [x] Godot TCP shown-peak proof confirmed `matches=true`, `constructed_consume.type=ConsumePowerDynamic`, preserved `displayed`, preserved `usage`, and `consume_called=true`.
- [x] Godot TCP shown-idle proof confirmed `matches=true`, `constructed_consume.type=ConsumePowerDynamic`, preserved `displayed`, preserved `usage`, and `consume_called=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_power_dynamic_displayed_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_power_dynamic_displayed_bridge_state`
  - Result: failed as expected because `var block_consume_power_dynamic_displayed_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_power_dynamic_displayed_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_power_dynamic_displayed_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_consume_power_dynamic_displayed`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 387.44s (0:06:27)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1296")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_consume_power_dynamic_displayed_bridge_state(3.5, {"usage_id":"shown-peak","sample":1.4})`: `matches=true`, `constructed_consume.type=ConsumePowerDynamic`, preserved `displayed=3.5`, preserved `usage`, `consume_called=true`.
  - TCP `/root/Main.generated_block_consume_power_dynamic_displayed_bridge_state(0.25, {"usage_id":"shown-idle","sample":0.0})`: `matches=true`, `constructed_consume.type=ConsumePowerDynamic`, preserved `displayed=0.25`, preserved `usage`, `consume_called=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total source-backed slices: `1073`
- Done: `971`
- Not done: `102`
- Source-backed remaining: `64`
- Other remaining: `38`
- Progress: `90.49%`
- Remaining: `9.51%`
- Current first unresolved ledger slice by numeric order: `N1297 Block.consumePowerBuffered(float)`
- Current next owner: `PortGame.source_block_consume_power_buffered_state`
