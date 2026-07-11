# N1221 ContinuousLiquidTurretBuild.getAmmoFraction Finalize

## Scope
- Slice: `N1221`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurretBuild.getAmmoFraction()`
- Godot owner: `PortGame.source_continuous_liquid_turret_build_get_ammo_fraction_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_build_get_ammo_fraction_bridge_state`

## Source Evidence
- `public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{`
- `boolean activated;`
- `@Override`
- `public float getAmmoFraction(){`
- `return liquids.currentAmount() / liquidCapacity;`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1221`.
- [x] Read SSOT roots and N1221 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurretBuild.getAmmoFraction()`.
- [x] Added RED assertion for `N1221.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1221` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1221.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_build_get_ammo_fraction_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.48s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 395.39s (0:06:35)`
- Godot MCP runtime:
  - Startup: `errors: []`
  - TCP `/root/Main.generated_continuous_liquid_turret_build_get_ammo_fraction_bridge_state(0.0, 10.0)`: `matches=true`, `ammo_fraction=0`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_get_ammo_fraction_bridge_state(5.0, 20.0)`: `matches=true`, `ammo_fraction=0.25`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_get_ammo_fraction_bridge_state(12.5, 50.0)`: `matches=true`, `ammo_fraction=0.25`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1221")`: `entry.status=done`, `entry.slice.status=done`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`

## Progress
- Total slices: `1073`
- Done: `918`
- Not done: `155`
- Active: `51`
- Progress: `85.55%`
- Remaining: `14.45%`
- Next slice: `N1222 ContinuousLiquidTurretBuild.updateTile()`
- Next owner: `PortGame.source_continuous_liquid_turret_build_update_tile_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1221`.
- Existing SSOT variable names `current_amount` and `liquid_capacity` are preserved.
- Continue with max 1-3 source-backed slices per turn.
