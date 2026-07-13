# N1333 Block Init Light Clip Size Finalize

## Scope

- Slice: `N1333`
- Title: `Generated Block init light clip size bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_light_clip_size_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_light_clip_size_bridge_state`

## Source Evidence

```java
clipSize = Math.max(clipSize, size * tilesize);

lightClipSize = Math.max(lightClipSize, clipSize);
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1333`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and light clip size bridge.
- [x] Added RED status assertion for `N1333`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1333` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1334` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1333` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `lightClipSize=10`, `clipSize=16` assigns `lightClipSize=16`.
- [x] Godot TCP source proof confirmed existing larger `lightClipSize=24` is preserved against `clipSize=16`.
- [x] Godot TCP source proof confirmed `lightClipSize=0`, `clipSize=24` assigns `lightClipSize=24`.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for all light clip size cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_light_clip_size_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_light_clip_size_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_init_light_clip_size or generated_block_init_light_clip_size"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_init_light_clip_size`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_init_light_clip_size`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_light_clip_size`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 390.66s (0:06:30)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1333")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_init_light_clip_size_state(10.0, 16.0)`: `light_clip_size_after=16.0`.
  - TCP `/root/Main.source_block_init_light_clip_size_state(24.0, 16.0)`: `light_clip_size_after=24.0`.
  - TCP `/root/Main.source_block_init_light_clip_size_state(0.0, 24.0)`: `light_clip_size_after=24.0`.
  - TCP `/root/Main.generated_block_init_light_clip_size_bridge_state(10.0, 16.0)`: `matches=true`.
  - TCP `/root/Main.generated_block_init_light_clip_size_bridge_state(24.0, 16.0)`: `matches=true`.
  - TCP `/root/Main.generated_block_init_light_clip_size_bridge_state(0.0, 24.0)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1011`
- Not done: `62`
- Source-backed remaining: `35`
- Active remaining: `27`
- Progress: `94.22%`
- Remaining: `5.78%`
- Current next active slice: `N1334 Generated Block init liquid light bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_init_liquid_light_state`
