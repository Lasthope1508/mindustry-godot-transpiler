# N1310 Block ResearchRequirements ResearchCost Finalize

## Scope

- Slice: `N1310`
- Title: `Generated Block researchRequirements researchCost bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.researchRequirements()`
- Godot owner: `PortGame.source_block_research_requirements_research_cost_state`
- Generated owner: `Block.java_method_researchRequirements_118`
- Runtime proof: `/root/Main.generated_block_research_requirements_research_cost_bridge_state`

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
- [x] Read design spec and SSOT entries for `N1310`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_researchRequirements_118` preserves `@Override`, `public ItemStack[] researchRequirements(){`, `if(researchCost != null) return researchCost;`, `return researchCost;`, and `researchCost`.
- [x] Added RED status assertion for `N1310`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1310` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper test passed.
- [x] Focused generated bridge test passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1310` canonical and nested status are `done`.
- [x] Godot TCP non-null `researchCost` proof confirmed `returned_early=true`, `returned_requirements=researchCost`, guard expr `if(researchCost != null) return researchCost;`, and return expr `return researchCost;`.
- [x] Godot TCP null `researchCost` proof confirmed `returned_early=false` and `returned_requirements=null`, deferring next branch to later slice.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for non-null and null `researchCost`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_research_requirements_research_cost_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_research_requirements_research_cost_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_source_block_research_requirements_research_cost_state`
  - Result: `1 passed, 1544 deselected`.
- Focused generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_research_requirements_research_cost_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k test_block_research_requirements_research_cost_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_block_research_requirements_research_cost_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_research_requirements_research_cost`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 391.55s (0:06:31)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1310")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_research_requirements_research_cost_state([{"item":{"name":"copper","id":0},"amount":12}])`: `returned_early=true`, `returned_requirements` equals `researchCost`, `research_cost_guard_expr=if(researchCost != null) return researchCost;`, `return_expr=return researchCost;`.
  - TCP `/root/Main.source_block_research_requirements_research_cost_state(null)`: `returned_early=false`, `returned_requirements=null`.
  - TCP `/root/Main.generated_block_research_requirements_research_cost_bridge_state([{"item":{"name":"copper","id":0},"amount":12}])`: `matches=true`, result `returned_early=true`, result `returned_requirements` equals `researchCost`.
  - TCP `/root/Main.generated_block_research_requirements_research_cost_bridge_state(null)`: `matches=true`, result `returned_early=false`, result `returned_requirements=null`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `988`
- Not done: `85`
- Source-backed remaining: `47`
- Other remaining: `38`
- Progress: `92.08%`
- Remaining: `7.92%`
- Current next source-backed finalize slice: `N1311 Generated Block researchRequirements empty bridge state`
- Current next source-backed owner: `PortGame.source_block_research_requirements_empty_state`
