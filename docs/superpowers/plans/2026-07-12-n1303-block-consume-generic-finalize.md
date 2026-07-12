# N1303 Block Consume Generic Finalize

## Scope

- Slice: `N1303`
- Title: `Generated Block consume generic bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.consume(T)`
- Godot owner: `PortGame.source_block_consume_generic_state`
- Generated owner: `Block.java_method_consume_111`
- Runtime proof: `/root/Main.generated_block_consume_generic_bridge_state`

## Source Evidence

```java
public <T extends Consume> T consume(T consume){
    if(consume instanceof ConsumePower){
        //there can only be one power consumer
        consumeBuilder.removeAll(b -> b instanceof ConsumePower);
        consPower = (ConsumePower)consume;
    }
    consumeBuilder.add(consume);
    return consume;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1303`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_consume_111` preserves `public <T extends Consume> T consume(T consume){`, `if(consume instanceof ConsumePower){`, `//there can only be one power consumer`, `consumeBuilder.removeAll(b -> b instanceof ConsumePower);`, `consPower = (ConsumePower)consume;`, `consumeBuilder.add(consume);`, `return consume;`, and explicit `T consume`.
- [x] Added RED status assertion for `N1303`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_consume_generic_result`.
- [x] Flipped `N1303` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_consume_generic_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1303` canonical and nested status are `done`.
- [x] Godot TCP non-power proof confirmed `matches=true`, `remove_power_called=false`, `add_called=true`, `consume_builder_after` appends `ConsumeItems`, `cons_power_after` preserves old `ConsumePower`, and `returned_consume` is the input consume.
- [x] Godot TCP power proof confirmed `matches=true`, `remove_power_called=true`, `add_called=true`, `consume_builder_after` appends new `ConsumePower` after power removal, `cons_power_after` is new `ConsumePower`, and `returned_consume` is the input consume.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_generic_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_generic_bridge_state`
  - Result: failed as expected because `var block_consume_generic_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_generic_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_generic_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_consume_generic`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 352.32s (0:05:52)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1303")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.generated_block_consume_generic_bridge_state({"type":"ConsumeItems","id":"items"}, false, [{"type":"ConsumeLiquid","id":"water"}], [{"type":"ConsumeLiquid","id":"water"}], {"type":"ConsumePower","id":"old-power"})`: `matches=true`, `remove_power_called=false`, `add_called=true`, `consume_builder_after=[ConsumeLiquid water, ConsumeItems items]`, `cons_power_after=old-power`, `returned_consume=items`.
  - TCP `/root/Main.generated_block_consume_generic_bridge_state({"type":"ConsumePower","id":"new-power"}, true, [{"type":"ConsumeItems","id":"items"},{"type":"ConsumePower","id":"old-power"}], [{"type":"ConsumeItems","id":"items"}], {"type":"ConsumePower","id":"old-power"})`: `matches=true`, `remove_power_called=true`, `add_called=true`, `consume_builder_after=[ConsumeItems items, ConsumePower new-power]`, `cons_power_after=new-power`, `returned_consume=new-power`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `978`
- Not done: `95`
- Source-backed remaining: `57`
- Other remaining: `38`
- Progress: `91.15%`
- Remaining: `8.85%`
- Current first numeric non-done ledger slice: `N462`
- Current next source-backed finalize slice: `N1304 Block.setupRequirements(Category,ItemStack[])`
- Current next source-backed owner: `PortGame.source_block_setup_requirements_simple_state`
