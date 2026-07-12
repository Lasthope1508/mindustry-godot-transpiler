# N1311 Block ResearchRequirements Empty Finalize

## Scope

- Slice: `N1311`
- Title: `Generated Block researchRequirements empty bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.researchRequirements()`
- Godot owner: `PortGame.source_block_research_requirements_empty_state`
- Generated owner: `Block.java_method_researchRequirements_118`
- Runtime proof: `/root/Main.generated_block_research_requirements_empty_bridge_state`

## Source Evidence

```java
@Override
public ItemStack[] researchRequirements(){
    if(researchCost != null) return researchCost;
    if(researchCostMultiplier <= 0f) return ItemStack.empty;
    ...
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1311`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_researchRequirements_118` preserves `@Override`, `public ItemStack[] researchRequirements(){`, `if(researchCost != null) return researchCost;`, `if(researchCostMultiplier <= 0f) return ItemStack.empty;`, `return ItemStack.empty;`, `researchCost`, and `researchCostMultiplier`.
- [x] Added RED status assertion for `N1311`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1311` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper test passed.
- [x] Focused generated bridge test passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1311` canonical and nested status are `done`.
- [x] Godot TCP empty proof confirmed `researchCost=null`, `researchCostMultiplier<=0`, `returned_empty=true`, `returned_requirements=ItemStack.empty`, empty guard expr, and empty return expr.
- [x] Godot TCP non-null researchCost proof confirmed researchCost guard wins, `returned_empty=false`, and passed researchCost is preserved.
- [x] Godot TCP defer proof confirmed `researchCost=null`, positive multiplier, `returned_empty=false`, and `returned_requirements=null` for later loop slice.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for empty, non-null researchCost, and defer cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_research_requirements_empty_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_research_requirements_empty_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_source_block_research_requirements_empty_state`
  - Result: `1 passed, 1544 deselected`.
- Focused generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_research_requirements_empty_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k test_block_research_requirements_empty_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_block_research_requirements_empty_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_research_requirements_empty`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 392.41s (0:06:32)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1311")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_research_requirements_empty_state(null, 0.0)`: `returned_empty=true`, `returned_requirements=ItemStack.empty`, `empty_guard_expr=if(researchCostMultiplier <= 0f) return ItemStack.empty;`, `empty_return_expr=return ItemStack.empty;`.
  - TCP `/root/Main.generated_block_research_requirements_empty_bridge_state(null, -0.25)`: `matches=true`, result `returned_empty=true`, result `returned_requirements=ItemStack.empty`.
  - TCP `/root/Main.source_block_research_requirements_empty_state([{"item":{"name":"lead","id":1},"amount":5}], 0.0)`: `returned_empty=false`, `returned_requirements` equals researchCost.
  - TCP `/root/Main.generated_block_research_requirements_empty_bridge_state(null, 1.0)`: `matches=true`, result `returned_empty=false`, result `returned_requirements=null`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `989`
- Not done: `84`
- Source-backed remaining: `46`
- Other remaining: `38`
- Progress: `92.17%`
- Remaining: `7.83%`
- Current next source-backed finalize slice: `N1312 Generated Block researchRequirements loop shape bridge state`
- Current next source-backed owner: `PortGame.source_block_research_requirements_loop_shape_state`
