# N1223 ContinuousLiquidTurretBuild.senseObject Finalize

## Scope
- Slice: `N1223`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurretBuild.senseObject(LAccess sensor)`
- Godot owner: `PortGame.source_continuous_liquid_turret_build_sense_object_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_build_sense_object_bridge_state`

## Source Evidence
- `public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{`
- `boolean activated;`
- `@Override`
- `public Object senseObject(LAccess sensor){`
- `return switch(sensor){`
- `case currentAmmoType -> liquids.current();`
- `default -> super.senseObject(sensor);`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1223`.
- [x] Read SSOT roots and N1223 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurretBuild.senseObject(LAccess sensor)`.
- [x] Added RED assertion for `N1223.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1223` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1223.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_build_sense_object_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.48s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_sense_object_bridge_state("currentAmmoType", "water", "fallback")`: `matches=true`, `sense_object_value="water"`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_sense_object_bridge_state("enabled", "slag", true)`: `matches=true`, `sense_object_value=true`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_sense_object_bridge_state("health", null, 42.5)`: `matches=true`, `sense_object_value=42.5`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 398.44s (0:06:38)`

## Progress
- Total slices: `1073`
- Done: `920`
- Not done: `153`
- Active: `49`
- Progress: `85.74%`
- Remaining: `14.26%`
- Next slice: `N1224 ContinuousLiquidTurretBuild.canConsume()`
- Next owner: `PortGame.source_continuous_liquid_turret_build_can_consume_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1223`.
- Existing SSOT variable names `sensor`, `current_liquid`, and `super_sense_object_value` are preserved.
- Deferred internals remain explicit: `ContinuousTurretBuild.super.senseObject(sensor) internals` and `Liquid module internals`.
- Continue with max 1-3 source-backed slices per turn.
