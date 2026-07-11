# N1210 BaseTurret.setStats Finalize

## Scope

- Slice: `N1210`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java`
- Java method: `setStats()`
- Godot owner: `PortGame.source_base_turret_set_stats_state`
- Bridge: `/root/Main.generated_base_turret_set_stats_bridge_state`
- Generated method: `BaseTurret.java_method_setStats_4`

## Source Evidence

- `@Override`
- `public void setStats(){`
- `super.setStats();`
- `stats.add(Stat.shootRange, range / tilesize, StatUnit.blocks);`
- `if(activationTime > 0) stats.add(Stat.activationTime, activationTime / 60f, StatUnit.seconds);`

## Deferred

- `super.setStats()` internals stay deferred to Block superclass source.
- `Stats` storage and `StatUnit` display internals stay deferred to stats/UI source.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read SSOT roots and shards:
  - `source_symbol_registry.json`
  - `source_symbol_audit_report.json`
  - `source_slice_ledger.json`
  - `source_api_contracts.json`
  - `source_state_schema.json`
  - `source_ssot_modules.json`
  - `source_modules/defense_slices.json`
  - `source_modules/source_slice_ledger_slices.json`
- [x] Read exact upstream Java `BaseTurret.setStats()`.
- [x] RED status assertion added for `N1210`.
- [x] RED focused test failed as expected with `active != done`: `1 failed, 1064 deselected in 9.69s`.
- [x] GREEN status flipped to `done` in canonical ledger and both shards.
- [x] Focused tests passed: `1 passed, 1064 deselected in 0.51s`.
- [x] SSOT validator passed:
  - `module_count=112`
  - `errors=[]`
  - `defense_checked=137`
  - `ledger_checked=1073`
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 393.69s (0:06:33)`.
- [x] Godot MCP runtime startup passed with `errors=[]`.
- [x] TCP runtime proof passed with one socket per call:
  - Activation positive: `matches=true`, `super_set_stats_called=true`, `shoot_range_blocks=10`, `activation_time_stat_called=true`, activation stat value `2`.
  - Activation zero: `matches=true`, `super_set_stats_called=true`, `shoot_range_blocks=10`, `activation_time_stat_called=false`, activation stat call `{}`.
  - Non-default range: `matches=true`, `super_set_stats_called=true`, `shoot_range_blocks=17`, `activation_time_stat_called=true`, activation stat value `1`.
  - Ledger proof: `N1210.entry.status=done`, nested `entry.slice.status=done`.
- [x] Godot MCP debug output after runtime proof passed with `errors=[]`.
- [x] Godot MCP stop passed with `finalErrors=[]`.

## Progress After N1210

- Total slices: `1073`
- Done: `907`
- Not done: `166`
- Progress: `84.53%`
- Next slice: `N1211 BaseTurret.setBars()`
