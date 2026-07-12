# N1232 TractorBeamTurret.icons Finalize

## Scope
- Slice: `N1232`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamTurret.icons()`
- Godot owner: `PortGame.source_tractor_beam_turret_icons_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_icons_bridge_state`

## Source Evidence
- `public @Load(value = "@-base", fallback = "block-@size") TextureRegion baseRegion;`
- `@Override`
- `public TextureRegion[] icons(){`
- `return new TextureRegion[]{baseRegion, region};`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1232`.
- [x] Read SSOT roots and N1232 shard entries.
- [x] Read upstream Java `TractorBeamTurret.icons()`.
- [x] Added RED assertion for `N1232.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1232` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1232.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.
- [x] Full Python suite passed.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_icons_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.46s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Godot MCP runtime:
  - Startup: Godot `4.6.2.stable.official.71f334935`, TCP port `7777`.
  - TCP string regions case: `matches=true`, `icons=["tractor-base","tractor-top"]`.
  - TCP dictionary regions case: `matches=true`, `icons=[{"id":"tractor-base"},{"id":"tractor-top"}]`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 398.68s (0:06:38)`

## Progress
- Total slices: `1073`
- Done: `929`
- Not done: `144`
- Active: `45`
- Source-backed not done: `99`
- Progress: `86.58%`
- Remaining: `13.42%`
- Next slice: `N1233 TractorBeamTurret.setStats()`
- Next owner: `PortGame.source_tractor_beam_turret_set_stats_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1232`.
- Existing SSOT variable names `base_region`, `region`, and `icons` are preserved.
- Deferred internals remain explicit: `TextureRegion internals and inherited region loading remain deferred; explicit inputs carry baseRegion and region field values.`
- Continue with max 1-3 source-backed slices per turn.
