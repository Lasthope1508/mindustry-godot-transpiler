# N1243 TractorBeamBuild.updateTile Coolant Guard Finalize

## Scope

- Slice: `N1243`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() coolant guard`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_coolant_guard_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_guard_bridge_state`

## Source Evidence

```java
//consume coolant
if(target != null && coolant != null){
    float maxUsed = coolant.amount;

    Liquid liquid = liquids.current();

    float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1243 SSOT ledger, API contract, state schema, module registration.
- [x] Read upstream Java source lines for N1243.
- [x] Added RED status assertion for `N1243`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1243` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `coolant_guard_result`.
- [x] Added `coolant_guard_result` subset in `PortGame.gd` to return only N1243 coolant guard fields.
- [x] Focused GREEN passed for bridge subset.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_coolant_guard_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_coolant_guard_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_coolant_guard_bridge_state`
  - Result: failed as expected because `var coolant_guard_result := {` was missing.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_coolant_guard_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- SSOT:
  - Command: `source_ssot.validate_json_modules(Path("godot-mindustry"))`
  - Result: `{"module_count":112,"errors":[]}`.
- Godot MCP runtime proof:
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_guard_bridge_state(...)` early: `matches=true`, `returned_early=true`, `coolant_guard=false`, `max_used=0`, `liquid=null`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_guard_bridge_state(...)` no target: `matches=true`, `returned_early=false`, `target_after=null`, `coolant_guard=false`, `max_used=0`, `liquid=null`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_guard_bridge_state(...)` no coolant: `matches=true`, `target_after={id:"target"}`, `coolant_present=false`, `coolant_guard=false`, `max_used=0`, `liquid=null`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_coolant_guard_bridge_state(...)` coolant: `matches=true`, `target_after={id:"target"}`, `coolant_present=true`, `coolant_guard=true`, `max_used=9`, `liquid="water"`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1243")`: `status=done`, `nested_status=done`.
  - Result keys were limited to `coolant_amount`, `coolant_evaluated`, `coolant_guard`, `coolant_present`, `current_liquid`, `liquid`, `max_used`, `returned_early`, `target_after`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 440.06s (0:07:20)`.

## Progress

- Total source-backed slices: `1073`
- Done: `940`
- Not done: `133`
- Progress: `87.60%`
- Remaining: `12.40%`
- Current sequence next slice: `N1244 TractorBeamBuild.updateTile() coolant used`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_coolant_used_state`
