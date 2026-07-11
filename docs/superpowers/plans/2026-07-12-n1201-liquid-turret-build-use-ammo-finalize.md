# N1201 LiquidTurretBuild.useAmmo Finalize

## Scope

- Slice: `N1201`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurretBuild.useAmmo()`
- Godot owner: `PortGame.source_liquid_turret_build_use_ammo_state`
- Bridge: `/root/Main.generated_liquid_turret_build_use_ammo_bridge_state`
- Generated method: `LiquidTurret.java_inner_class_LiquidTurretBuild_method_useAmmo_5`

## Source Evidence

- `public class LiquidTurretBuild extends TurretBuild{`
- `@Override`
- `public BulletType useAmmo(){`
- `if(cheating()) return ammoTypes.get(liquids.current());`
- `BulletType type = ammoTypes.get(liquids.current());`
- `liquids.remove(liquids.current(), 1f / type.ammoMultiplier);`
- `return type;`

## Deferred

- `ObjectMap ammoTypes` lookup internals.
- `LiquidModule` mutation internals.
- `BulletType` internals.

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
- [x] Read exact upstream Java `LiquidTurretBuild.useAmmo()`.
- [x] RED status assertion added for `N1201`.
- [x] RED focused test failed as expected with `active != done`: `1 failed, 4 passed in 10.70s`.
- [x] GREEN status flipped to `done` in canonical ledger and both shards.
- [x] Focused tests passed: `5 passed in 0.86s`.
- [x] SSOT validator passed:
  - `module_count=112`
  - `errors=[]`
  - `defense_checked=137`
  - `ledger_checked=1073`
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 382.19s (0:06:22)`.
- [x] Godot MCP runtime startup passed with `errors=[]`.
- [x] TCP runtime proof passed with one socket per call:
  - Cheating branch: `matches=true`, `liquid_remove_amount=0`, `remove_liquid_call={}`, `returned_ammo=water-shot`.
  - Normal branch: `matches=true`, `liquid_remove_amount=0.5`, `remove_liquid_call.amount=0.5`, `returned_ammo=water-shot`.
  - Ledger proof: `N1201.status=done`, nested `slice.status=done`.
- [x] Godot MCP debug output after runtime proof passed with `errors=[]`.
- [x] Godot MCP stop passed with `finalErrors=[]`.

## Progress After N1201

- Total slices: `1073`
- Done: `898`
- Not done: `175`
- Progress: `83.69%`
- Next slice: `N1202 LiquidTurretBuild.peekAmmo()`
