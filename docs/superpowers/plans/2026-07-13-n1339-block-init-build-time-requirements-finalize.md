# N1339 Block Init Build Time Requirements Finalize

## Scope

- Slice: `N1339`
- Title: `Generated Block init build time requirements bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Item source: `core/src/mindustry/type/Item.java`
- ItemStack source: `core/src/mindustry/type/ItemStack.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_build_time_requirements_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_build_time_requirements_bridge_state`

## Source Evidence

```java
if(requirements.length > 0 && buildTime < 0){
    buildTime = 0f;
    for(ItemStack stack : requirements){
        buildTime += stack.amount * stack.item.cost;
    }
}
```

```java
public float cost = 1f;
```

```java
public int amount = 0;
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1339`.
- [x] Read exact upstream Java `Block.java`.
- [x] Read exact upstream Java `Item.java` for `cost`.
- [x] Read exact upstream Java `ItemStack.java` for `amount`.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and build-time requirements bridge.
- [x] Added RED status assertion for `N1339`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1339` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1340` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1339` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed requirements buildTime sum `2 * 0.5 + 3 * 1.5 = 5.5`.
- [x] Godot TCP source proof confirmed explicit non-negative buildTime `12.0` is preserved.
- [x] Godot TCP source proof confirmed empty requirements leaves `buildTime=-1.0` for later default slice.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for sum and preserve cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_build_time_requirements_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_build_time_requirements_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_init_build_time_requirements or generated_block_init_build_time_requirements"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_init_build_time_requirements`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_init_build_time_requirements`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_build_time_requirements`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 396.80s (0:06:36)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1339")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_block_init_build_time_requirements_state(-1.0, [{amount:2,cost:0.5},{amount:3,cost:1.5}])`: `build_time_assigned=true`, `build_time_after=5.5`, `requirements_length=2`.
  - TCP `/root/Main.source_block_init_build_time_requirements_state(12.0, [{amount:2,cost:0.5}])`: `build_time_assigned=false`, `build_time_after=12.0`, `requirements_length=1`.
  - TCP `/root/Main.source_block_init_build_time_requirements_state(-1.0, [])`: `build_time_assigned=false`, `build_time_after=-1.0`, `requirements_length=0`.
  - TCP `/root/Main.generated_block_init_build_time_requirements_bridge_state(...)`: `matches=true` for sum and preserve cases.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1017`
- Not done: `56`
- Source-backed remaining: `35`
- Active remaining: `21`
- Progress: `94.78%`
- Remaining: `5.22%`
- Current next active slice: `N1340 Generated Block init build time default bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_init_build_time_default_state`
