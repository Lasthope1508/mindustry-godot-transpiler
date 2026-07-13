# N1344 Block Init Consumer Apply Loop Finalize

## Scope

- Slice: `N1344`
- Title: `Generated Block init consumer apply loop bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Consume source: `core/src/mindustry/world/consumers/Consume.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_consumer_apply_loop_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_consumer_apply_loop_bridge_state`

## Source Evidence

```java
for(Consume cons : consumers){
    cons.apply(this);
}
```

```java
public void apply(Block block){
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1344`.
- [x] Read exact upstream Java `Block.java`.
- [x] Read exact upstream Java `Consume.java`.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and consumer apply-loop bridge.
- [x] Added RED status assertion for `N1344`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1344` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1344` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed each consumer receives one `cons.apply(this);` call plan.
- [x] Godot TCP source proof confirmed empty consumers return zero apply calls.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for mixed and empty cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_consumer_apply_loop_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_consumer_apply_loop_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_init_consumer_apply_loop or generated_block_init_consumer_apply_loop"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_init_consumer_apply_loop`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_init_consumer_apply_loop`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_consumer_apply_loop`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 395.86s (0:06:35)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1344")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP mixed source proof: `apply_call_count=3`; each entry records `call="cons.apply(this);"` and `block_arg="this"`.
  - TCP empty source proof: `apply_call_count=0`, `apply_calls=[]`.
  - TCP `/root/Main.generated_block_init_consumer_apply_loop_bridge_state(...)`: `matches=true` for mixed and empty cases.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1022`
- Not done: `51`
- Source-backed remaining: `35`
- Active remaining: `16`
- Progress: `95.25%`
- Remaining: `4.75%`
- Current next active slice: `N1345 Generated Block init setBars call bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_init_set_bars_call_state`
