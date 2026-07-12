# N1253 TractorBeamBuild.updateTile Last Target Position Finalize

## Scope

- Slice: `N1253`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() last target position`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_last_target_position_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_last_target_position_bridge_state`

## Source Evidence

```java
float dest = angleTo(target);
rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);
lastX = target.x;
lastY = target.y;
strength = Mathf.lerpDelta(strength, 1f, 0.1f);
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1253 SSOT ledger, API contract, state schema, module registration, and shard mirrors.
- [x] Read upstream Java source lines for N1253.
- [x] Added RED status assertion for `N1253`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `last_target_position_result`.
- [x] Flipped `N1253` status to `done` in canonical ledger and shard mirrors.
- [x] Added `last_target_position_result` subset in `PortGame.gd` to return only N1253 last-target-position fields.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1253` canonical and nested status are `done`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_last_target_position_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_last_target_position_bridge_state`
  - Result: failed as expected because `var last_target_position_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_last_target_position_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_last_target_position_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k last_target_position`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_last_target_position_bridge_state(...)` not evaluated: `matches=true`, `last_target_position_evaluated=false`, `last_x_after=1.0`, `last_y_after=2.0`, `last_target_position_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_last_target_position_bridge_state(...)` evaluated: `matches=true`, `last_target_position_evaluated=true`, `last_x_after=20.0`, `last_y_after=30.0`, `last_target_position_call.call="lastX = target.x; lastY = target.y;"`.
  - Result keys were limited to N1253 last-target-position fields.
  - TCP `/root/Main.ssot_slice_ledger_state("N1253")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 403.10s (0:06:43)`.

## Progress

- Total source-backed slices: `1073`
- Done: `950`
- Not done: `123`
- Progress: `88.54%`
- Remaining: `11.46%`
- Current sequence next slice: `N1254 TractorBeamBuild.updateTile() strength lerp`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_active_strength_state`
