# N1410 BlockProducer Icons Finalize

## Scope

- Slice: `N1410`
- Title: `Generated BlockProducer icons bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/BlockProducer.java`
- Java method: `BlockProducer.icons()`
- Godot owner: `PortGame.source_block_producer_icons_state`
- Generated owner: `BlockProducer.java_method_icons_0`
- Runtime proof: `/root/Main.generated_block_producer_icons_bridge_state`

## Source Evidence

```java
@Override
public TextureRegion[] icons(){
    return new TextureRegion[]{region, outRegion, topRegion};
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1410`.
- [x] Read exact upstream Java `BlockProducer.java`.
- [x] Confirmed `PortGame.source_block_producer_icons_state` is backed by exact source expressions.
- [x] Confirmed generated `BlockProducer.java_method_icons_0` bridges to canonical icons state.
- [x] Added RED status assertion for `N1410`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1410` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1411` remains `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1410` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed icons order `[region, outRegion, topRegion]`.
- [x] Godot TCP generated bridge proof confirmed `matches=true`.
- [x] Godot TCP regression proof confirmed previous `UnitPayload.icon()` bridge still matches.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_icons_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_icons_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_producer_icons or generated_block_producer_icons"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_producer_icons`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_producer_icons`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_producer_icons`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 397.67s (0:06:37)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1410")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_block_producer_icons_state("region-a", "out-a", "top-a")`: `icons=["region-a", "out-a", "top-a"]`, `return_expr="return new TextureRegion[]{region, outRegion, topRegion};"`.
  - TCP `/root/Main.generated_block_producer_icons_bridge_state("region-a", "out-a", "top-a")`: `matches=true`, `generated_owner="BlockProducer.java_method_icons_0"`, `result.icons=["region-a", "out-a", "top-a"]`, `canonical.icons=["region-a", "out-a", "top-a"]`.
  - TCP `/root/Main.generated_unit_payload_icon_bridge_state("full-icon-alpha")`: `matches=true`, `icon="full-icon-alpha"`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1046`
- Not done: `27`
- Source-backed remaining: `27`
- Progress: `97.48%`
- Remaining: `2.52%`
- Next slice: `N1411`
- Next slice status: `source-backed`
- Next slice title: `Generated BlockProducer drawPlanRegion bridge state`
