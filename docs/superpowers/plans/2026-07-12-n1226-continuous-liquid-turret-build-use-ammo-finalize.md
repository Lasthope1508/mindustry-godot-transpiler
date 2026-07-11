# N1226 ContinuousLiquidTurretBuild.useAmmo Finalize

## Scope
- Slice: `N1226`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurretBuild.useAmmo()`
- Godot owner: `PortGame.source_continuous_liquid_turret_build_use_ammo_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_build_use_ammo_bridge_state`

## Source Evidence
- `public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{`
- `boolean activated;`
- `@Override`
- `public BulletType useAmmo(){`
- `//does not consume ammo upon firing`
- `return peekAmmo();`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1226`.
- [x] Read SSOT roots and N1226 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurretBuild.useAmmo()`.
- [x] Added RED assertion for `N1226.status == done`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1226` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1226.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_build_use_ammo_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'source-backed' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.47s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_use_ammo_bridge_state(null)`: `matches=true`, `returned_ammo=null`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_use_ammo_bridge_state("continuousWater")`: `matches=true`, `returned_ammo="continuousWater"`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_use_ammo_bridge_state({"name":"meltdownLaser"})`: `matches=true`, `returned_ammo={"name":"meltdownLaser"}`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 394.40s (0:06:34)`

## Progress
- Total slices: `1073`
- Done: `923`
- Not done: `150`
- Active: `47`
- Progress: `86.02%`
- Remaining: `13.98%`
- Next slice: `N1227 ContinuousLiquidTurretBuild.peekAmmo()`
- Next owner: `PortGame.source_continuous_liquid_turret_build_peek_ammo_state`
- Next status: `source-backed`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1226`.
- Existing SSOT variable name `peek_ammo` is preserved.
- Deferred internals remain explicit: `peekAmmo() internals and ammoTypes/liquids lookup are migrated in the peekAmmo slice.` and `BulletType internals stay deferred; this slice passes through the explicit peekAmmo result.`
- Continue with max 1-3 source-backed slices per turn.
