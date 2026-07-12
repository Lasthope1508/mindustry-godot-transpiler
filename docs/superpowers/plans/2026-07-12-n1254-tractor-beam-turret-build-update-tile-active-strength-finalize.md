# N1254 TractorBeamBuild.updateTile Active Strength Finalize

## Scope

- Slice: `N1254`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() active strength`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_active_strength_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_active_strength_bridge_state`

## Source Evidence

```java
lastY = target.y;
strength = Mathf.lerpDelta(strength, 1f, 0.1f);
if(Angles.within(rotation, dest, shootCone)){
```

```java
public static float lerpDelta(float fromValue, float toValue, float progress){
    return lerp(fromValue, toValue, clamp(progress * Time.delta));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1254 SSOT ledger, API contract, state schema, module registration, and shard mirrors.
- [x] Read upstream Java source lines for N1254.
- [x] Added RED status assertion for `N1254`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `active_strength_result`.
- [x] Flipped `N1254` status to `done` in canonical ledger and shard mirrors.
- [x] Added `active_strength_result` subset in `PortGame.gd` to return only N1254 active-strength fields.
- [x] Runtime proof exposed cross-slice contamination when generated `strength_after` had already been overwritten by inactive-strength logic.
- [x] Added RED guard requiring `strength_after` to fall back to `strength_before` when `strength_lerp_evaluated=false`.
- [x] Patched bridge subset to isolate active-strength branch result.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1254` canonical and nested status are `done`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_active_strength_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_active_strength_bridge_state`
  - Result: failed as expected because `var active_strength_result := {` was missing.
- Cross-slice isolation RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_active_strength_bridge_state`
  - Result: failed as expected because the N1254 subset did not isolate `strength_after` when `strength_lerp_evaluated=false`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_active_strength_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_active_strength_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k active_strength`
  - Result: `10 passed, 4007 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_active_strength_bridge_state(...)` not evaluated: `matches=true`, `strength_lerp_evaluated=false`, `strength_after=0.2`, `strength_lerp_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_active_strength_bridge_state(...)` evaluated: `matches=true`, `strength_lerp_evaluated=true`, `strength_lerp_scaled_progress=0.1`, `strength_lerp_clamped_progress=0.1`, `strength_after=0.28`, `strength_lerp_call.call="strength = Mathf.lerpDelta(strength, 1f, 0.1f);"`.
  - Result keys were limited to N1254 active-strength fields.
  - TCP `/root/Main.ssot_slice_ledger_state("N1254")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 400.33s (0:06:40)`.

## Progress

- Total source-backed slices: `1073`
- Done: `951`
- Not done: `122`
- Progress: `88.63%`
- Remaining: `11.37%`
- Current sequence next slice: `N1255 TractorBeamBuild.updateTile() shoot when possible guard`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state`
