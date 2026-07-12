# N1244 TractorBeamBuild.updateTile Coolant Used Finalize

## Scope

- Slice: `N1244`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() coolant used`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_coolant_used_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_used_bridge_state`

## Source Evidence

```java
if(target != null && coolant != null){
    float maxUsed = coolant.amount;

    Liquid liquid = liquids.current();

    float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));

    liquids.remove(liquid, used);
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1244 SSOT ledger, API contract, state schema, module registration.
- [x] Read upstream Java source lines for N1244.
- [x] Added RED status assertion for `N1244`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1244` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `coolant_used_result`.
- [x] Added `coolant_used_result` subset in `PortGame.gd` to return only N1244 coolant used fields.
- [x] Focused GREEN passed for bridge subset.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_coolant_used_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_coolant_used_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_coolant_used_bridge_state`
  - Result: failed as expected because `var coolant_used_result := {` was missing.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_coolant_used_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_used_bridge_state(...)` guard false: `matches=true`, `coolant_guard=false`, `used=0`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_used_bridge_state(...)` liquid cap: `matches=true`, `liquid_amount=3`, `max_used_time_delta=18`, `heat_capacity_limit=20`, `used=3`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_used_bridge_state(...)` maxUsed*Time.delta cap: `matches=true`, `liquid_amount=12`, `max_used_time_delta=2.25`, `heat_capacity_limit=100`, `used=2.25`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_used_bridge_state(...)` heat cap: `matches=true`, `liquid_amount=12`, `max_used_time_delta=18`, `heat_capacity_limit=0.125`, `used=0.125`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1244")`: `status=done`, `nested_status=done`.
  - Result keys were limited to `coolant_guard`, `coolant_multiplier`, `heat_capacity_limit`, `liquid_amount`, `liquid_heat_capacity`, `max_used`, `max_used_time_delta`, `nonnegative_heat_capacity_limit`, `time_delta`, `used`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 449.90s (0:07:29)`.

## Progress

- Total source-backed slices: `1073`
- Done: `941`
- Not done: `132`
- Progress: `87.70%`
- Remaining: `12.30%`
- Current sequence next slice: `N1245 TractorBeamBuild.updateTile() coolant remove`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_coolant_remove_state`
