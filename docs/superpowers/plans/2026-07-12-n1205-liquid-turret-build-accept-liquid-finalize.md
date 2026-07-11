# N1205 LiquidTurretBuild.acceptLiquid Finalize

## Scope

- Slice: `N1205`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurretBuild.acceptLiquid(Building source, Liquid liquid)`
- Godot owner: `PortGame.source_liquid_turret_build_accept_liquid_state`
- Bridge: `/root/Main.generated_liquid_turret_build_accept_liquid_bridge_state`
- Generated method: `LiquidTurret.java_inner_class_LiquidTurretBuild_method_acceptLiquid_9`

## Source Evidence

- `public class LiquidTurretBuild extends TurretBuild{`
- `@Override`
- `public boolean acceptLiquid(Building source, Liquid liquid){`
- `return ammoTypes.get(liquid) != null &&`
- `(liquids.current() == liquid ||`
- `((!ammoTypes.containsKey(liquids.current()) || liquids.get(liquids.current()) <= 1f / ammoTypes.get(liquids.current()).ammoMultiplier + 0.001f)));`

## Deferred

- `ObjectMap<Liquid, BulletType>`, `LiquidModule`, `Building`, and `Liquid` internals stay deferred.
- Explicit inputs carry exact Java lookup results: `ammoTypes.get(liquid)`, `liquids.current()`, `ammoTypes.containsKey(liquids.current())`, `liquids.get(liquids.current())`, and `ammoTypes.get(liquids.current()).ammoMultiplier`.
- Replacement threshold is evaluated only on the Java short-circuit path where candidate ammo exists, current liquid differs, and current liquid has an ammo type.

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
- [x] Read exact upstream Java `LiquidTurretBuild.acceptLiquid(Building source, Liquid liquid)`.
- [x] RED status assertion added for `N1205`.
- [x] RED focused test failed as expected with `active != done`: `1 failed, 4 passed in 10.76s`.
- [x] GREEN status flipped to `done` in canonical ledger and both shards.
- [x] Focused tests passed: `5 passed in 0.87s`.
- [x] SSOT validator passed:
  - `module_count=112`
  - `errors=[]`
  - `defense_checked=137`
  - `ledger_checked=1073`
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 388.23s (0:06:28)`.
- [x] Godot MCP runtime startup passed with `errors=[]`.
- [x] TCP runtime proof passed with one socket per call:
  - No ammo candidate: `matches=true`, `liquid_has_ammo_type=false`, `accept_liquid=false`.
  - Same liquid: `matches=true`, `same_liquid=true`, `accept_liquid=true`.
  - Current liquid missing ammo type: `matches=true`, `current_liquid_missing_ammo_type=true`, `replacement_allowed=true`, `accept_liquid=true`.
  - Drained at threshold: `matches=true`, `current_required_with_epsilon=0.501`, `current_liquid_drained=true`, `accept_liquid=true`.
  - Not drained: `matches=true`, `current_required_with_epsilon=0.501`, `current_liquid_drained=false`, `accept_liquid=false`.
  - Ledger proof: `N1205.entry.status=done`, nested `entry.slice.status=done`.
- [x] Godot MCP debug output after runtime proof passed with `errors=[]`.
- [x] Godot MCP stop passed with `finalErrors=[]`.

## Progress After N1205

- Total slices: `1073`
- Done: `902`
- Not done: `171`
- Progress: `84.06%`
- Next slice: `N1206 BaseTurret.reinitializeConsumers()`
