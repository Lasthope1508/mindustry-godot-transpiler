# N1225 ContinuousLiquidTurretBuild.shouldConsume Finalize

## Scope
- Slice: `N1225`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurretBuild.shouldConsume()`
- Godot owner: `PortGame.source_continuous_liquid_turret_build_should_consume_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_build_should_consume_bridge_state`

## Source Evidence
- `public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{`
- `boolean activated;`
- `@Override`
- `public boolean shouldConsume(){`
- `return super.shouldConsume() && activated;`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1225`.
- [x] Read SSOT roots and N1225 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurretBuild.shouldConsume()`.
- [x] Added RED assertion for `N1225.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1225` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1225.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_build_should_consume_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.47s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_should_consume_bridge_state(false, false)`: `matches=true`, `should_consume=false`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_should_consume_bridge_state(false, true)`: `matches=true`, `should_consume=false`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_should_consume_bridge_state(true, false)`: `matches=true`, `should_consume=false`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_should_consume_bridge_state(true, true)`: `matches=true`, `should_consume=true`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 393.71s (0:06:33)`

## Progress
- Total slices: `1073`
- Done: `922`
- Not done: `151`
- Active: `47`
- Progress: `85.93%`
- Remaining: `14.07%`
- Next slice: `N1226 ContinuousLiquidTurretBuild.useAmmo()`
- Next owner: `PortGame.source_continuous_liquid_turret_build_use_ammo_state`
- Next status: `source-backed`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1225`.
- Existing SSOT variable names `super_should_consume` and `activated` are preserved.
- Deferred internals remain explicit: `ContinuousTurretBuild.super.shouldConsume() internals` and `activated lifecycle outside updateTile`.
- Continue with max 1-3 source-backed slices per turn.
