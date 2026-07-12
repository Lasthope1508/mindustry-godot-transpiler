# N1306 Block Requirements Unlocked Finalize

## Scope

- Slice: `N1306`
- Title: `Generated Block requirements unlocked bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.requirements(Category,ItemStack[],boolean)`
- Godot owner: `PortGame.source_block_requirements_unlocked_state`
- Generated owner: `Block.java_method_requirements_114`
- Runtime proof: `/root/Main.generated_block_requirements_unlocked_bridge_state`

## Source Evidence

```java
public void requirements(Category cat, ItemStack[] stacks, boolean unlocked){
    requirements(cat, BuildVisibility.shown, stacks);
    this.alwaysUnlocked = unlocked;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1306`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_requirements_114` preserves `public void requirements(Category cat, ItemStack[] stacks, boolean unlocked){`, `requirements(cat, BuildVisibility.shown, stacks);`, `requirements(cat, BuildVisibility.shown, stacks)`, `this.alwaysUnlocked = unlocked;`, explicit `Category cat`, explicit `ItemStack[] stacks`, explicit `boolean unlocked`, `BuildVisibility.shown`, `delegate_called`, and `always_unlocked_after`.
- [x] Added RED status assertion for `N1306`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `block_requirements_unlocked_result`.
- [x] Flipped `N1306` status to `done` in canonical ledger and shard mirrors.
- [x] Added `block_requirements_unlocked_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1306` canonical and nested status are `done`.
- [x] Godot TCP true proof confirmed `matches=true`, `delegate_call_expr=requirements(cat, BuildVisibility.shown, stacks)`, `always_unlocked_assignment_expr=this.alwaysUnlocked = unlocked;`, `build_visibility=BuildVisibility.shown`, `unlocked=true`, `delegate_called=true`, `always_unlocked_assigned=true`, and `always_unlocked_after=true`.
- [x] Godot TCP false proof confirmed `matches=true`, `delegate_call_expr=requirements(cat, BuildVisibility.shown, stacks)`, `always_unlocked_assignment_expr=this.alwaysUnlocked = unlocked;`, `build_visibility=BuildVisibility.shown`, `unlocked=false`, `delegate_called=true`, `always_unlocked_assigned=true`, and `always_unlocked_after=false`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_requirements_unlocked_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_requirements_unlocked_bridge_state`
  - Result: failed as expected because `var block_requirements_unlocked_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_block_requirements_unlocked_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_requirements_unlocked_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_requirements_unlocked`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 383.15s (0:06:23)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1306")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.generated_block_requirements_unlocked_bridge_state({"name":"crafting","type":"Category"}, [{"item":{"name":"titanium","id":4},"amount":7},{"item":{"name":"thorium","id":5},"amount":3}], true)`: `matches=true`, `build_visibility=BuildVisibility.shown`, `unlocked=true`, `always_unlocked_after=true`, `delegate_called=true`, `always_unlocked_assigned=true`.
  - TCP `/root/Main.generated_block_requirements_unlocked_bridge_state({"name":"crafting","type":"Category"}, [{"item":{"name":"titanium","id":4},"amount":7},{"item":{"name":"thorium","id":5},"amount":3}], false)`: `matches=true`, `build_visibility=BuildVisibility.shown`, `unlocked=false`, `always_unlocked_after=false`, `delegate_called=true`, `always_unlocked_assigned=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `981`
- Not done: `92`
- Source-backed remaining: `54`
- Other remaining: `38`
- Progress: `91.43%`
- Remaining: `8.57%`
- Current first numeric non-done ledger slice: `N462`
- Current next source-backed finalize slice: `N1307 Block.requirements(Category,ItemStack[])`
- Current next source-backed owner: `PortGame.source_block_requirements_simple_state`
