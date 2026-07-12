# N1307 Block Requirements Simple Finalize

## Scope

- Slice: `N1307`
- Title: `Generated Block requirements simple bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.requirements(Category,ItemStack[])`
- Godot owner: `PortGame.source_block_requirements_simple_state`
- Generated owner: `Block.java_method_requirements_115`
- Runtime proof: `/root/Main.generated_block_requirements_simple_bridge_state`

## Source Evidence

```java
public void requirements(Category cat, ItemStack[] stacks){
    requirements(cat, BuildVisibility.shown, stacks);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1307`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_requirements_115` preserves `public void requirements(Category cat, ItemStack[] stacks){`, `requirements(cat, BuildVisibility.shown, stacks);`, `requirements(cat, BuildVisibility.shown, stacks)`, explicit `Category cat`, explicit `ItemStack[] stacks`, `BuildVisibility.shown`, and `delegate_called`.
- [x] Added RED status assertion for `N1307`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1307` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper test passed.
- [x] Focused generated bridge test passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1307` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `delegate_called=true`, `delegate_call_expr=requirements(cat, BuildVisibility.shown, stacks)`, and `build_visibility=BuildVisibility.shown`.
- [x] Godot TCP bridge proof confirmed `matches=true`, result/canonical `delegate_called=true`, result/canonical `build_visibility=BuildVisibility.shown`, and result `delegate_call_expr=requirements(cat, BuildVisibility.shown, stacks)`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_requirements_simple_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_requirements_simple_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_source_block_requirements_simple_state`
  - Result: `1 passed, 1544 deselected`.
- Focused generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_requirements_simple_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k test_block_requirements_simple_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_block_requirements_simple_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_requirements_simple`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 395.88s (0:06:35)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1307")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_requirements_simple_state({"name":"crafting","type":"Category"}, [{"item":{"name":"thorium","id":5},"amount":3},{"item":{"name":"titanium","id":4},"amount":7}])`: `delegate_called=true`, `build_visibility=BuildVisibility.shown`, `delegate_call_expr=requirements(cat, BuildVisibility.shown, stacks)`.
  - TCP `/root/Main.generated_block_requirements_simple_bridge_state({"name":"crafting","type":"Category"}, [{"item":{"name":"thorium","id":5},"amount":3},{"item":{"name":"titanium","id":4},"amount":7}])`: `matches=true`, `result.delegate_called=true`, `result.build_visibility=BuildVisibility.shown`, `result.delegate_call_expr=requirements(cat, BuildVisibility.shown, stacks)`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `985`
- Not done: `88`
- Source-backed remaining: `50`
- Other remaining: `38`
- Progress: `91.80%`
- Remaining: `8.20%`
- Current next source-backed finalize slice: `N1308 Generated Block requirements visible bridge state`
- Current next source-backed owner: `PortGame.source_block_requirements_visible_state`
