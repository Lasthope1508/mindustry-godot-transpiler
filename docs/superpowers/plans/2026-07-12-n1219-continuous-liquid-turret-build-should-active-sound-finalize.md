# N1219 ContinuousLiquidTurretBuild.shouldActiveSound Finalize

## Scope
- Slice: `N1219`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurretBuild.shouldActiveSound()`
- Godot owner: `PortGame.source_continuous_liquid_turret_build_should_active_sound_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_build_should_active_sound_bridge_state`

## Source Evidence
- `public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{`
- `boolean activated;`
- `@Override`
- `public boolean shouldActiveSound(){`
- `return wasShooting && enabled;`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1219`.
- [x] Read SSOT roots and N1219 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurretBuild.shouldActiveSound()`.
- [x] Added RED assertion for `N1219.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1219` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1219.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean after clean rerun.
- [x] Godot stop returned clean final errors after clean rerun.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_build_should_active_sound_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.46s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 386.77s (0:06:26)`
- Godot MCP runtime:
  - Startup: `errors: []`
  - TCP `/root/Main.generated_continuous_liquid_turret_build_should_active_sound_bridge_state(false, false)`: `matches=true`, `should_active_sound=false`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_should_active_sound_bridge_state(true, false)`: `matches=true`, `should_active_sound=false`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_should_active_sound_bridge_state(true, true)`: `matches=true`, `should_active_sound=true`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1219")`: `entry.status=done`, `entry.slice.status=done`.
  - After clean TCP rerun: `errors: []`
  - Stop after clean TCP rerun: `finalErrors: []`

## Progress
- Total slices: `1073`
- Done: `916`
- Not done: `157`
- Active: `53`
- Progress: `85.37%`
- Remaining: `14.63%`
- Next slice: `N1220 ContinuousLiquidTurretBuild.getAmmoContent()`
- Next owner: `PortGame.source_continuous_liquid_turret_build_get_ammo_content_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1219`.
- First TCP probe used the wrong request framing and produced UTF-8 errors, so that dirty run was stopped and discarded.
- The recorded MCP proof is from a clean rerun with startup `errors: []`, post-TCP `errors: []`, and stop `finalErrors: []`.
- Continue with max 1-3 source-backed slices per turn.
