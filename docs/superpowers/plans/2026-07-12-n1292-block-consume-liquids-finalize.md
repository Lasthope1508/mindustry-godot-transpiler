# N1292 Block Consume Liquids Finalize

## Scope

- Slice: `N1292`
- Title: `Generated Block consumeLiquids bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.consumeLiquids(LiquidStack...)`
- Godot owner: `PortGame.source_block_consume_liquids_state`
- Generated owner: `Block.java_method_consumeLiquids_100`
- Runtime proof: `/root/Main.generated_block_consume_liquids_bridge_state`

## Source Evidence

```java
public ConsumeLiquids consumeLiquids(LiquidStack... stacks){
    return consume(new ConsumeLiquids(stacks));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1292`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_consumeLiquids_100` preserves `new ConsumeLiquids(stacks)`, `consume(new ConsumeLiquids(stacks))`, explicit `LiquidStack... stacks`, and `consume_called`.
- [x] Added RED status assertion for `N1292`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_consume_liquids_result`.
- [x] Flipped `N1292` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_consume_liquids_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1292` canonical and nested status are `done`.
- [x] Godot TCP single-stack proof confirmed `matches=true`, `constructed_consume.type=ConsumeLiquids`, `consume_called=true`, and preserved `stacks`.
- [x] Godot TCP two-stack proof confirmed `matches=true`, `constructed_consume.type=ConsumeLiquids`, `consume_called=true`, and preserved `stacks`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_liquids_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_liquids_bridge_state`
  - Result: failed as expected because `var block_consume_liquids_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_liquids_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_liquids_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_consume_liquids`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 387.25s (0:06:27)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1292")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_consume_liquids_bridge_state([{"liquid":"water","amount":0.5}])`: `matches=true`, `constructed_consume.type=ConsumeLiquids`, `consume_called=true`, preserved `stacks`.
  - TCP `/root/Main.generated_block_consume_liquids_bridge_state([{"liquid":"water","amount":0.5},{"liquid":"slag","amount":2.25}])`: `matches=true`, `constructed_consume.type=ConsumeLiquids`, `consume_called=true`, preserved `stacks`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total source-backed slices: `1073`
- Done: `967`
- Not done: `106`
- Source-backed remaining: `68`
- Other remaining: `38`
- Progress: `90.12%`
- Remaining: `9.88%`
- Current first unresolved ledger slice by numeric order: `N1293 Block.consumePower(float)`
- Current next owner: `PortGame.source_block_consume_power_state`
