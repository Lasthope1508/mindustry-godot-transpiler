# N1341 Block Init Build Time Multiplier Finalize

## Scope

- Slice: `N1341`
- Title: `Generated Block init build time multiplier bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_build_time_multiplier_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_build_time_multiplier_bridge_state`

## Source Evidence

```java
public float buildCostMultiplier = 1f;
```

```java
buildTime *= buildCostMultiplier;
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1341`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and buildTime multiplier bridge.
- [x] Added RED status assertion for `N1341`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1341` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1342` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1341` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed identity multiplier `20.0 * 1.0 = 20.0`.
- [x] Godot TCP source proof confirmed boost multiplier `20.0 * 1.5 = 30.0`.
- [x] Godot TCP source proof confirmed zero multiplier `20.0 * 0.0 = 0.0`.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for boost and zero cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_build_time_multiplier_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_build_time_multiplier_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_init_build_time_multiplier or generated_block_init_build_time_multiplier"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_init_build_time_multiplier`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_init_build_time_multiplier`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_build_time_multiplier`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 392.45s (0:06:32)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1341")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_block_init_build_time_multiplier_state(20.0, 1.0)`: `build_time_after=20.0`.
  - TCP `/root/Main.source_block_init_build_time_multiplier_state(20.0, 1.5)`: `build_time_after=30.0`.
  - TCP `/root/Main.source_block_init_build_time_multiplier_state(20.0, 0.0)`: `build_time_after=0.0`.
  - TCP `/root/Main.generated_block_init_build_time_multiplier_bridge_state(...)`: `matches=true` for boost and zero cases.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1019`
- Not done: `54`
- Source-backed remaining: `35`
- Active remaining: `19`
- Progress: `94.97%`
- Remaining: `5.03%`
- Current next active slice: `N1342 Generated Block init consumer arrays bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_init_consumer_arrays_state`
