# N1314 Block ResearchRequirements Round Amount Finalize

## Scope

- Slice: `N1314`
- Title: `Generated Block researchRequirements round amount bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- UI source: `core/src/mindustry/core/UI.java`
- Arc source: `arc-core/src/arc/math/Mathf.java`
- Java method: `Block.researchRequirements()`
- Godot owner: `PortGame.source_block_research_requirements_round_amount_state`
- Generated owner: `Block.java_method_researchRequirements_118`
- Runtime proof: `/root/Main.generated_block_research_requirements_round_amount_bridge_state`

## Source Evidence

```java
out[i] = new ItemStack(requirements[i].item, UI.roundAmount(quantity));
```

```java
public static int roundAmount(int number){
    if(number >= 1_000_000_000){
        return Mathf.round(number, 100_000_000);
    }else if(number >= 1_000_000){
        return Mathf.round(number, 100_000);
    }else if(number >= 10_000){
        return Mathf.round(number, 1000);
    }else if(number >= 1000){
        return Mathf.round(number, 100);
    }else if(number >= 100){
        return Mathf.round(number, 100);
    }else if(number >= 10){
        return Mathf.round(number, 10);
    }else{
        return number;
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1314`.
- [x] Read exact upstream Java `Block.java`.
- [x] Read exact upstream Java `UI.java`.
- [x] Read exact Arc Java `Mathf.java`.
- [x] Confirmed generated `Block.java_method_researchRequirements_118` preserves `out[i] = new ItemStack(requirements[i].item, UI.roundAmount(quantity));`, `UI.roundAmount(quantity)`, `public static int roundAmount(int number){`, threshold guards, `public static int round(int value, int step){`, and `return (value / step) * step;`.
- [x] Added RED status assertion for `N1314`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1314` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1315` stayed `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper test passed.
- [x] Focused generated bridge test passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1314` canonical and nested status are `done`.
- [x] Godot TCP round amount proof confirmed `quantity_values=[1090,890,144810,7096320,15171551560]` and `rounded_amount_values=[1000,800,144000,7000000,15100000000]`.
- [x] Godot TCP researchCost guard proof confirmed no quantity or rounded amount values are produced when `researchCost` is non-null.
- [x] Godot TCP empty guard proof confirmed no quantity or rounded amount values are produced when `researchCostMultiplier<=0`.
- [x] Godot TCP generated bridge proof confirmed `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_research_requirements_round_amount_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_research_requirements_round_amount_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_source_block_research_requirements_round_amount_state`
  - Result: `1 passed, 1544 deselected`.
- Focused generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_research_requirements_round_amount_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k test_block_research_requirements_round_amount_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_block_research_requirements_round_amount_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_research_requirements_round_amount`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 396.29s (0:06:36)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1314")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_research_requirements_round_amount_state(null, 1.0, requirements, multipliers)`: `quantity_values=[1090,890,144810,7096320,15171551560]`, `rounded_amount_values=[1000,800,144000,7000000,15100000000]`.
  - TCP `/root/Main.source_block_research_requirements_round_amount_state(researchCost, 1.0, requirements, multipliers)`: `quantity_values=[]`, `rounded_amount_values=[]`.
  - TCP `/root/Main.source_block_research_requirements_round_amount_state(null, 0.0, requirements, multipliers)`: `quantity_values=[]`, `rounded_amount_values=[]`.
  - TCP `/root/Main.generated_block_research_requirements_round_amount_bridge_state(null, 1.0, requirements, multipliers)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `992`
- Not done: `81`
- Source-backed remaining: `43`
- Other remaining: `38`
- Progress: `92.45%`
- Remaining: `7.55%`
- Current next source-backed finalize slice: `N1315 Generated Block researchRequirements output fill bridge state`
- Current next source-backed owner: `PortGame.source_block_research_requirements_output_fill_state`
