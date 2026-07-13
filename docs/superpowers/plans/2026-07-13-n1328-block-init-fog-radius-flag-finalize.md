# N1328 Block Init FogRadius Flag Finalize

## Scope

- Slice: `N1328`
- Title: `Generated Block init fogRadius flag bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_fog_radius_flag_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_fog_radius_flag_bridge_state`

## Source Evidence

```java
if(fogRadius > 0){
    flags = flags.with(BlockFlag.hasFogRadius);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1328`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed slice rule limits this bridge to fogRadius flag assignment only and does not claim sync, health, liquid, or other init branches.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary and fogRadius flag bridge.
- [x] Added RED status assertion for `N1328`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1328` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1329` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1328` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `fogRadius=5` appends `BlockFlag.hasFogRadius`.
- [x] Godot TCP source proof confirmed `fogRadius=0` preserves existing flags.
- [x] Godot TCP source proof confirmed existing `BlockFlag.hasFogRadius` remains single when `fogRadius=3`.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for all fogRadius flag cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_fog_radius_flag_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -p no:cacheprovider -k test_generated_block_init_fog_radius_flag_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -p no:cacheprovider -k "test_port_game_exposes_source_block_init_fog_radius_flag_state or test_port_game_exposes_generated_block_init_fog_radius_flag_bridge_state"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -p no:cacheprovider -k test_block_init_fog_radius_flag_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -p no:cacheprovider -k test_emit_bridges_block_init_fog_radius_flag_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_fog_radius_flag`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, 'tools/mindustry_godot_transpiler'); from mindustry_port import source_ssot; report = source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']}); raise SystemExit(1 if report['errors'] else 0)"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 394.10s (0:06:34)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1328")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_init_fog_radius_flag_state(5, ["BlockFlag.synthetic"])`: `has_fog_radius_flag_added=true`, `flags_after=["BlockFlag.synthetic","BlockFlag.hasFogRadius"]`.
  - TCP `/root/Main.source_block_init_fog_radius_flag_state(0, ["BlockFlag.synthetic"])`: `has_fog_radius_flag_added=false`, `flags_after=["BlockFlag.synthetic"]`.
  - TCP `/root/Main.source_block_init_fog_radius_flag_state(3, ["BlockFlag.hasFogRadius"])`: `has_fog_radius_flag_added=true`, `flags_after=["BlockFlag.hasFogRadius"]`.
  - TCP `/root/Main.generated_block_init_fog_radius_flag_bridge_state(5, ["BlockFlag.synthetic"])`: `matches=true`.
  - TCP `/root/Main.generated_block_init_fog_radius_flag_bridge_state(0, ["BlockFlag.synthetic"])`: `matches=true`.
  - TCP `/root/Main.generated_block_init_fog_radius_flag_bridge_state(3, ["BlockFlag.hasFogRadius"])`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1006`
- Not done: `67`
- Source-backed remaining: `35`
- Active remaining: `32`
- Progress: `93.76%`
- Remaining: `6.24%`
- Current next slice: `N1329 Generated Block init sync flag bridge state`
- Current next status: `active`
- Current next owner: `PortGame.source_block_init_sync_flag_state`
