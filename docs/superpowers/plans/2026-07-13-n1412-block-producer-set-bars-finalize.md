# N1412 BlockProducer SetBars Finalize

## Scope

- Slice: `N1412`
- Title: `Generated BlockProducer setBars bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/BlockProducer.java`
- Java method: `BlockProducer.setBars()`
- Godot owner: `PortGame.source_block_producer_set_bars_state`
- Generated owner: `BlockProducer.java_method_setBars_2`
- Runtime proof: `/root/Main.generated_block_producer_set_bars_bridge_state`

## Source Evidence

```java
@Override
public void setBars(){
    super.setBars();

    addBar("progress", (BlockProducerBuild entity) -> new Bar("bar.progress", Pal.ammo, () -> entity.recipe() == null ? 0f : (entity.progress / entity.recipe().buildTime)));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1412`.
- [x] Read exact upstream Java `BlockProducer.java`.
- [x] Confirmed `PortGame.source_block_producer_set_bars_state` is backed by exact source expressions.
- [x] Confirmed generated `BlockProducer.java_method_setBars_2` bridges to canonical setBars state.
- [x] Added RED status assertion for `N1412`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1412` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1413` remains `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1412` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed active recipe progress fraction `30 / 120 = 0.25`.
- [x] Godot TCP generated bridge proof confirmed active and recipe-null cases with `matches=true`.
- [x] Godot TCP regression proof confirmed previous `BlockProducer.drawPlanRegion()` bridge still matches.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_set_bars_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_producer_set_bars_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_producer_set_bars or generated_block_producer_set_bars"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_producer_set_bars`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_producer_set_bars`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_producer_set_bars`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 393.12s (0:06:33)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1412")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_block_producer_set_bars_state(false, 30.0, 120.0)`: `progress_bar_fraction=0.25`, `super_set_bars_called=true`, `progress_bar_call.color="Pal.ammo"`, `progress_bar_call.bar_text="bar.progress"`.
  - TCP `/root/Main.generated_block_producer_set_bars_bridge_state(false, 30.0, 120.0)`: `matches=true`, `progress_bar_fraction=0.25`.
  - TCP `/root/Main.generated_block_producer_set_bars_bridge_state(true, 30.0, 120.0)`: `matches=true`, `progress_bar_fraction=0`.
  - TCP `/root/Main.generated_block_producer_draw_plan_region_bridge_state("region-a", "out-a", "top-a", 12.5, 34.25, 2.0)`: `matches=true`, `out_region_rotation=180`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1048`
- Not done: `25`
- Source-backed remaining: `25`
- Progress: `97.67%`
- Remaining: `2.33%`
- Next slice: `N1413`
- Next slice status: `source-backed`
- Next slice title: `Generated BlockProducerBuild acceptItem bridge state`
