# N1246 TractorBeamBuild.updateTile Coolant Effect Finalize

## Scope

- Slice: `N1246`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() coolant effect`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_coolant_effect_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_effect_bridge_state`

## Source Evidence

```java
if(target != null && coolant != null){
    if(Mathf.chance(0.06 * used)){
        coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));
    }
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1246 SSOT ledger, API contract, state schema, module registration.
- [x] Read upstream Java source lines for N1246.
- [x] Added RED status assertion for `N1246`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1246` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `coolant_effect_result`.
- [x] Added `coolant_effect_result` subset in `PortGame.gd` to return only N1246 coolant effect fields.
- [x] Focused GREEN passed for bridge subset.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_coolant_effect_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_coolant_effect_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_coolant_effect_bridge_state`
  - Result: failed as expected because `var coolant_effect_result := {` was missing.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_coolant_effect_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k coolant_effect`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_effect_bridge_state(...)` guard false: `matches=true`, `coolant_guard=false`, `chance_called=false`, `cool_effect_called=false`, `cool_effect_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_effect_bridge_state(...)` chance false: `matches=true`, `coolant_guard=true`, `used=2`, `chance_threshold=0.12`, `particle_range=8`, `chance_called=true`, `cool_effect_called=false`, `cool_effect_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_effect_bridge_state(...)` chance true: `matches=true`, `coolant_guard=true`, `used=2`, `chance_threshold=0.12`, `particle_range=8`, `cool_effect_called=true`, `cool_effect_call.call="coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));"`, `cool_effect_call.x=11.5`, `cool_effect_call.y=17.75`, `cool_effect_call.range=8`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1246")`: `status=done`, `nested_status=done`.
  - Result keys were limited to `coolant_guard`, `used`, `chance_result`, `x`, `y`, `size`, `source_tilesize`, `range_x`, `range_y`, `chance_threshold`, `particle_range`, `chance_called`, `cool_effect_called`, `cool_effect_call`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 453.13s (0:07:33)`.

## Progress

- Total source-backed slices: `1073`
- Done: `943`
- Not done: `130`
- Progress: `87.88%`
- Remaining: `12.12%`
- Current sequence next slice: `N1247 TractorBeamBuild.updateTile() coolant multiplier`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_coolant_multiplier_state`
