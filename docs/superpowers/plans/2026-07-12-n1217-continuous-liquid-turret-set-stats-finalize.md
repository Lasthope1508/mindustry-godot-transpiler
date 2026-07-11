# N1217 ContinuousLiquidTurret.setStats Finalize

## Scope
- Slice: `N1217`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurret.setStats()`
- Godot owner: `PortGame.source_continuous_liquid_turret_set_stats_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_set_stats_bridge_state`

## Source Evidence
- `@Override`
- `public void setStats(){`
- `super.setStats();`
- `//mirror stats onto each bullet (purely visual)`
- `ammoTypes.each((l, b) -> b.statLiquidConsumed = liquidConsumed);`
- `stats.replace(Stat.ammo, StatValues.ammo(ammoTypes));`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1217`.
- [x] Read SSOT roots and N1217 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurret.setStats()`.
- [x] Added RED assertion for `N1217.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1217` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1217.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_set_stats_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.47s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 391.42s (0:06:31)`
- Godot MCP runtime:
  - Startup: `errors: []`
  - TCP `/root/Main.generated_continuous_liquid_turret_set_stats_bridge_state([], 1/60)`: `matches=true`, `update_count=0`, `stats_replace_matches=true`.
  - TCP `/root/Main.generated_continuous_liquid_turret_set_stats_bridge_state([{liquid:"water", bullet:"continuousWater"}], 0.25)`: `matches=true`, `update_count=1`, `stat_liquid_consumed_values=[0.25]`.
  - TCP `/root/Main.generated_continuous_liquid_turret_set_stats_bridge_state([{liquid:"water", bullet:"continuousWater"}, {liquid:"slag", bullet:"continuousSlag"}], 0.5)`: `matches=true`, `update_count=2`, `stat_liquid_consumed_values=[0.5,0.5]`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1217")`: `entry.status=done`, `entry.slice.status=done`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`

## Progress
- Total slices: `1073`
- Done: `914`
- Not done: `159`
- Active: `55`
- Progress: `85.18%`
- Remaining: `14.82%`
- Next slice: `N1218 ContinuousLiquidTurret.init()`
- Next owner: `PortGame.source_continuous_liquid_turret_init_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1217`.
- Continue with max 1-3 source-backed slices per turn.
