# N1332 Block Init Clip Size Finalize

## Scope

- Slice: `N1332`
- Title: `Generated Block init clip size bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_clip_size_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_clip_size_bridge_state`

## Source Evidence

```java
clipSize = Math.max(clipSize, size * tilesize);
```

```java
/** size of tiles in units */
public static final int tilesize = 8;
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1332`.
- [x] Read exact upstream Java `Block.java`.
- [x] Read exact upstream Java `Vars.java` for `tilesize`.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and clip size bridge.
- [x] Added RED status assertion for `N1332`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1332` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1333` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1332` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `clipSize=10`, `size=2`, `tilesize=8` assigns `clipSize=16`.
- [x] Godot TCP source proof confirmed existing larger `clipSize=24` is preserved.
- [x] Godot TCP source proof confirmed `size=3`, `tilesize=8` assigns `clipSize=24`.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for all clip size cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_clip_size_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_clip_size_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_init_clip_size or generated_block_init_clip_size"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_init_clip_size`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_init_clip_size`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_clip_size`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 401.64s (0:06:41)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1332")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_init_clip_size_state(10.0, 2, 8.0)`: `size_tilesize=16.0`, `clip_size_after=16.0`.
  - TCP `/root/Main.source_block_init_clip_size_state(24.0, 2, 8.0)`: `size_tilesize=16.0`, `clip_size_after=24.0`.
  - TCP `/root/Main.source_block_init_clip_size_state(0.0, 3, 8.0)`: `size_tilesize=24.0`, `clip_size_after=24.0`.
  - TCP `/root/Main.generated_block_init_clip_size_bridge_state(10.0, 2, 8.0)`: `matches=true`.
  - TCP `/root/Main.generated_block_init_clip_size_bridge_state(24.0, 2, 8.0)`: `matches=true`.
  - TCP `/root/Main.generated_block_init_clip_size_bridge_state(0.0, 3, 8.0)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1010`
- Not done: `63`
- Source-backed remaining: `35`
- Active remaining: `28`
- Progress: `94.13%`
- Remaining: `5.87%`
- Current next active slice: `N1333 Generated Block init light clip size bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_init_light_clip_size_state`
