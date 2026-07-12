# N1313 Block ResearchRequirements Quantity Formula Finalize

## Scope

- Slice: `N1313`
- Title: `Generated Block researchRequirements quantity formula bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Arc source: `arc-core/src/arc/math/Mathf.java`
- Java method: `Block.researchRequirements()`
- Godot owner: `PortGame.source_block_research_requirements_quantity_formula_state`
- Generated owner: `Block.java_method_researchRequirements_118`
- Runtime proof: `/root/Main.generated_block_research_requirements_quantity_formula_bridge_state`

## Source Evidence

```java
int quantity = Mathf.round(60 * researchCostMultiplier + Mathf.pow(requirements[i].amount, 1.11f) * 20 * researchCostMultiplier * researchCostMultipliers.get(requirements[i].item, 1f), 10);
```

```java
public static int round(float value, int step){
    return (int)(value / step) * step;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1313`.
- [x] Read exact upstream Java `Block.java`.
- [x] Read exact Arc Java `Mathf.java`.
- [x] Confirmed generated `Block.java_method_researchRequirements_118` preserves `int quantity = Mathf.round(...)`, `60 * researchCostMultiplier`, `Mathf.pow(requirements[i].amount, 1.11f)`, `researchCostMultipliers.get(requirements[i].item, 1f)`, `public static int round(float value, int step){`, `return (int)(value / step) * step;`, `researchCost`, `researchCostMultiplier`, `requirements`, and `researchCostMultipliers`.
- [x] Added RED status assertion for `N1313`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1313` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1314` stayed `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper test passed.
- [x] Focused generated bridge test passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1313` canonical and nested status are `done`.
- [x] Godot TCP formula proof confirmed `quantity_values=[1090,890,370]`, `multiplier_values=[1.0,1.5,1.0]`, and source-backed `amount_power_values`.
- [x] Godot TCP researchCost guard proof confirmed no formula values are produced when `researchCost` is non-null.
- [x] Godot TCP empty guard proof confirmed no formula values are produced when `researchCostMultiplier<=0`.
- [x] Godot TCP generated bridge proof confirmed `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_research_requirements_quantity_formula_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_research_requirements_quantity_formula_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_source_block_research_requirements_quantity_formula_state`
  - Result: `1 passed, 1544 deselected`.
- Focused generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_research_requirements_quantity_formula_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k test_block_research_requirements_quantity_formula_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_block_research_requirements_quantity_formula_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_research_requirements_quantity_formula`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 397.78s (0:06:37)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1313")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_research_requirements_quantity_formula_state(null, 1.0, requirements, {"copper":1.0,"lead":1.5})`: `quantity_values=[1090,890,370]`, `multiplier_values=[1.0,1.5,1.0]`.
  - TCP `/root/Main.source_block_research_requirements_quantity_formula_state(researchCost, 1.0, requirements, multipliers)`: `quantity_values=[]`, `multiplier_values=[]`, `amount_power_values=[]`.
  - TCP `/root/Main.source_block_research_requirements_quantity_formula_state(null, 0.0, requirements, multipliers)`: `quantity_values=[]`, `multiplier_values=[]`, `amount_power_values=[]`.
  - TCP `/root/Main.generated_block_research_requirements_quantity_formula_bridge_state(null, 1.0, requirements, multipliers)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `991`
- Not done: `82`
- Source-backed remaining: `44`
- Other remaining: `38`
- Progress: `92.36%`
- Remaining: `7.64%`
- Current next source-backed finalize slice: `N1314 Generated Block researchRequirements round amount bridge state`
- Current next source-backed owner: `PortGame.source_block_research_requirements_round_amount_state`
