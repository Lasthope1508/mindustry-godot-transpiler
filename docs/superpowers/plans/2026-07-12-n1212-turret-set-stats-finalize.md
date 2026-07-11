# N1212 Turret.setStats Finalize

## Scope
- Slice: `N1212`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java`
- Java method: `setStats()`
- Godot owner: `PortGame.source_turret_set_stats_state`
- Runtime proof: `/root/Main.generated_turret_set_stats_bridge_state`

## Source Evidence
- `@Override`
- `public void setStats(){`
- `super.setStats();`
- `stats.add(Stat.inaccuracy, (int)inaccuracy, StatUnit.degrees);`
- `stats.add(Stat.reload, 60f / (reload + (!reloadWhileCharging ? shoot.firstShotDelay : 0f)) * shoot.shots, StatUnit.perSecond);`
- `stats.add(Stat.targetsAir, targetAir);`
- `stats.add(Stat.targetsGround, targetGround);`
- `if(ammoPerShot != 1) stats.add(Stat.ammoUse, ammoPerShot, StatUnit.perShot);`
- `if(heatRequirement > 0) stats.add(Stat.input, heatRequirement, StatUnit.heatUnits);`
- `if(heatRequirement > 0 && maxHeatEfficiency > 0) stats.add(Stat.maxEfficiency, (int)(maxHeatEfficiency * 100f), StatUnit.percent);`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1212`.
- [x] Read SSOT roots and N1212 shard entries.
- [x] Read upstream Java `Turret.setStats()`.
- [x] Added RED assertion for `N1212.status == done`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1212` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1212.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_turret_set_stats_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'source-backed' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.48s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 394.81s (0:06:34)`
- Godot MCP runtime:
  - Startup: `errors: []`
  - TCP `/root/Main.generated_turret_set_stats_bridge_state(3.8, 5.0, false, 5.0, 2.0, true, false, 1, 0.0, 0.0)`: `matches=true`, denominator `10`, reload value `12`, guarded stat calls empty.
  - TCP `/root/Main.generated_turret_set_stats_bridge_state(7.2, 10.0, false, 20.0, 3.0, false, true, 2, 5.0, 2.5)`: `matches=true`, denominator `30`, reload value `6`, ammo use value `2`, input heat value `5`, max efficiency value `250`.
  - TCP `/root/Main.generated_turret_set_stats_bridge_state(1.0, 15.0, true, 40.0, 1.0, true, true, 1, 4.0, 0.0)`: `matches=true`, denominator `15`, reload value `4`, input heat value `4`, max efficiency call empty.
  - TCP `/root/Main.ssot_slice_ledger_state("N1212")`: `status=done`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`

## Progress
- Total slices: `1073`
- Done: `909`
- Not done: `164`
- Active: `59`
- Progress: `84.72%`
- Remaining: `15.28%`
- Next slice: `N1213 Turret.setBars()`
- Next owner: `PortGame.source_turret_set_bars_state`
- Next status: `source-backed`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1212`.
- Continue with max 1-3 source-backed slices per turn.
