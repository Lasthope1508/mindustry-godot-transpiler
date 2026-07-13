# N1338 Block Init Offset Finalize

## Scope

- Slice: `N1338`
- Title: `Generated Block init offset bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Vars source: `core/src/mindustry/Vars.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_offset_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_offset_bridge_state`

## Source Evidence

```java
offset = ((size + 1) % 2) * tilesize / 2f;
sizeOffset = -((size - 1) / 2);
```

```java
public static final int tilesize = 8;
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1338`.
- [x] Read exact upstream Java `Block.java`.
- [x] Read exact upstream Java `Vars.java` for `tilesize`.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and offset bridge.
- [x] Added RED status assertion for `N1338`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1338` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1339` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1338` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `size=1`, `tilesize=8` gives `offset=0`, `sizeOffset=0`.
- [x] Godot TCP source proof confirmed `size=2`, `tilesize=8` gives `offset=4`, `sizeOffset=0`.
- [x] Godot TCP source proof confirmed `size=3`, `tilesize=8` gives `offset=0`, `sizeOffset=-1`.
- [x] Godot TCP source proof confirmed `size=4`, `tilesize=8` gives `offset=4`, `sizeOffset=-1`.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for all offset cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_offset_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_offset_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_init_offset or generated_block_init_offset"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_init_offset`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_init_offset`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_offset`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 383.86s (0:06:23)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1338")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_init_offset_state(1, 8.0)`: `offset_after=0.0`, `size_offset_after=0`.
  - TCP `/root/Main.source_block_init_offset_state(2, 8.0)`: `offset_after=4.0`, `size_offset_after=0`.
  - TCP `/root/Main.source_block_init_offset_state(3, 8.0)`: `offset_after=0.0`, `size_offset_after=-1`.
  - TCP `/root/Main.source_block_init_offset_state(4, 8.0)`: `offset_after=4.0`, `size_offset_after=-1`.
  - TCP `/root/Main.generated_block_init_offset_bridge_state(...)`: `matches=true` for all four cases.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1016`
- Not done: `57`
- Source-backed remaining: `35`
- Active remaining: `22`
- Progress: `94.69%`
- Remaining: `5.31%`
- Current next active slice: `N1339 Generated Block init build time requirements bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_init_build_time_requirements_state`
