# N1290 Block Remove Consumers Finalize

## Scope

- Slice: `N1290`
- Title: `Generated Block removeConsumers bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.removeConsumers(Boolf<Consume>)`
- Godot owner: `PortGame.source_block_remove_consumers_state`
- Generated owner: `Block.java_method_removeConsumers_98`
- Runtime proof: `/root/Main.generated_block_remove_consumers_bridge_state`

## Source Evidence

```java
public void removeConsumers(Boolf<Consume> b){
    consumeBuilder.removeAll(b);
    //the power was removed, unassign it
    if(!consumeBuilder.contains(c -> c instanceof ConsumePower)){
        consPower = null;
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1290`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_removeConsumers_98` preserves `consumeBuilder.removeAll(b)`, the post-remove power guard, explicit `b`, and explicit `consume_builder_contains_power_after_remove`.
- [x] Added RED status assertion for `N1290`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_remove_consumers_result`.
- [x] Flipped `N1290` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_remove_consumers_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1290` canonical and nested status are `done`.
- [x] Godot TCP kept-power proof confirmed `matches=true`, `consume_builder_remove_all_called=true`, `cons_power_cleared=false`, and preserved `b`.
- [x] Godot TCP removed-power proof confirmed `matches=true`, `consume_builder_remove_all_called=true`, `cons_power_cleared=true`, and preserved `b`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_remove_consumers_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_remove_consumers_bridge_state`
  - Result: failed as expected because `var block_remove_consumers_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_remove_consumers_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_remove_consumers_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_remove_consumers`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 392.12s (0:06:32)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1290")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_remove_consumers_bridge_state(true, {"id":"predicate-keeps-power"})`: `matches=true`, `consume_builder_remove_all_called=true`, `cons_power_cleared=false`, preserved `b`.
  - TCP `/root/Main.generated_block_remove_consumers_bridge_state(false, {"id":"predicate-removes-power"})`: `matches=true`, `consume_builder_remove_all_called=true`, `cons_power_cleared=true`, preserved `b`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total source-backed slices: `1073`
- Done: `965`
- Not done: `108`
- Source-backed remaining: `70`
- Other remaining: `38`
- Progress: `89.93%`
- Remaining: `10.07%`
- Current first unresolved ledger slice by numeric order: `N1291 Block.consumeLiquid(Liquid,float)`
- Current next owner: `PortGame.source_block_consume_liquid_state`
