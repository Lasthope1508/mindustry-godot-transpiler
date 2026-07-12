# N1249 TractorBeamBuild.updateTile Look Target Guard Finalize

## Scope

- Slice: `N1249`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() look target guard`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_look_target_guard_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_look_target_guard_bridge_state`

## Source Evidence

```java
any = false;

//look at target
if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
    if(!headless){
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1249 SSOT ledger, API contract, state schema, module registration.
- [x] Read upstream Java source lines for N1249.
- [x] Added RED status assertion for `N1249`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1249` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `look_target_guard_result`.
- [x] Added `look_target_guard_result` subset in `PortGame.gd` to return only N1249 look-target-guard fields.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.
- [x] Godot MCP ledger runtime proof confirmed `N1249` canonical and nested status are `done`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_look_target_guard_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_look_target_guard_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_look_target_guard_bridge_state`
  - Result: failed as expected because `var look_target_guard_result := {` was missing.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_look_target_guard_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k look_target_guard`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_look_target_guard_bridge_state(...)` early return: `matches=true`, `look_target_evaluated=false`, `look_target_guard=false`, `target_within_call={}`, `target_check_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_look_target_guard_bridge_state(...)` null target: `matches=true`, `target_exists_for_look=false`, `look_target_guard=false`, `target_within_call={}`, `target_check_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_look_target_guard_bridge_state(...)` within false: `matches=true`, `target_within_evaluated=true`, `target_team_evaluated=false`, `look_target_guard=false`, `target_check_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_look_target_guard_bridge_state(...)` same team: `matches=true`, `target_enemy=false`, `target_check_evaluated=false`, `look_target_guard=false`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_look_target_guard_bridge_state(...)` check false: `matches=true`, `target_check_evaluated=true`, `efficiency_gate_evaluated=false`, `look_target_guard=false`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_look_target_guard_bridge_state(...)` low efficiency: `matches=true`, `efficiency_gate_evaluated=true`, `look_target_guard=false`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_look_target_guard_bridge_state(...)` true guard: `matches=true`, `target_within_radius=86.0`, `target_enemy=true`, `target_check_evaluated=true`, `efficiency_gate_evaluated=true`, `look_target_guard=true`.
  - Result keys were limited to N1249 look-target-guard fields.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Godot MCP ledger proof:
  - TCP `/root/Main.ssot_slice_ledger_state("N1249")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 423.72s (0:07:03)`.

## Progress

- Total source-backed slices: `1073`
- Done: `946`
- Not done: `127`
- Progress: `88.16%`
- Remaining: `11.84%`
- Current sequence next slice: `N1250 TractorBeamBuild.updateTile() sound loop`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_sound_loop_state`
