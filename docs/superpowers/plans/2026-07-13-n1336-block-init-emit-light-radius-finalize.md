# N1336 Block Init Emit Light Radius Finalize

## Scope

- Slice: `N1336`
- Title: `Generated Block init emit light radius bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_emit_light_radius_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_emit_light_radius_bridge_state`

## Source Evidence

```java
if(emitLight){
    lightClipSize = Math.max(lightClipSize, lightRadius * 2f);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1336`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and emit-light-radius bridge.
- [x] Added RED status assertion for `N1336`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1336` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1337` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1336` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `emitLight=true`, `lightClipSize=10`, `lightRadius=8` clamps to `16`.
- [x] Godot TCP source proof confirmed existing larger `lightClipSize=30` is preserved.
- [x] Godot TCP source proof confirmed `emitLight=false` preserves `lightClipSize` even when `lightRadius * 2f` is larger.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for all emit-light-radius cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_emit_light_radius_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_emit_light_radius_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_init_emit_light_radius or generated_block_init_emit_light_radius"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_init_emit_light_radius`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_init_emit_light_radius`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_emit_light_radius`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 382.79s (0:06:22)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1336")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_init_emit_light_radius_state(true, 10.0, 8.0)`: `light_radius_clip_size=16.0`, `light_clip_size_after=16.0`.
  - TCP `/root/Main.source_block_init_emit_light_radius_state(true, 30.0, 8.0)`: `light_radius_clip_size=16.0`, `light_clip_size_after=30.0`.
  - TCP `/root/Main.source_block_init_emit_light_radius_state(false, 10.0, 20.0)`: `light_radius_clip_size=40.0`, `light_clip_size_after=10.0`.
  - TCP `/root/Main.generated_block_init_emit_light_radius_bridge_state(...)`: `matches=true` for all three cases.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1014`
- Not done: `59`
- Source-backed remaining: `35`
- Active remaining: `24`
- Progress: `94.50%`
- Remaining: `5.50%`
- Current next active slice: `N1337 Generated Block init accepts items bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_init_accepts_items_state`
