# N1354 Block Check Content Array Capacity Finalize

## Scope

- Slice: `N1354`
- Title: `Generated Block checkContentArrayCapacity filter resize bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.checkContentArrayCapacity(int,int)`
- Godot owner: `PortGame.source_block_check_content_array_capacity_state`
- Generated owner: `Block.java_method_checkContentArrayCapacity_125`
- Runtime proof: `/root/Main.generated_block_check_content_array_capacity_bridge_state`

## Source Evidence

```java
public void checkContentArrayCapacity(int items, int liquids){
    if(liquidFilter.length != liquids) liquidFilter = Arrays.copyOf(liquidFilter, liquids);
    if(itemFilter.length != items) itemFilter = Arrays.copyOf(itemFilter, items);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1354`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed `PortGame.source_block_check_content_array_capacity_state` is backed by exact source expressions.
- [x] Confirmed generated `Block.java_method_checkContentArrayCapacity_125` bridges to canonical resize state.
- [x] Added RED status assertion for `N1354`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1354` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1354` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed grow preserves prior booleans and appends `false`.
- [x] Godot TCP source proof confirmed shrink truncates prior booleans.
- [x] Godot TCP source proof confirmed same-size keeps prior filters.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for grow and shrink.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_check_content_array_capacity_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_check_content_array_capacity_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_check_content_array_capacity or generated_block_check_content_array_capacity"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_check_content_array_capacity`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_check_content_array_capacity`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_check_content_array_capacity`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 393.71s (0:06:33)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1354")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_block_check_content_array_capacity_state([true,false,true], [false,true], 5, 4)`: item `[true,false,true,false,false]`, liquid `[false,true,false,false]`.
  - TCP `/root/Main.source_block_check_content_array_capacity_state([true,false,true], [false,true], 2, 1)`: item `[true,false]`, liquid `[false]`.
  - TCP `/root/Main.source_block_check_content_array_capacity_state([true,false,true], [false,true], 3, 2)`: item `[true,false,true]`, liquid `[false,true]`.
  - TCP `/root/Main.generated_block_check_content_array_capacity_bridge_state([true,false,true], [false,true], 5, 4)`: `matches=true`.
  - TCP `/root/Main.generated_block_check_content_array_capacity_bridge_state([true,false,true], [false,true], 2, 1)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1029`
- Not done: `44`
- Source-backed remaining: `35`
- Active remaining: `9`
- Progress: `95.90%`
- Remaining: `4.10%`
- Current next active slice: `N1355 Generated Block load base regions bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_load_base_regions_state`
