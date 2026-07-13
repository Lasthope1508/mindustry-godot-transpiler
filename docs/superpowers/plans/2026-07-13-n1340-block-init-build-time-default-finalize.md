# N1340 Block Init Build Time Default Finalize

## Scope

- Slice: `N1340`
- Title: `Generated Block init build time default bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_build_time_default_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_build_time_default_bridge_state`

## Source Evidence

```java
if(buildTime < 0){
    buildTime = 20f;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1340`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and default buildTime bridge.
- [x] Added RED status assertion for `N1340`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1340` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1341` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1340` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed negative `buildTime=-1.0` becomes `20.0`.
- [x] Godot TCP source proof confirmed zero `buildTime=0.0` is preserved.
- [x] Godot TCP source proof confirmed positive `buildTime=12.0` is preserved.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for default and preserve cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_build_time_default_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_build_time_default_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_init_build_time_default or generated_block_init_build_time_default"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_init_build_time_default`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_init_build_time_default`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_build_time_default`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 394.71s (0:06:34)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1340")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_block_init_build_time_default_state(-1.0)`: `build_time_assigned=true`, `build_time_after=20.0`.
  - TCP `/root/Main.source_block_init_build_time_default_state(0.0)`: `build_time_assigned=false`, `build_time_after=0.0`.
  - TCP `/root/Main.source_block_init_build_time_default_state(12.0)`: `build_time_assigned=false`, `build_time_after=12.0`.
  - TCP `/root/Main.generated_block_init_build_time_default_bridge_state(...)`: `matches=true` for default and preserve cases.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1018`
- Not done: `55`
- Source-backed remaining: `35`
- Active remaining: `20`
- Progress: `94.87%`
- Remaining: `5.13%`
- Current next active slice: `N1341 Generated Block init build time multiplier bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_init_build_time_multiplier_state`
