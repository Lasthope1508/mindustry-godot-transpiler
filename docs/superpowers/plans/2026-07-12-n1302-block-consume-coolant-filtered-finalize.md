# N1302 Block Consume Coolant Filtered Finalize

## Scope

- Slice: `N1302`
- Title: `Generated Block consumeCoolant filtered bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.consumeCoolant(float,boolean,boolean)`
- Godot owner: `PortGame.source_block_consume_coolant_filtered_state`
- Generated owner: `Block.java_method_consumeCoolant_110`
- Runtime proof: `/root/Main.generated_block_consume_coolant_filtered_bridge_state`

## Source Evidence

```java
public ConsumeCoolant consumeCoolant(float amount, boolean allowLiquid, boolean allowGas){
    return consume(new ConsumeCoolant(amount, allowLiquid, allowGas));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1302`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_consumeCoolant_110` preserves `public ConsumeCoolant consumeCoolant(float amount, boolean allowLiquid, boolean allowGas){`, `return consume(new ConsumeCoolant(amount, allowLiquid, allowGas));`, `new ConsumeCoolant(amount, allowLiquid, allowGas)`, `consume(new ConsumeCoolant(amount, allowLiquid, allowGas))`, explicit `float amount`, explicit `boolean allowLiquid`, explicit `boolean allowGas`, and `consume_called`.
- [x] Added RED status assertion for `N1302`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_consume_coolant_filtered_result`.
- [x] Flipped `N1302` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_consume_coolant_filtered_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1302` canonical and nested status are `done`.
- [x] Godot TCP liquid-only proof confirmed `matches=true`, `amount=0.6`, `allowLiquid=true`, `allowGas=false`, `constructed_consume.type=ConsumeCoolant`, and `consume_called=true`.
- [x] Godot TCP gas-only proof confirmed `matches=true`, `amount=2.25`, `allowLiquid=false`, `allowGas=true`, `constructed_consume.type=ConsumeCoolant`, and `consume_called=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_coolant_filtered_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_coolant_filtered_bridge_state`
  - Result: failed as expected because `var block_consume_coolant_filtered_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_coolant_filtered_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_coolant_filtered_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_consume_coolant_filtered`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 342.60s (0:05:42)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1302")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_consume_coolant_filtered_bridge_state(0.6, true, false)`: `matches=true`, `amount=0.6`, `allowLiquid=true`, `allowGas=false`, `constructed_consume.type=ConsumeCoolant`, `consume_called=true`.
  - TCP `/root/Main.generated_block_consume_coolant_filtered_bridge_state(2.25, false, true)`: `matches=true`, `amount=2.25`, `allowLiquid=false`, `allowGas=true`, `constructed_consume.type=ConsumeCoolant`, `consume_called=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `977`
- Not done: `96`
- Source-backed remaining: `58`
- Other remaining: `38`
- Progress: `91.05%`
- Remaining: `8.95%`
- Current first numeric non-done ledger slice: `N462`
- Current next source-backed finalize slice: `N1303 Block.consume(Consume)`
- Current next source-backed owner: `PortGame.source_block_consume_generic_state`
