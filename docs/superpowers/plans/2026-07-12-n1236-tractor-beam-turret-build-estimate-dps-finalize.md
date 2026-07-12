# N1236 TractorBeamBuild.estimateDps Finalize

## Scope
- Slice: `N1236`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.estimateDps()`
- Godot owner: `PortGame.source_tractor_beam_turret_build_estimate_dps_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_estimate_dps_bridge_state`

## Source Evidence
- `public class TractorBeamBuild extends BaseTurretBuild{`
- `public boolean any;`
- `public float coolantMultiplier = 1f;`
- `@Override`
- `public float estimateDps(){`
- `if(!any || damage <= 0) return 0f;`
- `return damage * 60f * efficiency * coolantMultiplier;`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1236`.
- [x] Read SSOT roots and N1236 shard entries.
- [x] Read upstream Java `TractorBeamBuild.estimateDps()`.
- [x] Added RED assertion for `N1236.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1236` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1236.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_estimate_dps_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected in 9.90s`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.45s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP case `any_state=false`, `damage=2`, `efficiency=0.5`, `coolant_multiplier=1.5`: `zero_guard=true`, `estimate_dps=0`, `matches=true`.
  - TCP case `any_state=true`, `damage=0`, `efficiency=0.5`, `coolant_multiplier=1.5`: `zero_guard=true`, `estimate_dps=0`, `matches=true`.
  - TCP case `any_state=true`, `damage=2`, `efficiency=0.5`, `coolant_multiplier=1.5`: `zero_guard=false`, `estimate_dps=90`, `matches=true`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 402.76s (0:06:42)`

## Progress
- Total slices: `1073`
- Done: `933`
- Not done: `140`
- Active: `41`
- Source-backed not done: `99`
- Progress: `86.95%`
- Remaining: `13.05%`
- Next slice: `N1237 TractorBeamBuild.write(Writes write)`
- Next owner: `PortGame.source_tractor_beam_turret_build_write_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1236`.
- Existing SSOT variable names `any_state`, `damage`, `efficiency`, `coolant_multiplier`, `zero_guard`, and `estimate_dps` are preserved.
- Deferred internals remain explicit: `BaseTurretBuild inherited efficiency lifecycle`; `TractorBeamBuild any lifecycle outside estimateDps`; `coolantMultiplier update lifecycle outside estimateDps`.
- Continue with max 1-3 source-backed slices per turn.
