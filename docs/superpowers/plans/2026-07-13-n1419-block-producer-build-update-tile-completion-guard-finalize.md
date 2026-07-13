# N1419 BlockProducerBuild UpdateTile Completion Guard Finalize

## Scope

- Slice: `N1419`
- Title: `Generated BlockProducerBuild updateTile completion guard bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/BlockProducer.java`
- Java method: `BlockProducerBuild.updateTile() completion guard`
- Godot owner: `PortGame.source_block_producer_build_update_tile_completion_guard_state`
- Generated owner: `BlockProducer.BlockProducerBuild.updateTile.completionGuard`
- Runtime proof: `/root/Main.generated_block_producer_build_update_tile_completion_guard_bridge_state`

## Source Evidence

```java
if(progress >= recipe.buildTime){
    consume();
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1419`.
- [x] Read exact upstream Java `BlockProducer.java`.
- [x] Confirmed `PortGame.source_block_producer_build_update_tile_completion_guard_state` is backed by exact source expressions.
- [x] Confirmed generated `BlockProducer.BlockProducerBuild.updateTile.completionGuard` bridge matches canonical completion guard state.
- [x] Added RED status assertion for `N1419`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1419` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1420` remains `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1419` canonical and nested status are `done`.
- [x] Godot TCP generated bridge proof confirmed equal threshold calls consume: `progress=120`, `recipe_build_time=120`.
- [x] Godot TCP generated bridge proof confirmed under threshold does not consume: `progress=119.5`, `recipe_build_time=120`.
- [x] Godot TCP generated bridge proof confirmed over threshold calls consume: `progress=121`, `recipe_build_time=120`.
- [x] Godot TCP source proof confirmed canonical consume gate.
- [x] Godot TCP regression proof confirmed previous `BlockProducerBuild.updateTile.progressAccumulation` bridge still matches.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_build_update_tile_completion_guard_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_build_update_tile_completion_guard_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_producer_build_update_tile_completion_guard or generated_block_producer_build_update_tile_completion_guard"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_producer_build_update_tile_completion_guard`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_producer_build_update_tile_completion_guard`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_producer_build_update_tile_completion_guard`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 395.51s (0:06:35)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1419")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_producer_build_update_tile_completion_guard_bridge_state(120.0, 120.0)`: `matches=true`, `completion_guard=true`, `consume_called=true`.
  - TCP `/root/Main.generated_block_producer_build_update_tile_completion_guard_bridge_state(119.5, 120.0)`: `matches=true`, `completion_guard=false`, `consume_called=false`.
  - TCP `/root/Main.generated_block_producer_build_update_tile_completion_guard_bridge_state(121.0, 120.0)`: `matches=true`, `completion_guard=true`, `consume_called=true`.
  - TCP `/root/Main.source_block_producer_build_update_tile_completion_guard_state(120.0, 120.0)`: `completion_guard=true`, `consume_called=true`.
  - TCP `/root/Main.generated_block_producer_build_update_tile_progress_accumulation_bridge_state(true, 2.0, 3.0, 4.0)`: `matches=true`, `progress_after=14`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1055`
- Not done: `18`
- Source-backed remaining: `18`
- Progress: `98.32%`
- Remaining: `1.68%`
- Next slice: `N1420`
- Next slice status: `source-backed`
- Next slice title: `Generated BlockProducerBuild updateTile payload creation bridge state`
