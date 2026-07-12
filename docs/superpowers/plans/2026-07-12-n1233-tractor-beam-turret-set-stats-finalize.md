# N1233 TractorBeamTurret.setStats Finalize

## Scope
- Slice: `N1233`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamTurret.setStats()`
- Godot owner: `PortGame.source_tractor_beam_turret_set_stats_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_set_stats_bridge_state`

## Source Evidence
- `@Override`
- `public void setStats(){`
- `super.setStats();`
- `stats.add(Stat.targetsAir, targetAir);`
- `stats.add(Stat.targetsGround, targetGround);`
- `if(damage > 0) stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1233`.
- [x] Read SSOT roots and N1233 shard entries.
- [x] Read upstream Java `TractorBeamTurret.setStats()`.
- [x] Added RED assertion for `N1233.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1233` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1233.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_set_stats_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.47s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Runtime: TCP port `7777`.
  - Zero damage case: `target_air=true`, `target_ground=false`, `damage=0.0`, `damage_stat_added=false`, `damage_per_second=0`, `matches=true`.
  - Positive damage case: `target_air=true`, `target_ground=true`, `damage=2.5`, `damage_stat_added=true`, `damage_per_second=150`, `damage_stat_call.value=150`, `matches=true`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 374.87s (0:06:14)`

## Progress
- Total slices: `1073`
- Done: `930`
- Not done: `143`
- Active: `44`
- Source-backed not done: `99`
- Progress: `86.67%`
- Remaining: `13.33%`
- Next slice: `N1234 TractorBeamTurret.init()`
- Next owner: `PortGame.source_tractor_beam_turret_init_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1233`.
- Existing SSOT variable names `target_air`, `target_ground`, `damage`, and `damage_per_second` are preserved.
- Deferred internals remain explicit: `Stats storage, Stat objects, StatUnit formatting, and inherited BaseTurret.setStats internals remain deferred; this slice records exact TractorBeamTurret stat calls and computed damage per second.`
- Continue with max 1-3 source-backed slices per turn.
