# N1294 Block Consume Power Cond Finalize

## Scope

- Slice: `N1294`
- Title: `Generated Block consumePowerCond bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.consumePowerCond(float,Boolf)`
- Godot owner: `PortGame.source_block_consume_power_cond_state`
- Generated owner: `Block.java_method_consumePowerCond_102`
- Runtime proof: `/root/Main.generated_block_consume_power_cond_bridge_state`

## Source Evidence

```java
/** Creates a consumer which only consumes power when the condition is met. */
public <T extends Building> ConsumePower consumePowerCond(float usage, Boolf<T> cons){
    return consume(new ConsumePowerCondition(usage, (Boolf<Building>)cons));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1294`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_consumePowerCond_102` preserves `new ConsumePowerCondition(usage, (Boolf<Building>)cons)`, `(Boolf<Building>)cons`, `consume(new ConsumePowerCondition(usage, (Boolf<Building>)cons))`, explicit `float usage`, explicit `Boolf<T> cons`, and `consume_called`.
- [x] Added RED status assertion for `N1294`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_consume_power_cond_result`.
- [x] Flipped `N1294` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_consume_power_cond_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1294` canonical and nested status are `done`.
- [x] Godot TCP enabled-condition proof confirmed `matches=true`, `constructed_consume.type=ConsumePowerCondition`, `consume_called=true`, and preserved `usage`/`condition`.
- [x] Godot TCP low-power proof confirmed `matches=true`, `constructed_consume.type=ConsumePowerCondition`, `consume_called=true`, and preserved `usage`/`condition`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_power_cond_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_power_cond_bridge_state`
  - Result: failed as expected because `var block_consume_power_cond_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_power_cond_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_power_cond_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_consume_power_cond`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 381.64s (0:06:21)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1294")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_consume_power_cond_bridge_state(2.25, {"condition_id":"power-enabled","result":true})`: `matches=true`, `constructed_consume.type=ConsumePowerCondition`, `usage=2.25`, preserved condition, `consume_called=true`.
  - TCP `/root/Main.generated_block_consume_power_cond_bridge_state(0.75, {"condition_id":"low-power","result":false})`: `matches=true`, `constructed_consume.type=ConsumePowerCondition`, `usage=0.75`, preserved condition, `consume_called=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total source-backed slices: `1073`
- Done: `969`
- Not done: `104`
- Source-backed remaining: `66`
- Other remaining: `38`
- Progress: `90.31%`
- Remaining: `9.69%`
- Current first unresolved ledger slice by numeric order: `N1295 Block.consumePowerDynamic(Floatf)`
- Current next owner: `PortGame.source_block_consume_power_dynamic_state`
