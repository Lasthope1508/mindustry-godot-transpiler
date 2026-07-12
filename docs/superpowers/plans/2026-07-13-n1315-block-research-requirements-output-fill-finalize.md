# N1315 Block ResearchRequirements Output Fill Finalize

## Scope

- Slice: `N1315`
- Title: `Generated Block researchRequirements output fill bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.researchRequirements()`
- Godot owner: `PortGame.source_block_research_requirements_output_fill_state`
- Generated owner: `Block.java_method_researchRequirements_118`
- Runtime proof: `/root/Main.generated_block_research_requirements_output_fill_bridge_state`

## Source Evidence

```java
out[i] = new ItemStack(requirements[i].item, UI.roundAmount(quantity));
```

```java
return out;
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1315`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_researchRequirements_118` preserves `out[i] = new ItemStack(requirements[i].item, UI.roundAmount(quantity));`, `requirements[i].item`, `UI.roundAmount(quantity)`, and `return out;`.
- [x] Added RED status assertion for `N1315`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1315` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1316` stayed `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper test passed.
- [x] Focused generated bridge test passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1315` canonical and nested status are `done`.
- [x] Godot TCP output fill proof confirmed output requirements and returned requirements preserve source items with rounded amounts.
- [x] Godot TCP researchCost guard proof confirmed output and returned requirements are empty when `researchCost` is non-null.
- [x] Godot TCP empty guard proof confirmed output and returned requirements are empty when `researchCostMultiplier<=0`.
- [x] Godot TCP generated bridge proof confirmed `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_research_requirements_output_fill_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_research_requirements_output_fill_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_source_block_research_requirements_output_fill_state`
  - Result: `1 passed, 1544 deselected`.
- Focused generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_research_requirements_output_fill_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k test_block_research_requirements_output_fill_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_block_research_requirements_output_fill_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_research_requirements_output_fill`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 383.61s (0:06:23)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1315")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_research_requirements_output_fill_state(null, 1.0, requirements, multipliers)`: `output_requirements=[{"item":"copper","amount":1000},{"item":"lead","amount":800},{"item":"graphite","amount":144000}]`, `returned_requirements` same value.
  - TCP `/root/Main.source_block_research_requirements_output_fill_state(researchCost, 1.0, requirements, multipliers)`: `output_requirements=[]`, `returned_requirements=[]`.
  - TCP `/root/Main.source_block_research_requirements_output_fill_state(null, 0.0, requirements, multipliers)`: `output_requirements=[]`, `returned_requirements=[]`.
  - TCP `/root/Main.generated_block_research_requirements_output_fill_bridge_state(null, 1.0, requirements, multipliers)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `993`
- Not done: `80`
- Source-backed remaining: `42`
- Other remaining: `38`
- Progress: `92.54%`
- Remaining: `7.46%`
- Current next source-backed finalize slice: `N1316 Generated Block getDependencies requirements bridge state`
- Current next source-backed owner: `PortGame.source_block_get_dependencies_requirements_state`
