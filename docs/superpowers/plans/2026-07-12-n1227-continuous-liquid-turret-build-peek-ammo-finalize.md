# N1227 ContinuousLiquidTurretBuild.peekAmmo Finalize

## Scope
- Slice: `N1227`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurretBuild.peekAmmo()`
- Godot owner: `PortGame.source_continuous_liquid_turret_build_peek_ammo_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_build_peek_ammo_bridge_state`

## Source Evidence
- `public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{`
- `boolean activated;`
- `@Override`
- `public BulletType peekAmmo(){`
- `return ammoTypes.get(liquids.current());`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1227`.
- [x] Read SSOT roots and N1227 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurretBuild.peekAmmo()`.
- [x] Added RED assertion for `N1227.status == done`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1227` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1227.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_build_peek_ammo_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'source-backed' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.48s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_peek_ammo_bridge_state("water", null)`: `matches=true`, `peek_ammo=null`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_peek_ammo_bridge_state("water", "continuousWater")`: `matches=true`, `peek_ammo="continuousWater"`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_peek_ammo_bridge_state("slag", {"name":"meltdownLaser"})`: `matches=true`, `peek_ammo={"name":"meltdownLaser"}`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 391.20s (0:06:31)`

## Progress
- Total slices: `1073`
- Done: `924`
- Not done: `149`
- Active: `47`
- Progress: `86.11%`
- Remaining: `13.89%`
- Next slice: `N1228 ContinuousLiquidTurretBuild.hasAmmo()`
- Next owner: `PortGame.source_continuous_liquid_turret_build_has_ammo_state`
- Next status: `source-backed`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1227`.
- Existing SSOT variable names `current_liquid` and `ammo_type` are preserved.
- Deferred internals remain explicit: `ObjectMap ammoTypes lookup internals stay deferred; this slice records lookup result through explicit ammo_type input.` and `LiquidModule current liquid internals stay deferred; this slice records current liquid through explicit current_liquid input.`
- Continue with max 1-3 source-backed slices per turn.
