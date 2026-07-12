# N1255 TractorBeamBuild.updateTile Shoot When Possible Guard Finalize

## Scope

- Slice: `N1255`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() shoot when possible guard`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_bridge_state`

## Source Evidence

```java
strength = Mathf.lerpDelta(strength, 1f, 0.1f);

//shoot when possible
if(Angles.within(rotation, dest, shootCone)){
    if(damage > 0){
```

```java
public static boolean within(float a, float b, float margin){
    return angleDist(a, b) <= margin;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1255 SSOT ledger, API contract, state schema, module registration, and shard mirrors.
- [x] Read upstream Java source lines for N1255.
- [x] Added RED status assertion for `N1255`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `shoot_when_possible_guard_result`.
- [x] Flipped `N1255` status to `done` in canonical ledger and shard mirrors.
- [x] Added `shoot_when_possible_guard_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1255` canonical and nested status are `done`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_bridge_state`
  - Result: failed as expected because `var shoot_when_possible_guard_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k shoot_when_possible_guard`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_bridge_state(...)` not evaluated: `matches=true`, `shoot_when_possible_evaluated=false`, `shoot_within_guard=false`, `shoot_within_angle_dist=0.0`, `shoot_within_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_bridge_state(...)` within true: `matches=true`, `shoot_when_possible_evaluated=true`, `dest=45.0`, `rotation_after=10.15`, `shoot_within_angle_dist=34.85`, `shoot_cone=40.0`, `shoot_within_guard=true`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_bridge_state(...)` within false: `matches=true`, `shoot_when_possible_evaluated=true`, `dest=45.0`, `rotation_after=10.15`, `shoot_within_angle_dist=34.85`, `shoot_cone=15.0`, `shoot_within_guard=false`.
  - Result keys were limited to N1255 shoot-when-possible guard fields.
  - TCP `/root/Main.ssot_slice_ledger_state("N1255")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 385.03s (0:06:25)`.

## Progress

- Total source-backed slices: `1073`
- Done: `952`
- Not done: `121`
- Source-backed remaining: `83`
- Other remaining: `38`
- Progress: `88.72%`
- Remaining: `11.28%`
- Current sequence next slice: `N1256 TractorBeamBuild.updateTile() damage pierce`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_damage_pierce_state`
