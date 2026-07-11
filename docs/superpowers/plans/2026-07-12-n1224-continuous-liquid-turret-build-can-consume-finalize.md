# N1224 ContinuousLiquidTurretBuild.canConsume Finalize

## Scope
- Slice: `N1224`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurretBuild.canConsume()`
- Godot owner: `PortGame.source_continuous_liquid_turret_build_can_consume_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_build_can_consume_bridge_state`

## Source Evidence
- `public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{`
- `boolean activated;`
- `@Override`
- `public boolean canConsume(){`
- `return hasCorrectAmmo() && super.canConsume();`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1224`.
- [x] Read SSOT roots and N1224 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurretBuild.canConsume()`.
- [x] Added RED assertion for `N1224.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1224` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1224.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_build_can_consume_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.47s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_can_consume_bridge_state(false, false)`: `matches=true`, `can_consume=false`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_can_consume_bridge_state(false, true)`: `matches=true`, `can_consume=false`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_can_consume_bridge_state(true, false)`: `matches=true`, `can_consume=false`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_can_consume_bridge_state(true, true)`: `matches=true`, `can_consume=true`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 395.87s (0:06:35)`

## Progress
- Total slices: `1073`
- Done: `921`
- Not done: `152`
- Active: `48`
- Progress: `85.83%`
- Remaining: `14.17%`
- Next slice: `N1225 ContinuousLiquidTurretBuild.shouldConsume()`
- Next owner: `PortGame.source_continuous_liquid_turret_build_should_consume_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1224`.
- Existing SSOT variable names `has_correct_ammo` and `super_can_consume` are preserved.
- Deferred internals remain explicit: `hasCorrectAmmo() internals` and `ContinuousTurretBuild.super.canConsume() internals`.
- Continue with max 1-3 source-backed slices per turn.
