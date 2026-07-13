# N1414 BlockProducerBuild GetMaximumAccepted Finalize

## Scope

- Slice: `N1414`
- Title: `Generated BlockProducerBuild getMaximumAccepted bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/BlockProducer.java`
- Java method: `BlockProducerBuild.getMaximumAccepted(Item item)`
- Godot owner: `PortGame.source_block_producer_build_get_maximum_accepted_state`
- Generated owner: `BlockProducer.BlockProducerBuild.getMaximumAccepted`
- Runtime proof: `/root/Main.generated_block_producer_build_get_maximum_accepted_bridge_state`

## Source Evidence

```java
@Override
public int getMaximumAccepted(Item item){
    if(recipe() == null) return 0;
    for(ItemStack stack : recipe().requirements){
        if(stack.item == item) return stack.amount * 2;
    }
    return 0;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1414`.
- [x] Read exact upstream Java `BlockProducer.java`.
- [x] Confirmed `PortGame.source_block_producer_build_get_maximum_accepted_state` is backed by exact source expressions.
- [x] Confirmed generated `BlockProducer.BlockProducerBuild.getMaximumAccepted` bridge matches canonical getMaximumAccepted state.
- [x] Added RED status assertion for `N1414`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1414` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1415` remains `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1414` canonical and nested status are `done`.
- [x] Godot TCP generated bridge proof confirmed recipe-null returns `0`.
- [x] Godot TCP generated bridge proof confirmed matching `copper` requirement amount `5` returns `10`.
- [x] Godot TCP generated bridge proof confirmed no-match `silicon` returns `0`.
- [x] Godot TCP source proof confirmed canonical matched requirement and maximum.
- [x] Godot TCP regression proof confirmed previous `BlockProducerBuild.acceptItem()` bridge still matches.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_build_get_maximum_accepted_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_build_get_maximum_accepted_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_producer_build_get_maximum_accepted or generated_block_producer_build_get_maximum_accepted"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_producer_build_get_maximum_accepted`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_producer_build_get_maximum_accepted`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_producer_build_get_maximum_accepted`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 385.78s (0:06:25)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1414")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_producer_build_get_maximum_accepted_bridge_state("copper", true, [{"item":"lead","amount":2},{"item":"copper","amount":5}])`: `matches=true`, `maximum_accepted=0`.
  - TCP `/root/Main.generated_block_producer_build_get_maximum_accepted_bridge_state("copper", false, [{"item":"lead","amount":2},{"item":"copper","amount":5}])`: `matches=true`, `matched_requirement.item="copper"`, `maximum_accepted=10`.
  - TCP `/root/Main.generated_block_producer_build_get_maximum_accepted_bridge_state("silicon", false, [{"item":"lead","amount":2},{"item":"copper","amount":5}])`: `matches=true`, `matched_requirement=null`, `maximum_accepted=0`.
  - TCP `/root/Main.source_block_producer_build_get_maximum_accepted_state("copper", false, [{"item":"lead","amount":2},{"item":"copper","amount":5}])`: `matched_requirement.item="copper"`, `maximum_accepted=10`.
  - TCP `/root/Main.generated_block_producer_build_accept_item_bridge_state("source-a", "copper", 3, 4)`: `matches=true`, `accept_item=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1050`
- Not done: `23`
- Source-backed remaining: `23`
- Progress: `97.86%`
- Remaining: `2.14%`
- Next slice: `N1415`
- Next slice status: `source-backed`
- Next slice title: `Generated BlockProducerBuild acceptPayload bridge state`
