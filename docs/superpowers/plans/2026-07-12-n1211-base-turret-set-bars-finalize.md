# N1211 BaseTurret.setBars Finalize

## Scope
- Slice: `N1211`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java`
- Java method: `setBars()`
- Godot owner: `PortGame.source_base_turret_set_bars_state`
- Runtime proof: `/root/Main.generated_base_turret_set_bars_bridge_state`

## Source Evidence
- `@Override`
- `public void setBars(){`
- `super.setBars();`
- `if(activationTime > 0){`
- `addBar("activationtimer", (BaseTurretBuild entity) ->`
- `new Bar(() ->`
- `(entity.activationTimer > 0)? Core.bundle.format("bar.activationtimer", Mathf.ceil(entity.activationTimer / 60f)) : Core.bundle.get("bar.activated")`
- `() -> (entity.activationTimer > 0)?  Pal.lightOrange : Pal.techBlue`
- `() -> 1 - entity.activationTimer / activationTime`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1211`.
- [x] Read SSOT roots and N1211 shard entries.
- [x] Read upstream Java `BaseTurret.setBars()`.
- [x] Added RED assertion for `N1211.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1211` status to `done` in canonical ledger and shards.
- [x] Fixed nested `source_slice_ledger_slices.N1211.slice.status` mirror.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_base_turret_set_bars_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.47s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 389.30s (0:06:29)`
- Godot MCP runtime:
  - Startup: `errors: []`
  - TCP `/root/Main.generated_base_turret_set_bars_bridge_state(0.0, 0.0)`: `matches=true`, `activation_bar_added=false`, `activation_bar_fraction=0`, empty text/color/call.
  - TCP `/root/Main.generated_base_turret_set_bars_bridge_state(120.0, 61.0)`: `matches=true`, key `bar.activationtimer`, seconds `2`, color `Pal.lightOrange`, fraction `0.491666666666667`.
  - TCP `/root/Main.generated_base_turret_set_bars_bridge_state(120.0, 0.0)`: `matches=true`, key `bar.activated`, color `Pal.techBlue`, fraction `1`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1211")`: `status=done`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`

## Progress
- Total slices: `1073`
- Done: `908`
- Not done: `165`
- Active: `59`
- Progress: `84.62%`
- Remaining: `15.38%`
- Next slice: `N1212 Turret.setStats()`
- Next owner: `PortGame.source_turret_set_stats_state`
- Next status: `source-backed`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1211`.
- Continue with max 1-3 source-backed slices per turn.
