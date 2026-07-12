# N1260 TractorBeamBuild.updateTile Inactive Strength Finalize

## Scope

- Slice: `N1260`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() inactive strength`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_inactive_strength_state`
- Generated owner: `TractorBeamTurret.TractorBeamBuild.updateTile.inactive_strength`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_inactive_strength_bridge_state`

## Source Evidence

```java
if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){
```

```java
}else{
    strength = Mathf.lerpDelta(strength, 0, 0.1f);
}
```

```java
public static float lerpDelta(float fromValue, float toValue, float progress){
    return lerp(fromValue, toValue, clamp(progress * Time.delta));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1260`.
- [x] Read exact upstream Java `TractorBeamTurret.java`.
- [x] Read exact Arc `Mathf.lerpDelta` source.
- [x] Added RED status assertion for `N1260`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `inactive_strength_result`.
- [x] Flipped `N1260` status to `done` in canonical ledger and shard mirrors.
- [x] Added `inactive_strength_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1260` canonical and nested status are `done`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_inactive_strength_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_inactive_strength_bridge_state`
  - Result: failed as expected because `var inactive_strength_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_inactive_strength_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_inactive_strength_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k inactive_strength`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_inactive_strength_bridge_state(...)` inactive branch: `matches=true`, `inactive_strength_evaluated=true`, `inactive_strength_after=10.8`, `inactive_strength_lerp_call.call="strength = Mathf.lerpDelta(strength, 0, 0.1f);"`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_inactive_strength_bridge_state(...)` look-target branch: `matches=true`, `inactive_strength_evaluated=false`, `inactive_strength_after=12.0`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1260")`: `entry.status=done`, `entry.slice.status=done`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 384.39s (0:06:24)`.

## Progress

- Total source-backed slices: `1073`
- Done: `957`
- Not done: `116`
- Source-backed remaining: `78`
- Other remaining: `38`
- Progress: `89.19%`
- Remaining: `10.81%`
- Current sequence next slice: `N1261 Ability.update(Unit unit)`
- Current sequence next owner: `PortGame.source_ability_update_state`
- First unresolved ledger slice by numeric order: `N462 updateWeaving(Bullet b)`
