# N1231 ContinuousLiquidTurretBuild.acceptLiquid Finalize

## Scope
- Slice: `N1231`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurretBuild.acceptLiquid(Building source, Liquid liquid)`
- Godot owner: `PortGame.source_continuous_liquid_turret_build_accept_liquid_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_build_accept_liquid_bridge_state`

## Source Evidence
- `public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{`
- `boolean activated;`
- `@Override`
- `public boolean acceptLiquid(Building source, Liquid liquid){`
- `return ammoTypes.get(liquid) != null &&`
- `(liquids.current() == liquid ||`
- `((!ammoTypes.containsKey(liquids.current()) || liquids.get(liquids.current()) <= 1f / ammoTypes.get(liquids.current()).ammoMultiplier + 0.001f)));`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1231`.
- [x] Read SSOT roots and N1231 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurretBuild.acceptLiquid(Building source, Liquid liquid)`.
- [x] Added RED assertion for `N1231.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1231` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1231.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_build_accept_liquid_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.48s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP no-ammo case: `matches=true`, `accept_liquid=false`.
  - TCP same-liquid case: `matches=true`, `accept_liquid=true`.
  - TCP different-current-missing-ammo case: `matches=true`, `accept_liquid=true`, `replacement_allowed=true`.
  - TCP different-current-drained case at threshold `0.501`: `matches=true`, `accept_liquid=true`, `replacement_allowed=true`.
  - TCP different-current-too-full case: `matches=true`, `accept_liquid=false`, `replacement_allowed=false`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 379.10s (0:06:19)`

## Progress
- Total slices: `1073`
- Done: `928`
- Not done: `145`
- Active: `46`
- Source-backed not done: `99`
- Progress: `86.49%`
- Remaining: `13.51%`
- Next slice: `N1232 TractorBeamTurret.icons()`
- Next owner: `PortGame.source_tractor_beam_turret_icons_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1231`.
- Existing SSOT variable names `source_building`, `liquid`, `ammo_type`, `current_liquid`, `current_liquid_ammo_type_present`, `current_liquid_amount`, `current_ammo_multiplier`, `liquid_has_ammo_type`, `same_liquid`, `current_liquid_missing_ammo_type`, `current_required_with_epsilon`, `current_liquid_drained`, `replacement_allowed`, and `accept_liquid` are preserved.
- Deferred internals remain explicit: `ObjectMap<Liquid, BulletType>, LiquidModule, Building, and Liquid internals stay deferred; explicit inputs carry exact Java lookup results.` and `Replacement threshold is evaluated only on the Java short-circuit path where ammoTypes.get(liquid) is non-null, current liquid differs, and ammoTypes.containsKey(liquids.current()) is true.`
- Continue with max 1-3 source-backed slices per turn.
