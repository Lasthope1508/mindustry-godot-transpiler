# N1359 Block Is Hidden Finalize

## Scope

- Slice: `N1359`
- Title: `Generated Block isHidden bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.isHidden()`
- Godot owner: `PortGame.source_block_is_hidden_state`
- Generated owner: `Block.java_method_isHidden_127`
- Runtime proof: `/root/Main.generated_block_is_hidden_bridge_state`

## Source Evidence

```java
@Override
public boolean isHidden(){
    return !buildVisibility.visible() && !state.rules.revealedBlocks.contains(this);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1359`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed `PortGame.source_block_is_hidden_state` is backed by exact source expressions.
- [x] Confirmed generated `Block.java_method_isHidden_127` bridges to canonical isHidden state.
- [x] Added RED status assertion for `N1359`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1359` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1359` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed hidden truth table for `!buildVisibility.visible() && !state.rules.revealedBlocks.contains(this)`.
- [x] Godot TCP generated bridge proof confirmed `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_is_hidden_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_is_hidden_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_is_hidden or generated_block_is_hidden"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_is_hidden`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_is_hidden`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_is_hidden`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 395.97s (0:06:35)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1359")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_block_is_hidden_state(false, false)`: `is_hidden=true`.
  - TCP `/root/Main.source_block_is_hidden_state(true, false)`: `is_hidden=false`.
  - TCP `/root/Main.source_block_is_hidden_state(false, true)`: `is_hidden=false`.
  - TCP `/root/Main.source_block_is_hidden_state(true, true)`: `is_hidden=false`.
  - TCP `/root/Main.generated_block_is_hidden_bridge_state(false, false)`: `matches=true`, `generated_owner=Block.java_method_isHidden_127`.
  - TCP `/root/Main.generated_block_is_hidden_bridge_state(true, false)`: `matches=true`, `generated_owner=Block.java_method_isHidden_127`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1034`
- Not done: `39`
- Source-backed remaining: `39`
- Active remaining: `4`
- Progress: `96.37%`
- Remaining: `3.63%`
- Current next active slice: `N1360 Generated Block planRotation bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_plan_rotation_state`
