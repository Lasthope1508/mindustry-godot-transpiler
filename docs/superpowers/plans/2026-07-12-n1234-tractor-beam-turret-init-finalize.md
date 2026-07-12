# N1234 TractorBeamTurret.init Finalize

## Scope
- Slice: `N1234`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamTurret.init()`
- Godot owner: `PortGame.source_tractor_beam_turret_init_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_init_bridge_state`

## Source Evidence
- `@Override`
- `public void init(){`
- `super.init();`
- `updateClipRadius(range + tilesize);`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1234`.
- [x] Read SSOT roots and N1234 shard entries.
- [x] Read upstream Java `TractorBeamTurret.init()`.
- [x] Added RED assertion for `N1234.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1234` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1234.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_init_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected in 9.69s`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.49s`
- SSOT validator:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -c "from pathlib import Path; import json; from mindustry_port import source_ssot; r=source_ssot.validate_json_modules(Path('godot-mindustry')); d=next(m for m in r['modules'] if m['name']=='defense_slices')['canonical_mirror']['checked']; l=next(m for m in r['modules'] if m['name']=='source_slice_ledger_slices')['canonical_mirror']['checked']; print(json.dumps({'module_count':r['module_count'],'errors':r['errors'],'defense_checked':d,'ledger_checked':l}, separators=(',', ':')))"
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP case `range=80`, `tilesize=8`: `clip_radius=88`, `update_clip_radius_call.radius=88`, `matches=true`.
  - TCP case `range=123.5`, `tilesize=8`: `clip_radius=131.5`, `update_clip_radius_call.radius=131.5`, `matches=true`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 391.28s (0:06:31)`

## Progress
- Total slices: `1073`
- Done: `931`
- Not done: `142`
- Active: `43`
- Source-backed not done: `99`
- Progress: `86.77%`
- Remaining: `13.23%`
- Next slice: `N1235 TractorBeamBuild.shouldConsume()`
- Next owner: `PortGame.source_tractor_beam_turret_build_should_consume_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1234`.
- Existing SSOT variable names `range_value`, `source_tilesize`, and `clip_radius` are preserved.
- Deferred internals remain explicit: `Inherited BaseTurret.init internals and Block.updateClipRadius side effects remain deferred; this slice records the exact TractorBeamTurret updateClipRadius argument.`
- Continue with max 1-3 source-backed slices per turn.
