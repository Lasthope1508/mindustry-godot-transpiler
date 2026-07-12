# N1245 TractorBeamBuild.updateTile Coolant Remove Finalize

## Scope

- Slice: `N1245`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() coolant remove`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_coolant_remove_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_remove_bridge_state`

## Source Evidence

```java
if(target != null && coolant != null){
    float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));

    liquids.remove(liquid, used);
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1245 SSOT ledger, API contract, state schema, module registration.
- [x] Read upstream Java source lines for N1245.
- [x] Added RED status assertion for `N1245`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1245` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `coolant_remove_result`.
- [x] Added `coolant_remove_result` subset in `PortGame.gd` to return only N1245 coolant remove fields.
- [x] Focused GREEN passed for bridge subset.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_coolant_remove_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_coolant_remove_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_coolant_remove_bridge_state`
  - Result: failed as expected because `var coolant_remove_result := {` was missing.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_coolant_remove_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_remove_bridge_state(...)` guard false: `matches=true`, `coolant_guard=false`, `remove_called=false`, `remove_call={}`, `used=0`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_remove_bridge_state(...)` remove: `matches=true`, `coolant_guard=true`, `liquid="water"`, `used=3`, `remove_called=true`, `remove_call.call="liquids.remove(liquid, used);"`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1245")`: `status=done`, `nested_status=done`.
  - Result keys were limited to `coolant_guard`, `liquid`, `used`, `remove_called`, `remove_call`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 416.88s (0:06:56)`.

## Progress

- Total source-backed slices: `1073`
- Done: `942`
- Not done: `131`
- Progress: `87.79%`
- Remaining: `12.21%`
- Current sequence next slice: `N1246 TractorBeamBuild.updateTile() coolant effect`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_coolant_effect_state`
