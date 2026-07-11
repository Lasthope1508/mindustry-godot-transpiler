# N1213 Turret.setBars Finalize

## Scope
- Slice: `N1213`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java`
- Java method: `setBars()`
- Godot owner: `PortGame.source_turret_set_bars_state`
- Runtime proof: `/root/Main.generated_turret_set_bars_bridge_state`

## Source Evidence
- `@Override`
- `public void setBars(){`
- `super.setBars();`
- `if(heatRequirement > 0){`
- `addBar("heat", (TurretBuild entity) ->`
- `new Bar(() ->`
- `Core.bundle.format("bar.heatpercent", (int)entity.heatReq, (int)(Math.min(entity.heatReq / heatRequirement, maxHeatEfficiency) * 100)),`
- `() -> Pal.lightOrange,`
- `() -> entity.heatReq / heatRequirement));`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1213`.
- [x] Read SSOT roots and N1213 shard entries.
- [x] Read upstream Java `Turret.setBars()`.
- [x] Added RED assertion for `N1213.status == done`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1213` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1213.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_turret_set_bars_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'source-backed' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.46s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 397.21s (0:06:37)`
- Godot MCP runtime:
  - Startup: `errors: []`
  - TCP `/root/Main.generated_turret_set_bars_bridge_state(0.0, 5.0, 3.0)`: `matches=true`, `heat_bar_added=false`, empty text/bar call, empty color, percent `0`, fraction `0`.
  - TCP `/root/Main.generated_turret_set_bars_bridge_state(10.0, 4.0, 3.0)`: `matches=true`, key `bar.heatpercent`, heat req `4`, percent `40`, color `Pal.lightOrange`, fraction `0.4`.
  - TCP `/root/Main.generated_turret_set_bars_bridge_state(10.0, 40.0, 2.5)`: `matches=true`, key `bar.heatpercent`, heat req `40`, percent `250`, color `Pal.lightOrange`, fraction `4`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1213")`: `status=done`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`

## Progress
- Total slices: `1073`
- Done: `910`
- Not done: `163`
- Active: `59`
- Progress: `84.81%`
- Remaining: `15.19%`
- Next slice: `N1214 ItemTurret.ammo(Object...)`
- Next owner: `PortGame.source_item_turret_ammo_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1213`.
- Continue with max 1-3 source-backed slices per turn.
