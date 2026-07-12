# N1228 ContinuousLiquidTurretBuild.hasAmmo Finalize

## Scope
- Slice: `N1228`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurretBuild.hasAmmo()`
- Godot owner: `PortGame.source_continuous_liquid_turret_build_has_ammo_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_build_has_ammo_bridge_state`

## Source Evidence
- `public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{`
- `boolean activated;`
- `@Override`
- `public boolean hasAmmo(){`
- `return hasCorrectAmmo() && ammoTypes.get(liquids.current()) != null && liquids.currentAmount() > 0f && activated;`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1228`.
- [x] Read SSOT roots and N1228 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurretBuild.hasAmmo()`.
- [x] Added RED assertion for `N1228.status == done`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1228` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1228.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_build_has_ammo_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'source-backed' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.47s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_has_ammo_bridge_state(true, "water", "continuousWater", 3.0, true)`: `matches=true`, `has_ammo=true`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_has_ammo_bridge_state(false, "water", "continuousWater", 3.0, true)`: `matches=true`, `has_ammo=false`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_has_ammo_bridge_state(true, "water", null, 3.0, true)`: `matches=true`, `has_ammo=false`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_has_ammo_bridge_state(true, "water", "continuousWater", 0.0, true)`: `matches=true`, `has_ammo=false`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_has_ammo_bridge_state(true, "water", "continuousWater", 3.0, false)`: `matches=true`, `has_ammo=false`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 379.54s (0:06:19)`

## Progress
- Total slices: `1073`
- Done: `925`
- Not done: `148`
- Active: `47`
- Progress: `86.21%`
- Remaining: `13.79%`
- Next slice: `N1229 ContinuousLiquidTurretBuild.hasCorrectAmmo()`
- Next owner: `PortGame.source_continuous_liquid_turret_build_has_correct_ammo_state`
- Next status: `source-backed`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1228`.
- Existing SSOT variable names `has_correct_ammo`, `current_liquid`, `ammo_type`, `current_amount`, and `activated` are preserved.
- Deferred internals remain explicit: `hasCorrectAmmo() internals are migrated separately.` and `ObjectMap ammoTypes lookup and LiquidModule internals stay deferred; this slice uses explicit inputs.`
- Continue with max 1-3 source-backed slices per turn.
