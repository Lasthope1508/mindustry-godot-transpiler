# N1415 BlockProducerBuild AcceptPayload Finalize

## Scope

- Slice: `N1415`
- Title: `Generated BlockProducerBuild acceptPayload bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/BlockProducer.java`
- Java method: `BlockProducerBuild.acceptPayload(Building source, Payload payload)`
- Godot owner: `PortGame.source_block_producer_build_accept_payload_state`
- Generated owner: `BlockProducer.BlockProducerBuild.acceptPayload`
- Runtime proof: `/root/Main.generated_block_producer_build_accept_payload_bridge_state`

## Source Evidence

```java
@Override
public boolean acceptPayload(Building source, Payload payload){
    return false;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1415`.
- [x] Read exact upstream Java `BlockProducer.java`.
- [x] Confirmed `PortGame.source_block_producer_build_accept_payload_state` is backed by exact source expressions.
- [x] Confirmed generated `BlockProducer.BlockProducerBuild.acceptPayload` bridge matches canonical acceptPayload state.
- [x] Added RED status assertion for `N1415`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1415` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1416` remains `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1415` canonical and nested status are `done`.
- [x] Godot TCP generated bridge proof confirmed upstream hard false payload gate with `matches=true`.
- [x] Godot TCP source proof confirmed canonical `accept_payload=false`.
- [x] Godot TCP regression proof confirmed previous `BlockProducerBuild.getMaximumAccepted()` bridge still matches.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_build_accept_payload_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_build_accept_payload_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_producer_build_accept_payload or generated_block_producer_build_accept_payload"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_producer_build_accept_payload`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_producer_build_accept_payload`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_producer_build_accept_payload`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 393.57s (0:06:33)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1415")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_producer_build_accept_payload_bridge_state("source-a", {"payload":"build"})`: `matches=true`, `accept_payload=false`.
  - TCP `/root/Main.source_block_producer_build_accept_payload_state("source-a", {"payload":"build"})`: `accept_payload=false`.
  - TCP `/root/Main.generated_block_producer_build_get_maximum_accepted_bridge_state("copper", false, [{"item":"lead","amount":2},{"item":"copper","amount":5}])`: `matches=true`, `maximum_accepted=10`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1051`
- Not done: `22`
- Source-backed remaining: `22`
- Progress: `97.95%`
- Remaining: `2.05%`
- Next slice: `N1416`
- Next slice status: `source-backed`
- Next slice title: `Generated BlockProducerBuild shouldConsume bridge state`
