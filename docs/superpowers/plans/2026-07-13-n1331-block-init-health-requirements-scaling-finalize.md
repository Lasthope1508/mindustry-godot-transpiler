# N1331 Block Init Health Requirements Scaling Finalize

## Scope

- Slice: `N1331`
- Title: `Generated Block init health requirements scaling bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_health_requirements_scaling_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_health_requirements_scaling_bridge_state`

## Source Evidence

```java
//initialize default health based on size
if(health == -1){
    boolean round = false;
    if(scaledHealth < 0){
        scaledHealth = 40;

        float scaling = 1f;
        for(var stack : requirements){
            scaling += stack.item.healthScaling;
        }

        scaledHealth *= scaling;
        round = true;
    }

    health = round ?
        Mathf.round(size * size * scaledHealth, 5) :
        (int)(size * size * scaledHealth);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1331`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed `Item.healthScaling` source field from `core/src/mindustry/type/Item.java`.
- [x] Confirmed Arc `Mathf.round(float value, int step)` source step expression.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and requirements scaling bridge.
- [x] Added RED status assertion for `N1331`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1331` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1332` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1331` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `health=-1`, `size=2`, `scaledHealth=-1`, requirements `[0.2, 0.25]` assigns `health=230`.
- [x] Godot TCP source proof confirmed empty requirements scaling assigns `health=360` for `size=3`.
- [x] Godot TCP source proof confirmed existing `health=120` is preserved.
- [x] Godot TCP source proof confirmed non-negative `scaledHealth=80` remains outside this negative-scaling branch.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for all requirements scaling cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_health_requirements_scaling_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_health_requirements_scaling_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_init_health_requirements_scaling or generated_block_init_health_requirements_scaling"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_init_health_requirements_scaling`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_init_health_requirements_scaling`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_health_requirements_scaling`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 393.11s (0:06:33)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1331")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_init_health_requirements_scaling_state(-1, 2, -1.0, [0.2, 0.25])`: `health_assigned=true`, `health_after=230`, `scaled_health_after=58.0`, `scaling=1.45`, `round=true`.
  - TCP `/root/Main.source_block_init_health_requirements_scaling_state(-1, 3, -1.0, [])`: `health_assigned=true`, `health_after=360`, `scaled_health_after=40.0`, `scaling=1.0`, `round=true`.
  - TCP `/root/Main.source_block_init_health_requirements_scaling_state(120, 2, -1.0, [0.2])`: `health_assigned=false`, `health_after=120`.
  - TCP `/root/Main.source_block_init_health_requirements_scaling_state(-1, 2, 80.0, [0.2])`: `health_assigned=false`, `health_after=-1`, `scaled_health_after=80.0`.
  - TCP `/root/Main.generated_block_init_health_requirements_scaling_bridge_state(-1, 2, -1.0, [0.2, 0.25])`: `matches=true`.
  - TCP `/root/Main.generated_block_init_health_requirements_scaling_bridge_state(-1, 3, -1.0, [])`: `matches=true`.
  - TCP `/root/Main.generated_block_init_health_requirements_scaling_bridge_state(120, 2, -1.0, [0.2])`: `matches=true`.
  - TCP `/root/Main.generated_block_init_health_requirements_scaling_bridge_state(-1, 2, 80.0, [0.2])`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1009`
- Not done: `64`
- Source-backed remaining: `35`
- Active remaining: `29`
- Progress: `94.04%`
- Remaining: `5.96%`
- Current next active slice: `N1332 Generated Block init clip size bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_init_clip_size_state`
