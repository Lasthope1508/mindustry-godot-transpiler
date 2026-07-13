# N1353 Block Reinitialize Consumers Apply Loop Finalize

## Scope

- Slice: `N1353`
- Title: `Generated Block reinitializeConsumers consumer apply loop bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Consume source: `core/src/mindustry/world/consumers/Consume.java`
- Java method: `Block.reinitializeConsumers()`
- Godot owner: `PortGame.source_block_reinitialize_consumers_apply_loop_state`
- Generated owner: `Block.java_method_reinitializeConsumers_124`
- Runtime proof: `/root/Main.generated_block_reinitialize_consumers_apply_loop_bridge_state`

## Source Evidence

```java
public void reinitializeConsumers(){
    for(Consume cons : consumers){
        cons.apply(this);
    }
```

```java
public void apply(Block block){
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1353`.
- [x] Read exact upstream Java `Block.java`.
- [x] Read exact upstream Java `Consume.java`.
- [x] Confirmed `PortGame.source_block_reinitialize_consumers_apply_loop_state` is backed by exact source expressions.
- [x] Confirmed generated `Block.java_method_reinitializeConsumers_124` has `consumer_apply_loop` bridge mode.
- [x] Added RED status assertion for `N1353`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1353` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1353` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed three consumers produce three `cons.apply(this);` calls in input order.
- [x] Godot TCP empty source proof confirmed zero consumers produce zero apply calls.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for mixed and empty consumers.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_reinitialize_consumers_apply_loop_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_reinitialize_consumers_apply_loop_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_reinitialize_consumers_apply_loop or generated_block_reinitialize_consumers_apply_loop"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_reinitialize_consumers_apply_loop`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_reinitialize_consumers_apply_loop`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_reinitialize_consumers_apply_loop`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 415.54s (0:06:55)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1353")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_block_reinitialize_consumers_apply_loop_state([{id=alpha}, {id=beta}, {id=gamma}])`: `apply_call_count=3`, call labels all `cons.apply(this);`, block args all `this`, order `alpha,beta,gamma`.
  - TCP `/root/Main.source_block_reinitialize_consumers_apply_loop_state([])`: `apply_call_count=0`, `apply_calls=[]`.
  - TCP `/root/Main.generated_block_reinitialize_consumers_apply_loop_bridge_state([{id=alpha}, {id=beta}, {id=gamma}])`: `matches=true`.
  - TCP `/root/Main.generated_block_reinitialize_consumers_apply_loop_bridge_state([])`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1028`
- Not done: `45`
- Source-backed remaining: `35`
- Active remaining: `10`
- Progress: `95.81%`
- Remaining: `4.19%`
- Current next active slice: `N1354 Generated Block checkContentArrayCapacity filter resize bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_check_content_array_capacity_state`
