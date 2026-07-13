# N1363 Block Sense LAccess Finalize

## Scope

- Slice: `N1363`
- Title: `Generated Block sense LAccess bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.sense(LAccess sensor)`
- Godot owner: `PortGame.source_block_sense_laccess_state`
- Generated owner: `Block.java_method_sense_132`
- Runtime proof: `/root/Main.generated_block_sense_laccess_bridge_state`

## Source Evidence

```java
@Override
public double sense(LAccess sensor){
    return switch(sensor){
        case color -> mapColor.toDoubleBits();
        case health, maxHealth -> health;
        case solid -> solid ? 1 : 0;
        case size -> size;
        case itemCapacity -> itemCapacity;
        case liquidCapacity -> liquidCapacity;
        case powerCapacity -> consPower != null && consPower.buffered ? consPower.capacity : 0f;
        case id -> getLogicId();
        default -> Double.NaN;
    };
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1363`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed `PortGame.source_block_sense_laccess_state` is backed by exact source expressions.
- [x] Confirmed generated `Block.java_method_sense_132` bridges to canonical sense LAccess state.
- [x] Added RED status assertion for `N1363`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1363` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1363` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed LAccess switch cases and `Double.NaN` default.
- [x] Godot TCP generated bridge proof confirmed `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_sense_laccess_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_sense_laccess_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_sense_laccess or generated_block_sense_laccess"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_sense_laccess`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_sense_laccess`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_sense_laccess`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 404.64s (0:06:44)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1363")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_block_sense_laccess_state("color", 123.5, 456.0, true, 3, 40, 60.5, true, true, 900.25, 77)`: `sense_value=123.5`.
  - TCP `/root/Main.source_block_sense_laccess_state("health", 123.5, 456.0, true, 3, 40, 60.5, true, true, 900.25, 77)`: `sense_value=456`.
  - TCP `/root/Main.source_block_sense_laccess_state("maxHealth", 123.5, 456.0, true, 3, 40, 60.5, true, true, 900.25, 77)`: `sense_value=456`.
  - TCP `/root/Main.source_block_sense_laccess_state("solid", 123.5, 456.0, true, 3, 40, 60.5, true, true, 900.25, 77)`: `sense_value=1`.
  - TCP `/root/Main.source_block_sense_laccess_state("size", 123.5, 456.0, true, 3, 40, 60.5, true, true, 900.25, 77)`: `sense_value=3`.
  - TCP `/root/Main.source_block_sense_laccess_state("itemCapacity", 123.5, 456.0, true, 3, 40, 60.5, true, true, 900.25, 77)`: `sense_value=40`.
  - TCP `/root/Main.source_block_sense_laccess_state("liquidCapacity", 123.5, 456.0, true, 3, 40, 60.5, true, true, 900.25, 77)`: `sense_value=60.5`.
  - TCP `/root/Main.source_block_sense_laccess_state("powerCapacity", 123.5, 456.0, true, 3, 40, 60.5, true, true, 900.25, 77)`: `sense_value=900.25`.
  - TCP `/root/Main.source_block_sense_laccess_state("powerCapacity", 123.5, 456.0, true, 3, 40, 60.5, true, false, 900.25, 77)`: `sense_value=0`.
  - TCP `/root/Main.source_block_sense_laccess_state("id", 123.5, 456.0, true, 3, 40, 60.5, true, true, 900.25, 77)`: `sense_value=77`.
  - TCP `/root/Main.source_block_sense_laccess_state("unknown", 123.5, 456.0, true, 3, 40, 60.5, true, true, 900.25, 77)`: `sense_value=null`, `sense_value_is_nan=true`.
  - TCP `/root/Main.generated_block_sense_laccess_bridge_state("powerCapacity", 123.5, 456.0, true, 3, 40, 60.5, true, true, 900.25, 77)`: `matches=true`, `generated_owner=Block.java_method_sense_132`.
  - TCP `/root/Main.generated_block_sense_laccess_bridge_state("unknown", 123.5, 456.0, true, 3, 40, 60.5, true, true, 900.25, 77)`: `matches=true`, `generated_owner=Block.java_method_sense_132`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1038`
- Not done: `35`
- Source-backed remaining: `35`
- Active remaining: `0`
- Progress: `96.74%`
- Remaining: `3.26%`
- Current next active slice: none
- Current next active status: none
- Current next active owner: none
