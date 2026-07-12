# N1251 TractorBeamBuild.updateTile Angle To Target Finalize

## Scope

- Slice: `N1251`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() angle to target`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_angle_to_target_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_angle_to_target_bridge_state`

## Source Evidence

```java
if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
    if(!headless){
        control.sound.loop(shootSound, this, shootSoundVolume);
    }

    float dest = angleTo(target);
    rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1251 SSOT ledger, API contract, state schema, module registration.
- [x] Read upstream Java source lines for N1251.
- [x] Added RED status assertion for `N1251`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1251` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `angle_to_target_result`.
- [x] Added `angle_to_target_result` subset in `PortGame.gd` to return only N1251 angle-to-target fields.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1251` canonical and nested status are `done`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_angle_to_target_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_angle_to_target_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_angle_to_target_bridge_state`
  - Result: failed as expected because `var angle_to_target_result := {` was missing.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_angle_to_target_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k angle_to_target`
  - Result: `6 passed, 4011 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_angle_to_target_bridge_state(...)` guard false: `matches=true`, `angle_to_target_evaluated=false`, `dest=0.0`, `angle_to_target_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_angle_to_target_bridge_state(...)` guard true: `matches=true`, `angle_to_target_evaluated=true`, `dest=0.0`, `angle_to_target_call.call="angleTo(target)"`, `angle_to_target_call.origin={"x":10.0,"y":20.0}`, `angle_to_target_call.target={"x":20.0,"y":20.0}`.
  - Result keys were limited to N1251 angle-to-target fields.
  - TCP `/root/Main.ssot_slice_ledger_state("N1251")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 436.46s (0:07:16)`.

## Progress

- Total source-backed slices: `1073`
- Done: `948`
- Not done: `125`
- Progress: `88.35%`
- Remaining: `11.65%`
- Current sequence next slice: `N1252 TractorBeamBuild.updateTile() rotation move`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_rotation_move_state`
