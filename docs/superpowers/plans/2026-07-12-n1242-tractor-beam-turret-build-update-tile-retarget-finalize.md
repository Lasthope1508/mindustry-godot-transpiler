# N1242 TractorBeamBuild.updateTile Retarget Finalize

## Scope

- Slice: `N1242`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() retarget`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_retarget_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_retarget_bridge_state`

## Source Evidence

```java
float eff = efficiency * coolantMultiplier, edelta = eff * delta();

//retarget
if(timer(timerTarget, retargetTime)){
    target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1242 SSOT ledger, API contract, state schema, module registration.
- [x] Read upstream Java source lines for N1242.
- [x] Added RED status assertion for `N1242`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1242` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `retarget_result`.
- [x] Added `retarget_result` subset in `PortGame.gd` to return only N1242 retarget fields.
- [x] Focused GREEN passed for bridge subset.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_retarget_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_retarget_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_retarget_bridge_state`
  - Result: failed as expected because `var retarget_result := {` was missing.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_retarget_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- SSOT:
  - Command: `source_ssot.validate_json_modules(Path("godot-mindustry"))`
  - Result: `{"module_count":112,"errors":[]}`.
- Godot MCP runtime proof:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_retarget_bridge_state(3.5, 0.75, 2.0, 1.5, 0.25, true, existing, closest, "sharded", 10.0, 20.0, 120.0, true, false)`: `matches=true`, `returned_early=true`, `retarget_called=false`, `target_after=existing`, `closest_enemy_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_retarget_bridge_state(0.0, 0.75, 2.0, 1.5, 0.25, false, existing, closest, "sharded", 10.0, 20.0, 120.0, true, false)`: `matches=true`, `returned_early=false`, `retarget_called=false`, `target_after=existing`, `closest_enemy_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_retarget_bridge_state(0.0, 0.75, 2.0, 1.5, 0.25, true, existing, closest, "sharded", 10.0, 20.0, 120.0, true, false)`: `matches=true`, `returned_early=false`, `retarget_called=true`, `target_after=closest`, `closest_enemy_call.call=Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1242")`: `status=done`, `nested_status=done`.
  - Result keys were limited to `closest_enemy_call`, `closest_enemy_result`, `existing_target`, `range_value`, `retarget_called`, `retarget_evaluated`, `returned_early`, `target_after`, `target_air`, `target_ground`, `team`, `timer_target_ready`, `x`, `y`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 380.91s (0:06:20)`.

## Progress

- Total source-backed slices: `1073`
- Done: `939`
- Not done: `134`
- Progress: `87.51%`
- Remaining: `12.49%`
- Next slice: `N1243 TractorBeamBuild.updateTile() coolant guard`
- Next owner: `PortGame.source_tractor_beam_turret_build_update_tile_coolant_guard_state`

## Notes

- `Units.closestEnemy(...)` internals remain deferred by SSOT; N1242 only records dispatch, explicit input `closest_enemy_result`, and target assignment.
- `retarget_result` prevents later coolant/shooting fields from being serialized during N1242 MCP proof.
- No formula, parameter, or symbol was invented; all names come from upstream Java and SSOT.
