# N1416 BlockProducerBuild ShouldConsume Finalize

## Scope

- Slice: `N1416`
- Title: `Generated BlockProducerBuild shouldConsume bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/BlockProducer.java`
- Java method: `BlockProducerBuild.shouldConsume()`
- Godot owner: `PortGame.source_block_producer_build_should_consume_state`
- Generated owner: `BlockProducer.BlockProducerBuild.shouldConsume`
- Runtime proof: `/root/Main.generated_block_producer_build_should_consume_bridge_state`

## Source Evidence

```java
@Override
public boolean shouldConsume(){
    return super.shouldConsume() && recipe() != null;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1416`.
- [x] Read exact upstream Java `BlockProducer.java`.
- [x] Confirmed `PortGame.source_block_producer_build_should_consume_state` is backed by exact source expressions.
- [x] Confirmed generated `BlockProducer.BlockProducerBuild.shouldConsume` bridge matches canonical shouldConsume state.
- [x] Added RED status assertion for `N1416`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1416` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1417` remains `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1416` canonical and nested status are `done`.
- [x] Godot TCP generated bridge proof confirmed true path: `super_should_consume=true`, `recipe_null=false`.
- [x] Godot TCP generated bridge proof confirmed recipe-null path returns false.
- [x] Godot TCP generated bridge proof confirmed parent false path returns false.
- [x] Godot TCP source proof confirmed canonical `should_consume=true`.
- [x] Godot TCP regression proof confirmed previous `BlockProducerBuild.acceptPayload()` bridge still matches.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_build_should_consume_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_build_should_consume_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_producer_build_should_consume or generated_block_producer_build_should_consume"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_producer_build_should_consume`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_producer_build_should_consume`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_producer_build_should_consume`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 384.43s (0:06:24)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1416")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_producer_build_should_consume_bridge_state(true, false)`: `matches=true`, `should_consume=true`.
  - TCP `/root/Main.generated_block_producer_build_should_consume_bridge_state(true, true)`: `matches=true`, `should_consume=false`.
  - TCP `/root/Main.generated_block_producer_build_should_consume_bridge_state(false, false)`: `matches=true`, `should_consume=false`.
  - TCP `/root/Main.source_block_producer_build_should_consume_state(true, false)`: `should_consume=true`.
  - TCP `/root/Main.generated_block_producer_build_accept_payload_bridge_state("source-a", {"payload":"build"})`: `matches=true`, `accept_payload=false`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1052`
- Not done: `21`
- Source-backed remaining: `21`
- Progress: `98.04%`
- Remaining: `1.96%`
- Next slice: `N1417`
- Next slice status: `source-backed`
- Next slice title: `Generated BlockProducerBuild updateTile produce gate bridge state`
