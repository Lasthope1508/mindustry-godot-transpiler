# N1350 Block Reinitialize Consumers Arrays Finalize

## Scope

- Slice: `N1350`
- Title: `Generated Block reinitializeConsumers consumer arrays bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Consume source: `core/src/mindustry/world/consumers/Consume.java`
- Java method: `Block.reinitializeConsumers()`
- Godot owner: `PortGame.source_block_reinitialize_consumers_arrays_state`
- Generated owner: `Block.java_method_reinitializeConsumers_124`
- Runtime proof: `/root/Main.generated_block_reinitialize_consumers_arrays_bridge_state`

## Source Evidence

```java
public void reinitializeConsumers(){
    consumers = consumeBuilder.toArray(Consume.class);
    consPower = (ConsumePower)Structs.find(consumers, c -> c instanceof ConsumePower);
    optionalConsumers = consumeBuilder.select(consume -> consume.optional && !consume.ignore()).toArray(Consume.class);
    nonOptionalConsumers = consumeBuilder.select(consume -> !consume.optional && !consume.ignore()).toArray(Consume.class);
    updateConsumers = consumeBuilder.select(consume -> consume.update && !consume.ignore()).toArray(Consume.class);
    hasConsumers = consumers.length > 0;
```

```java
public boolean optional;
public boolean update = true;
public boolean ignore(){
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1350`.
- [x] Read exact upstream Java `Block.java`.
- [x] Read exact upstream Java `Consume.java`.
- [x] Confirmed `PortGame.source_block_reinitialize_consumers_arrays_state` is backed by exact source expressions.
- [x] Confirmed generated bridge owner `Block.java_method_reinitializeConsumers_124`.
- [x] Added RED status assertion for `N1350`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1350` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1350` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed consumer array copy, first `ConsumePower`, optional/non-optional/update filters, ignored exclusion, and `hasConsumers`.
- [x] Godot TCP empty-builder proof confirmed empty arrays, `cons_power=null`, and `has_consumers=false`.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for mixed and empty builders.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_reinitialize_consumers_arrays_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_reinitialize_consumers_arrays_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_reinitialize_consumers_arrays or generated_block_reinitialize_consumers_arrays"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_reinitialize_consumers_arrays`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_reinitialize_consumers_arrays`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_reinitialize_consumers_arrays`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 390.27s (0:06:30)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1350")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_block_reinitialize_consumers_arrays_state(mixed_builder)`: `consumers=[required, optional, manual, ignored, power]`, `cons_power=power`, `optional=[optional]`, `non_optional=[required, manual, power]`, `update=[required, optional, power]`, `has_consumers=true`.
  - TCP `/root/Main.source_block_reinitialize_consumers_arrays_state([])`: empty arrays, `cons_power=null`, `has_consumers=false`.
  - TCP `/root/Main.generated_block_reinitialize_consumers_arrays_bridge_state(mixed_builder)`: `matches=true`.
  - TCP `/root/Main.generated_block_reinitialize_consumers_arrays_bridge_state([])`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1025`
- Not done: `48`
- Source-backed remaining: `35`
- Active remaining: `13`
- Progress: `95.53%`
- Remaining: `4.47%`
- Current next active slice: `N1351 Generated Block reinitializeConsumers item liquid filters bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_reinitialize_consumers_item_liquid_filters_state`
