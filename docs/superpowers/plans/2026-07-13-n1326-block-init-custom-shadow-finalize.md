# N1326 Block Init CustomShadow Finalize

## Scope

- Slice: `N1326`
- Title: `Generated Block init customShadow bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_custom_shadow_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_custom_shadow_bridge_state`

## Source Evidence

```java
//disable standard shadow
if(customShadow){
    hasShadow = false;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1326`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed slice rule limits this bridge to customShadow standard shadow suppression only and does not claim underBullets, fogRadius, sync, health, liquid, or other init branches.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and customShadow guard assignment bridge.
- [x] Added RED status assertion for `N1326`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1326` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1327` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1326` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `customShadow=true` assigns `hasShadow=false`.
- [x] Godot TCP source proof confirmed `customShadow=false` preserves `hasShadow=true`.
- [x] Godot TCP source proof confirmed `customShadow=false` preserves `hasShadow=false`.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for all customShadow cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_custom_shadow_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -p no:cacheprovider -k test_generated_block_init_custom_shadow_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -p no:cacheprovider -k "test_port_game_exposes_source_block_init_custom_shadow_state or test_port_game_exposes_generated_block_init_custom_shadow_bridge_state"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -p no:cacheprovider -k test_block_init_custom_shadow_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -p no:cacheprovider -k test_emit_bridges_block_init_custom_shadow_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_custom_shadow`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, 'tools/mindustry_godot_transpiler'); from mindustry_port import source_ssot; report = source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']}); raise SystemExit(1 if report['errors'] else 0)"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 397.31s (0:06:37)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1326")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_init_custom_shadow_state(true, true)`: `has_shadow_assigned=true`, `has_shadow_after=false`.
  - TCP `/root/Main.source_block_init_custom_shadow_state(false, true)`: `has_shadow_assigned=false`, `has_shadow_after=true`.
  - TCP `/root/Main.source_block_init_custom_shadow_state(false, false)`: `has_shadow_assigned=false`, `has_shadow_after=false`.
  - TCP `/root/Main.generated_block_init_custom_shadow_bridge_state(true, true)`: `matches=true`.
  - TCP `/root/Main.generated_block_init_custom_shadow_bridge_state(false, true)`: `matches=true`.
  - TCP `/root/Main.generated_block_init_custom_shadow_bridge_state(false, false)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1004`
- Not done: `69`
- Source-backed remaining: `35`
- Active remaining: `34`
- Progress: `93.57%`
- Remaining: `6.43%`
- Current next slice: `N1327 Generated Block init underBullets bridge state`
- Current next status: `active`
- Current next owner: `PortGame.source_block_init_under_bullets_state`
