# N1215 ContinuousTurret.setStats Finalize

## Scope
- Slice: `N1215`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java`
- Java method: `ContinuousTurret.setStats()`
- Godot owner: `PortGame.source_continuous_turret_set_stats_state`
- Runtime proof: `/root/Main.generated_continuous_turret_set_stats_bridge_state`

## Source Evidence
- `@Override`
- `public void setStats(){`
- `super.setStats();`
- `stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));`
- `stats.remove(Stat.reload);`
- `stats.remove(Stat.inaccuracy);`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1215`.
- [x] Read SSOT roots and N1215 shard entries.
- [x] Read upstream Java `ContinuousTurret.setStats()`.
- [x] Added RED assertion for `N1215.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1215` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1215.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_turret_set_stats_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.48s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 388.24s (0:06:28)`
- Godot MCP runtime:
  - Startup: `errors: []`
  - TCP `/root/Main.generated_continuous_turret_set_stats_bridge_state(null)`: `matches=true`, `generated_owner=ContinuousTurret.java_method_setStats_0`, `remove_reload_called=true`, `remove_inaccuracy_called=true`, `stats_add_call.stat=Stat.ammo`.
  - TCP `/root/Main.generated_continuous_turret_set_stats_bridge_state({name:"continuous-laser", damage:42, lifetime:12.5})`: `matches=true`, `shoot_type_matches=true`, `stats_add_matches=true`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1215")`: `entry.status=done`, `entry.slice.status=done`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`

## Progress
- Total slices: `1073`
- Done: `912`
- Not done: `161`
- Active: `57`
- Progress: `85.00%`
- Remaining: `15.00%`
- Next slice: `N1216 ContinuousLiquidTurret.ammo(Object...)`
- Next owner: `PortGame.source_continuous_liquid_turret_ammo_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1215`.
- Continue with max 1-3 source-backed slices per turn.
