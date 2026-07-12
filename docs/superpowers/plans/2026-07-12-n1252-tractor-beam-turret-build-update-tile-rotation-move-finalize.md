# N1252 TractorBeamBuild.updateTile Rotation Move Finalize

## Scope

- Slice: `N1252`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() rotation move`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_rotation_move_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_rotation_move_bridge_state`

## Source Evidence

```java
float dest = angleTo(target);
rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);
lastX = target.x;
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1252 SSOT ledger, API contract, state schema, module registration.
- [x] Read upstream Java source lines for N1252.
- [x] Added RED status assertion for `N1252`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1252` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `rotation_move_result`.
- [x] Added `rotation_move_result` subset in `PortGame.gd` to return only N1252 rotation-move fields.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1252` canonical and nested status are `done`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_rotation_move_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_rotation_move_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_rotation_move_bridge_state`
  - Result: failed as expected because `var rotation_move_result := {` was missing.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_rotation_move_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k rotation_move`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_rotation_move_bridge_state(...)` not evaluated: `matches=true`, `rotation_move_evaluated=false`, `rotation_max_delta=0.0`, `rotation_after=10.0`, `rotation_move_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_rotation_move_bridge_state(...)` move toward zero: `matches=true`, `rotation_max_delta=0.15`, `rotation_after=9.85`, `rotation_move_call.result=9.85`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_rotation_move_bridge_state(...)` move toward 90: `matches=true`, `rotation_max_delta=0.15`, `rotation_after=0.15`, `rotation_move_call.dest=90.0`.
  - Result keys were limited to N1252 rotation-move fields.
  - TCP `/root/Main.ssot_slice_ledger_state("N1252")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 383.22s (0:06:23)`.

## Progress

- Total source-backed slices: `1073`
- Done: `949`
- Not done: `124`
- Progress: `88.44%`
- Remaining: `11.56%`
- Current sequence next slice: `N1253 TractorBeamBuild.updateTile() last target position`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_last_target_position_state`
