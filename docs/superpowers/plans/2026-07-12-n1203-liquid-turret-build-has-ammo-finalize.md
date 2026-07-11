# N1203 LiquidTurretBuild.hasAmmo Finalize

## Scope

- Slice: `N1203`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurretBuild.hasAmmo()`
- Godot owner: `PortGame.source_liquid_turret_build_has_ammo_state`
- Bridge: `/root/Main.generated_liquid_turret_build_has_ammo_bridge_state`
- Generated method: `LiquidTurret.java_inner_class_LiquidTurretBuild_method_hasAmmo_7`

## Source Evidence

- `public class LiquidTurretBuild extends TurretBuild{`
- `@Override`
- `public boolean hasAmmo(){`
- `return ammoTypes.get(liquids.current()) != null && liquids.currentAmount() >= 1f / ammoTypes.get(liquids.current()).ammoMultiplier;`

## Deferred

- `ObjectMap ammoTypes` lookup internals.
- `LiquidModule` internals.
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
- [x] Read exact upstream Java `LiquidTurretBuild.hasAmmo()`.
- [x] RED status assertion added for `N1203`.
- [x] RED focused test failed as expected with `active != done`: `1 failed, 4 passed in 10.78s`.
- [x] GREEN status flipped to `done` in canonical ledger and both shards.
- [x] Focused tests passed: `5 passed in 0.90s`.
- [x] SSOT validator passed:
  - `module_count=112`
  - `errors=[]`
  - `defense_checked=137`
  - `ledger_checked=1073`
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 395.12s (0:06:35)`.
- [x] Godot MCP runtime startup passed with `errors=[]`.
- [x] TCP runtime proof passed with one socket per call:
  - No ammo type: `matches=true`, `ammo_type_present=false`, `required_amount=0.5`, `has_ammo=false`.
  - Enough ammo: `matches=true`, `ammo_type_present=true`, `current_amount=0.5`, `required_amount=0.5`, `has_ammo=true`.
  - Below required: `matches=true`, `current_amount=0.49`, `required_amount=0.5`, `has_ammo=false`.
  - Ledger proof: `N1203.status=done`, nested `slice.status=done`.
- [x] Godot MCP debug output after runtime proof passed with `errors=[]`.
- [x] Godot MCP stop passed with `finalErrors=[]`.

## Progress After N1203

- Total slices: `1073`
- Done: `900`
- Not done: `173`
- Progress: `83.88%`
- Next slice: `N1204 LiquidTurretBuild.acceptItem()`
