# N1248 TractorBeamBuild.updateTile Any Reset Finalize

## Scope

- Slice: `N1248`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() any reset`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_any_reset_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_any_reset_bridge_state`

## Source Evidence

```java
if(activationTimer > 0){
    activationTimer -= Time.delta;
    return;
}

any = false;
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1248 SSOT ledger, API contract, state schema, module registration.
- [x] Read upstream Java source lines for N1248.
- [x] Added RED status assertion for `N1248`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1248` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `any_reset_result`.
- [x] Added `any_reset_result` subset in `PortGame.gd` to return only N1248 any reset fields.
- [x] Focused GREEN passed for bridge subset.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_any_reset_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_any_reset_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_any_reset_bridge_state`
  - Result: failed as expected because `var any_reset_result := {` was missing.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_any_reset_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k any_reset`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_any_reset_bridge_state(...)` early true: `matches=true`, `activation_returned_early=true`, `any_before=true`, `any_after=true`, `any_reset_evaluated=false`, `any_reset_called=false`, `any_reset_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_any_reset_bridge_state(...)` early false: `matches=true`, `activation_returned_early=true`, `any_before=false`, `any_after=false`, `any_reset_called=false`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_any_reset_bridge_state(...)` reset true: `matches=true`, `activation_returned_early=false`, `any_before=true`, `any_after=false`, `any_reset_evaluated=true`, `any_reset_called=true`, `any_reset_call.value=false`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_any_reset_bridge_state(...)` reset false: `matches=true`, `activation_returned_early=false`, `any_before=false`, `any_after=false`, `any_reset_called=true`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1248")`: `status=done`, `nested_status=done`.
  - Result keys were limited to `activation_returned_early`, `any_before`, `any_reset_evaluated`, `any_reset_called`, `any_after`, `any_reset_call`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 414.58s (0:06:54)`.

## Progress

- Total source-backed slices: `1073`
- Done: `945`
- Not done: `128`
- Progress: `88.07%`
- Remaining: `11.93%`
- Current sequence next slice: `N1249 TractorBeamBuild.updateTile() look target guard`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_look_target_guard_state`
