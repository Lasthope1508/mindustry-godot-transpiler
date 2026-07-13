# N1335 Block Init Liquid Capacity Default Finalize

## Scope

- Slice: `N1335`
- Title: `Generated Block init liquid capacity default bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Arc source: `arc-core/src/arc/math/Mathf.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_liquid_capacity_default_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_liquid_capacity_default_bridge_state`

## Source Evidence

```java
public float liquidCapacity = -1f;
```

```java
//some blocks don't have hasLiquids, but have liquid consumers/liquid capacity
if(liquidCapacity < 0){
    float consumeAmount = 1f;
    for(var cons : consumeBuilder){
        ...
    }
    liquidCapacity = Mathf.round(10f * consumeAmount);
}
```

```java
public static int round(float value){
    return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1335`.
- [x] Read exact upstream Java `Block.java`.
- [x] Read exact upstream Arc `Mathf.java`.
- [x] Confirmed upstream `liquidCapacity` is `float`, so non-negative branch preserves float value.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and liquid capacity default bridge.
- [x] Added RED status assertion for `N1335`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Added RED guard for non-negative float preservation.
- [x] Float-preservation RED failed against existing `int(liquid_capacity_before)` branch.
- [x] Flipped `N1335` status to `done` in canonical ledger and shard mirrors.
- [x] Corrected `PortGame`, generated `Block.gd`, and emitter to preserve non-negative float values.
- [x] Confirmed `N1336` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed after float-preservation fix.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1335` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed negative `liquidCapacity` assigns Arc rounded default `10`.
- [x] Godot TCP source proof confirmed non-negative `0.0` is preserved.
- [x] Godot TCP source proof confirmed non-integer non-negative `24.7` is preserved.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for all liquid capacity cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_liquid_capacity_default_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Float-preservation RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k source_block_init_liquid_capacity_default`
  - Result: failed because `PortGame.gd` still used `else int(liquid_capacity_before)`.
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_init_liquid_capacity_default`
  - Result: failed because emitter still generated `else int(liquid_capacity_before)`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_liquid_capacity_default_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_init_liquid_capacity_default or generated_block_init_liquid_capacity_default"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_init_liquid_capacity_default`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_init_liquid_capacity_default`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_liquid_capacity_default`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 381.49s (0:06:21)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1335")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_init_liquid_capacity_default_state(-1.0)`: `liquid_capacity_assigned=true`, `liquid_capacity_after=10.0`.
  - TCP `/root/Main.source_block_init_liquid_capacity_default_state(-0.25)`: `liquid_capacity_assigned=true`, `liquid_capacity_after=10.0`.
  - TCP `/root/Main.source_block_init_liquid_capacity_default_state(0.0)`: `liquid_capacity_assigned=false`, `liquid_capacity_after=0.0`.
  - TCP `/root/Main.source_block_init_liquid_capacity_default_state(24.7)`: `liquid_capacity_assigned=false`, `liquid_capacity_after=24.7`.
  - TCP `/root/Main.generated_block_init_liquid_capacity_default_bridge_state(...)`: `matches=true` for all four cases.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1013`
- Not done: `60`
- Source-backed remaining: `35`
- Active remaining: `25`
- Progress: `94.41%`
- Remaining: `5.59%`
- Current next active slice: `N1336 Generated Block init emit light radius bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_init_emit_light_radius_state`
