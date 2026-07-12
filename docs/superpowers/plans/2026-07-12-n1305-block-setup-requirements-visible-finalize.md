# N1305 Block Setup Requirements Visible Finalize

## Scope

- Slice: `N1305`
- Title: `Generated Block setupRequirements visible bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.setupRequirements(Category,BuildVisibility,ItemStack[])`
- Godot owner: `PortGame.source_block_setup_requirements_visible_state`
- Generated owner: `Block.java_method_setupRequirements_113`
- Runtime proof: `/root/Main.generated_block_setup_requirements_visible_bridge_state`

## Source Evidence

```java
public void setupRequirements(Category cat, BuildVisibility visible, ItemStack[] stacks){
    requirements(cat, visible, stacks);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1305`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_setupRequirements_113` preserves `public void setupRequirements(Category cat, BuildVisibility visible, ItemStack[] stacks){`, `requirements(cat, visible, stacks);`, `requirements(cat, visible, stacks)`, explicit `Category cat`, explicit `BuildVisibility visible`, explicit `ItemStack[] stacks`, and `delegate_called`.
- [x] Added RED status assertion for `N1305`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_setup_requirements_visible_result`.
- [x] Flipped `N1305` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_setup_requirements_visible_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1305` canonical and nested status are `done`.
- [x] Godot TCP proof confirmed `matches=true`, `delegate_call_expr=requirements(cat, visible, stacks)`, `cat` preserved, `visible` preserved, `stacks` preserved, and `delegate_called=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_setup_requirements_visible_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_setup_requirements_visible_bridge_state`
  - Result: failed as expected because `var block_setup_requirements_visible_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_setup_requirements_visible_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_setup_requirements_visible_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_setup_requirements_visible`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 383.76s (0:06:23)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1305")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.generated_block_setup_requirements_visible_bridge_state({"name":"distribution","type":"Category"}, {"name":"shown","type":"BuildVisibility"}, [{"item":{"name":"silicon","id":2},"amount":4},{"item":{"name":"graphite","id":3},"amount":9}])`: `matches=true`, `delegate_call_expr=requirements(cat, visible, stacks)`, `cat=distribution`, `visible=shown`, `stacks=[silicon:4, graphite:9]`, `delegate_called=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `980`
- Not done: `93`
- Source-backed remaining: `55`
- Other remaining: `38`
- Progress: `91.33%`
- Remaining: `8.67%`
- Current first numeric non-done ledger slice: `N462`
- Current next source-backed finalize slice: `N1306 Block.requirements(Category,ItemStack[],boolean)`
- Current next source-backed owner: `PortGame.source_block_requirements_unlocked_state`
