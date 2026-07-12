# N1308 Block Requirements Visible Finalize

## Scope

- Slice: `N1308`
- Title: `Generated Block requirements visible bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.requirements(Category,BuildVisibility,ItemStack[])`
- Godot owner: `PortGame.source_block_requirements_visible_state`
- Generated owner: `Block.java_method_requirements_116`
- Runtime proof: `/root/Main.generated_block_requirements_visible_bridge_state`

## Source Evidence

```java
/** Sets up requirements. Use only this method to set up requirements. */
public void requirements(Category cat, BuildVisibility visible, ItemStack[] stacks){
    this.category = cat;
    this.requirements = stacks;
    this.buildVisibility = visible;

    Arrays.sort(requirements, Structs.comparingInt(i -> i.item.id));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1308`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_requirements_116` preserves `public void requirements(Category cat, BuildVisibility visible, ItemStack[] stacks){`, `this.category = cat;`, `this.requirements = stacks;`, `this.buildVisibility = visible;`, `Arrays.sort(requirements, Structs.comparingInt(i -> i.item.id));`, explicit `Category cat`, explicit `BuildVisibility visible`, explicit `ItemStack[] stacks`, and sort key `i.item.id`.
- [x] Added RED status assertion for `N1308`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1308` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper test passed.
- [x] Focused generated bridge test passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1308` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `category_after=cat`, `build_visibility_after=BuildVisibility.shown`, `sort_called=true`, `sort_expr=Arrays.sort(requirements, Structs.comparingInt(i -> i.item.id));`, and sorted item ids `[0,4,5]`.
- [x] Godot TCP bridge proof confirmed `matches=true`, result/canonical sorted item ids `[0,4,5]`, `result.sort_called=true`, `result.build_visibility_after=BuildVisibility.shown`, and `result.category_after=cat`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_requirements_visible_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_requirements_visible_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_source_block_requirements_visible_state`
  - Result: `1 passed, 1544 deselected`.
- Focused generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_requirements_visible_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k test_block_requirements_visible_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_block_requirements_visible_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_requirements_visible`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 392.45s (0:06:32)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1308")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_requirements_visible_state({"name":"crafting","type":"Category"}, "BuildVisibility.shown", [{"item":{"name":"thorium","id":5},"amount":3},{"item":{"name":"titanium","id":4},"amount":7},{"item":{"name":"copper","id":0},"amount":12}])`: `category_after=cat`, `build_visibility_after=BuildVisibility.shown`, `sort_called=true`, `requirements_after` ids `[0,4,5]`.
  - TCP `/root/Main.generated_block_requirements_visible_bridge_state({"name":"crafting","type":"Category"}, "BuildVisibility.shown", [{"item":{"name":"thorium","id":5},"amount":3},{"item":{"name":"titanium","id":4},"amount":7},{"item":{"name":"copper","id":0},"amount":12}])`: `matches=true`, result/canonical ids `[0,4,5]`, `result.sort_called=true`, `result.build_visibility_after=BuildVisibility.shown`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `986`
- Not done: `87`
- Source-backed remaining: `49`
- Other remaining: `38`
- Progress: `91.89%`
- Remaining: `8.11%`
- Current next source-backed finalize slice: `N1309 Generated Block initBuilding default bridge state`
- Current next source-backed owner: `PortGame.source_block_init_building_default_state`
