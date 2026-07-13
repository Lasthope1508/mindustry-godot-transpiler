# N1327 Block Init UnderBullets Finalize

## Scope

- Slice: `N1327`
- Title: `Generated Block init underBullets bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_under_bullets_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_under_bullets_bridge_state`

## Source Evidence

```java
if(underBullets){
    priority = TargetPriority.under;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1327`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed slice rule limits this bridge to underBullets priority assignment only and does not claim fogRadius, sync, health, liquid, or other init branches.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and underBullets priority assignment bridge.
- [x] Added RED status assertion for `N1327`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1327` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1328` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1327` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `underBullets=true` assigns `priority=TargetPriority.under`.
- [x] Godot TCP source proof confirmed `underBullets=false` preserves `priority=TargetPriority.base`.
- [x] Godot TCP source proof confirmed `underBullets=false` preserves `priority=TargetPriority.under`.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for all underBullets cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_under_bullets_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -p no:cacheprovider -k test_generated_block_init_under_bullets_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -p no:cacheprovider -k "test_port_game_exposes_source_block_init_under_bullets_state or test_port_game_exposes_generated_block_init_under_bullets_bridge_state"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -p no:cacheprovider -k test_block_init_under_bullets_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -p no:cacheprovider -k test_emit_bridges_block_init_under_bullets_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_under_bullets`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, 'tools/mindustry_godot_transpiler'); from mindustry_port import source_ssot; report = source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']}); raise SystemExit(1 if report['errors'] else 0)"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 394.72s (0:06:34)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1327")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_init_under_bullets_state(true, "TargetPriority.base")`: `priority_assigned=true`, `priority_after="TargetPriority.under"`.
  - TCP `/root/Main.source_block_init_under_bullets_state(false, "TargetPriority.base")`: `priority_assigned=false`, `priority_after="TargetPriority.base"`.
  - TCP `/root/Main.source_block_init_under_bullets_state(false, "TargetPriority.under")`: `priority_assigned=false`, `priority_after="TargetPriority.under"`.
  - TCP `/root/Main.generated_block_init_under_bullets_bridge_state(true, "TargetPriority.base")`: `matches=true`.
  - TCP `/root/Main.generated_block_init_under_bullets_bridge_state(false, "TargetPriority.base")`: `matches=true`.
  - TCP `/root/Main.generated_block_init_under_bullets_bridge_state(false, "TargetPriority.under")`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1005`
- Not done: `68`
- Source-backed remaining: `35`
- Active remaining: `33`
- Progress: `93.66%`
- Remaining: `6.34%`
- Current next slice: `N1328 Generated Block init fogRadius flag bridge state`
- Current next status: `active`
- Current next owner: `PortGame.source_block_init_fog_radius_flag_state`
