# N1413 BlockProducerBuild AcceptItem Finalize

## Scope

- Slice: `N1413`
- Title: `Generated BlockProducerBuild acceptItem bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/BlockProducer.java`
- Java method: `BlockProducerBuild.acceptItem(Building source, Item item)`
- Godot owner: `PortGame.source_block_producer_build_accept_item_state`
- Generated owner: `BlockProducer.BlockProducerBuild.acceptItem`
- Runtime proof: `/root/Main.generated_block_producer_build_accept_item_bridge_state`

## Source Evidence

```java
public abstract class BlockProducerBuild extends PayloadBlockBuild<BuildPayload>{
    public float progress, time, heat;

    public abstract @Nullable Block recipe();

    @Override
    public boolean acceptItem(Building source, Item item){
        return items.get(item) < getMaximumAccepted(item);
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1413`.
- [x] Read exact upstream Java `BlockProducer.java`.
- [x] Confirmed `PortGame.source_block_producer_build_accept_item_state` is backed by exact source expressions.
- [x] Confirmed generated `BlockProducer.BlockProducerBuild.acceptItem` bridge matches canonical acceptItem state.
- [x] Added RED status assertion for `N1413`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1413` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1414` remains `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1413` canonical and nested status are `done`.
- [x] Godot TCP generated bridge proof confirmed `3 < 4` accepts and `4 < 4` rejects with `matches=true`.
- [x] Godot TCP source proof confirmed canonical `accept_item=true` for `3 < 4`.
- [x] Godot TCP regression proof confirmed previous `BlockProducer.setBars()` bridge still matches.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_build_accept_item_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_build_accept_item_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_producer_build_accept_item or generated_block_producer_build_accept_item"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_producer_build_accept_item`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_producer_build_accept_item`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_producer_build_accept_item`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 401.44s (0:06:41)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1413")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_block_producer_build_accept_item_bridge_state("source-a", "copper", 3, 4)`: `matches=true`, `result.accept_item=true`.
  - TCP `/root/Main.generated_block_producer_build_accept_item_bridge_state("source-a", "copper", 4, 4)`: `matches=true`, `result.accept_item=false`.
  - TCP `/root/Main.source_block_producer_build_accept_item_state("source-a", "copper", 3, 4)`: `accept_item=true`.
  - TCP `/root/Main.generated_block_producer_set_bars_bridge_state(false, 30.0, 120.0)`: `matches=true`, `progress_bar_fraction=0.25`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1049`
- Not done: `24`
- Source-backed remaining: `24`
- Progress: `97.76%`
- Remaining: `2.24%`
- Next slice: `N1414`
- Next slice status: `source-backed`
- Next slice title: `Generated BlockProducerBuild getMaximumAccepted bridge state`
