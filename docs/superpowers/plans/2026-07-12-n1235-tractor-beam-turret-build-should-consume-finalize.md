# N1235 TractorBeamBuild.shouldConsume Finalize

## Scope
- Slice: `N1235`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.shouldConsume()`
- Godot owner: `PortGame.source_tractor_beam_turret_build_should_consume_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_should_consume_bridge_state`

## Source Evidence
- `public class TractorBeamBuild extends BaseTurretBuild{`
- `public @Nullable Unit target;`
- `@Override`
- `public boolean shouldConsume(){`
- `return super.shouldConsume() && target != null;`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1235`.
- [x] Read SSOT roots and N1235 shard entries.
- [x] Read upstream Java `TractorBeamBuild.shouldConsume()`.
- [x] Added RED assertion for `N1235.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1235` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1235.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_should_consume_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected in 9.75s`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.46s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP case `super_should_consume=false`, `target=null`: `target_present=false`, `should_consume=false`, `matches=true`.
  - TCP case `super_should_consume=true`, `target=null`: `target_present=false`, `should_consume=false`, `matches=true`.
  - TCP case `super_should_consume=true`, `target={"id":"unit-target"}`: `target_present=true`, `should_consume=true`, `matches=true`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 393.61s (0:06:33)`

## Progress
- Total slices: `1073`
- Done: `932`
- Not done: `141`
- Active: `42`
- Source-backed not done: `99`
- Progress: `86.86%`
- Remaining: `13.14%`
- Next slice: `N1236 TractorBeamBuild.estimateDps()`
- Next owner: `PortGame.source_tractor_beam_turret_build_estimate_dps_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1235`.
- Existing SSOT variable names `super_should_consume`, `target`, `target_present`, and `should_consume` are preserved.
- Deferred internals remain explicit: `BaseTurretBuild.super.shouldConsume() internals`; `target acquisition lifecycle outside shouldConsume`.
- Continue with max 1-3 source-backed slices per turn.
