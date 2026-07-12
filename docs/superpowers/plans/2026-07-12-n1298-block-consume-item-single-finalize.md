# N1298 Block Consume Item Single Finalize

## Scope

- Slice: `N1298`
- Title: `Generated Block consumeItem single bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.consumeItem(Item)`
- Godot owner: `PortGame.source_block_consume_item_single_state`
- Generated owner: `Block.java_method_consumeItem_106`
- Runtime proof: `/root/Main.generated_block_consume_item_single_bridge_state`

## Source Evidence

```java
public ConsumeItems consumeItem(Item item){
    return consumeItem(item, 1);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1298`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_consumeItem_106` preserves `public ConsumeItems consumeItem(Item item){`, `return consumeItem(item, 1);`, `consumeItem(item, 1)`, explicit `Item item`, implicit amount `1`, and `delegate_called`.
- [x] Added RED status assertion for `N1298`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_consume_item_single_result`.
- [x] Flipped `N1298` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_consume_item_single_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1298` canonical and nested status are `done`.
- [x] Godot TCP string item proof confirmed `matches=true`, `item="copper"`, `amount=1`, and `delegate_called=true`.
- [x] Godot TCP dictionary item proof confirmed `matches=true`, preserved item dictionary, `amount=1`, and `delegate_called=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_item_single_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_item_single_bridge_state`
  - Result: failed as expected because `var block_consume_item_single_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_item_single_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_item_single_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_consume_item_single`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 376.53s (0:06:16)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1298")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_consume_item_single_bridge_state("copper")`: `matches=true`, `item="copper"`, `amount=1`, `delegate_called=true`.
  - TCP `/root/Main.generated_block_consume_item_single_bridge_state({"id":"phase-fabric","localizedName":"Phase Fabric"})`: `matches=true`, preserved item dictionary, `amount=1`, `delegate_called=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total source-backed slices: `1073`
- Done: `973`
- Not done: `100`
- Source-backed remaining: `62`
- Other remaining: `38`
- Progress: `90.68%`
- Remaining: `9.32%`
- Current first unresolved ledger slice by numeric order: `N1299 Block.consumeItem(Item,int)`
- Current next owner: `PortGame.source_block_consume_item_amount_state`
