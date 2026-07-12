# N1229 ContinuousLiquidTurretBuild.hasCorrectAmmo Finalize

## Scope
- Slice: `N1229`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurretBuild.hasCorrectAmmo()`
- Godot owner: `PortGame.source_continuous_liquid_turret_build_has_correct_ammo_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_build_has_correct_ammo_bridge_state`

## Source Evidence
- `public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{`
- `boolean activated;`
- `public boolean hasCorrectAmmo(){`
- `return !bullets.any() || bullets.first().bullet.type == peekAmmo();`
- Upstream method has no `@Override`; no override marker is registered for this slice.

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1229`.
- [x] Read SSOT roots and N1229 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurretBuild.hasCorrectAmmo()`.
- [x] Added RED assertion for `N1229.status == done`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1229` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1229.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_build_has_correct_ammo_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'source-backed' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.45s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_has_correct_ammo_bridge_state(false, "ignored", "peek")`: `matches=true`, `has_correct_ammo=true`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_has_correct_ammo_bridge_state(true, "laser", "laser")`: `matches=true`, `has_correct_ammo=true`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_has_correct_ammo_bridge_state(true, "laser", "water")`: `matches=true`, `has_correct_ammo=false`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 388.33s (0:06:28)`

## Progress
- Total slices: `1073`
- Done: `926`
- Not done: `147`
- Active: `47`
- Source-backed not done: `100`
- Progress: `86.30%`
- Remaining: `13.70%`
- Next slice: `N1230 ContinuousLiquidTurretBuild.acceptItem(Building source, Item item)`
- Next owner: `PortGame.source_continuous_liquid_turret_build_accept_item_state`
- Next status: `source-backed`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1229`.
- Existing SSOT variable names `bullets_any`, `first_bullet_type`, `peek_ammo`, and `has_correct_ammo` are preserved.
- Deferred internals remain explicit: `Bullet sequence internals stay deferred; this slice uses explicit inputs for bullets.any() and bullets.first().bullet.type.` and `peekAmmo() internals are covered by N1227 and supplied as explicit input.`
- Continue with max 1-3 source-backed slices per turn.
