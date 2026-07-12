# N1291 Block Consume Liquid Finalize

## Scope

- Slice: `N1291`
- Title: `Generated Block consumeLiquid bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.consumeLiquid(Liquid,float)`
- Godot owner: `PortGame.source_block_consume_liquid_state`
- Generated owner: `Block.java_method_consumeLiquid_99`
- Runtime proof: `/root/Main.generated_block_consume_liquid_bridge_state`

## Source Evidence

```java
public ConsumeLiquid consumeLiquid(Liquid liquid, float amount){
    return consume(new ConsumeLiquid(liquid, amount));
}
```

## Checklist

- [x] Read design spec and SSOT entries for `N1291`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_consumeLiquid_99` preserves `new ConsumeLiquid(liquid, amount)`, `consume(new ConsumeLiquid(liquid, amount))`, explicit `liquid`, explicit `amount`, and `consume_called`.
- [x] Added RED status assertion for `N1291`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_consume_liquid_result`.
- [x] Flipped `N1291` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_consume_liquid_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1291` canonical and nested status are `done`.
- [x] Godot TCP water proof confirmed `matches=true`, `constructed_consume.type=ConsumeLiquid`, `consume_called=true`, and preserved `liquid`/`amount`.
- [x] Godot TCP slag proof confirmed `matches=true`, `constructed_consume.type=ConsumeLiquid`, `consume_called=true`, and preserved `liquid`/`amount`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_liquid_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_liquid_bridge_state`
  - Result: failed as expected because `var block_consume_liquid_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_consume_liquid_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_consume_liquid_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_consume_liquid`
  - Result: `10 passed, 4007 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 387.81s (0:06:27)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1291")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_consume_liquid_bridge_state({"id":"water","class":"Liquid"}, 0.5)`: `matches=true`, `constructed_consume.type=ConsumeLiquid`, `consume_called=true`, preserved `liquid` and `amount`.
  - TCP `/root/Main.generated_block_consume_liquid_bridge_state({"id":"slag","class":"Liquid"}, 2.25)`: `matches=true`, `constructed_consume.type=ConsumeLiquid`, `consume_called=true`, preserved `liquid` and `amount`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total source-backed slices: `1073`
- Done: `966`
- Not done: `107`
- Source-backed remaining: `69`
- Other remaining: `38`
- Progress: `90.03%`
- Remaining: `9.97%`
- Current first unresolved ledger slice by numeric order: `N1292 Block.consumeLiquids(LiquidStack...)`
- Current next owner: `PortGame.source_block_consume_liquids_state`
