# N1194 LiquidTurret.setStats Finalize

## Scope

- Slice: `N1194`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurret.setStats()`
- Godot owner: `PortGame.source_liquid_turret_set_stats_state`
- Runtime proof: `/root/Main.generated_liquid_turret_set_stats_bridge_state`

## Source Evidence

Exact upstream expressions preserved:

- `@Override`
- `public void setStats(){`
- `super.setStats();`
- `stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));`

Deferred:

- `StatValues.ammo(ammoTypes, name)` internals.
- Concrete `Stats`, `ObjectMap`, `Liquid`, and `BulletType` behavior beyond explicit call payload.
- `LiquidTurret.init()` starts at `N1195`.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read migration spec entry for `N1194`.
- [x] Read SSOT roots and N1194 shards.
- [x] Read exact upstream Java method.
- [x] Added RED status assertion in `test_generated_liquid_turret_set_stats_slice_is_registered_with_source_backing`.
- [x] RED failed for expected reason: `active != done`.
- [x] GREEN updated N1194 status in canonical ledger and mirror shards.
- [x] Focused tests passed: `5 passed`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed`.
- [x] Godot MCP runtime started project and returned `errors=[]` before runtime call.
- [x] TCP runtime proof called `/root/Main.generated_liquid_turret_set_stats_bridge_state`.
- [x] Runtime non-empty `ammo_types={water:{name:"water-bullet",damage:4},slag:{name:"slag-bullet",damage:7}}`, `name_value="wave"` returned `matches=true`, `super_set_stats_called=true`, and `stats_added=true`.
- [x] Runtime empty `ammo_types={}`, `name_value="tsunami"` returned `matches=true`, `super_set_stats_called=true`, and `stats_added=true`.
- [x] Godot debug output after runtime proof returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Progress

- Total slices: `1073`
- Done: `891`
- Not done: `182`
- Progress: `83.04%`

## Files Updated

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1194-liquid-turret-set-stats-finalize.md`

## Next

- `N1195`: `LiquidTurret.init()`
- Status before next slice: `active`
