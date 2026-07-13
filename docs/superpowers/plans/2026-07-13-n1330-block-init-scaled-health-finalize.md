# N1330 Block Init Scaled Health Finalize

## Scope

- Slice: `N1330`
- Title: `Generated Block init scaled health bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_health_scaled_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_health_scaled_bridge_state`

## Source Evidence

```java
//initialize default health based on size
if(health == -1){
    boolean round = false;
    if(scaledHealth < 0){
        scaledHealth = 40;
        // negative scaledHealth requirements scaling continues in N1331
    }

    health = round ?
        Mathf.round(size * size * scaledHealth, 5) :
        (int)(size * size * scaledHealth);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1330`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed slice rule limits this bridge to non-negative scaledHealth health assignment and defers negative scaledHealth requirements scaling to `N1331`.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and scaled health bridge.
- [x] Added RED status assertion for `N1330`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1330` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1331` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1330` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `health=-1`, `size=2`, `scaledHealth=80` assigns `health=320`.
- [x] Godot TCP source proof confirmed existing `health=120` is preserved.
- [x] Godot TCP source proof confirmed negative `scaledHealth=-1` remains deferred in this slice.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for all scaled health cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_health_scaled_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -p no:cacheprovider -k test_generated_block_init_health_scaled_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -p no:cacheprovider -k "test_port_game_exposes_source_block_init_health_scaled_state or test_port_game_exposes_generated_block_init_health_scaled_bridge_state"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -p no:cacheprovider -k test_block_init_health_scaled_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -p no:cacheprovider -k test_emit_bridges_block_init_health_scaled_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_health_scaled`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, 'tools/mindustry_godot_transpiler'); from mindustry_port import source_ssot; report = source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']}); raise SystemExit(1 if report['errors'] else 0)"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 395.01s (0:06:35)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1330")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_init_health_scaled_state(-1, 2, 80.0)`: `health_assigned=true`, `health_after=320`, `round=false`.
  - TCP `/root/Main.source_block_init_health_scaled_state(120, 2, 80.0)`: `health_assigned=false`, `health_after=120`.
  - TCP `/root/Main.source_block_init_health_scaled_state(-1, 2, -1.0)`: `health_assigned=false`, `health_after=-1`, `scaled_health=-1.0`.
  - TCP `/root/Main.generated_block_init_health_scaled_bridge_state(-1, 2, 80.0)`: `matches=true`.
  - TCP `/root/Main.generated_block_init_health_scaled_bridge_state(120, 2, 80.0)`: `matches=true`.
  - TCP `/root/Main.generated_block_init_health_scaled_bridge_state(-1, 2, -1.0)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1008`
- Not done: `65`
- Source-backed remaining: `35`
- Active remaining: `30`
- Progress: `93.94%`
- Remaining: `6.06%`
- Current next slice: `N1331 Generated Block init health requirements scaling bridge state`
- Current next status: `active`
- Current next owner: `PortGame.source_block_init_health_requirements_scaling_state`
