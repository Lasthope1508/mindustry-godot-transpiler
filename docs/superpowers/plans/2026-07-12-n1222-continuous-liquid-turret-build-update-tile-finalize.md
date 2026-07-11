# N1222 ContinuousLiquidTurretBuild.updateTile Finalize

## Scope
- Slice: `N1222`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurretBuild.updateTile()`
- Godot owner: `PortGame.source_continuous_liquid_turret_build_update_tile_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_build_update_tile_bridge_state`

## Source Evidence
- `public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{`
- `boolean activated;`
- `@Override`
- `public void updateTile(){`
- `super.updateTile();`
- `//only allow the turret to begin firing when it can fire for 4 continuous updates`
- `if(liquids.currentAmount() >= liquidConsumed * 4f){`
- `activated = true;`
- `}else if(liquids.currentAmount() < liquidConsumed){`
- `activated = false;`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1222`.
- [x] Read SSOT roots and N1222 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurretBuild.updateTile()`.
- [x] Added RED assertion for `N1222.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1222` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1222.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_build_update_tile_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.46s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 387.12s (0:06:27)`
- Godot MCP runtime:
  - Startup: `errors: []`
  - TCP `/root/Main.generated_continuous_liquid_turret_build_update_tile_bridge_state(8.0, 2.0, false)`: `matches=true`, `activated_after=true`, `super_update_tile_called=true`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_update_tile_bridge_state(1.0, 2.0, true)`: `matches=true`, `activated_after=false`, `super_update_tile_called=true`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_update_tile_bridge_state(3.0, 2.0, true)`: `matches=true`, `activated_after=true`, `super_update_tile_called=true`.
  - TCP `/root/Main.generated_continuous_liquid_turret_build_update_tile_bridge_state(3.0, 2.0, false)`: `matches=true`, `activated_after=false`, `super_update_tile_called=true`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1222")`: `entry.status=done`, `entry.slice.status=done`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`

## Progress
- Total slices: `1073`
- Done: `919`
- Not done: `154`
- Active: `50`
- Progress: `85.65%`
- Remaining: `14.35%`
- Next slice: `N1223 ContinuousLiquidTurretBuild.senseObject(LAccess sensor)`
- Next owner: `PortGame.source_continuous_liquid_turret_build_sense_object_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1222`.
- Existing SSOT variable names `current_amount`, `liquid_consumed`, and `activated_before` are preserved.
- Continue with max 1-3 source-backed slices per turn.
