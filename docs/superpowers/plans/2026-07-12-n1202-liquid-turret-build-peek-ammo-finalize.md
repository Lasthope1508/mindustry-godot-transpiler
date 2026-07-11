# N1202 LiquidTurretBuild.peekAmmo Finalize

## Scope

- Slice: `N1202`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurretBuild.peekAmmo()`
- Godot owner: `PortGame.source_liquid_turret_build_peek_ammo_state`
- Bridge: `/root/Main.generated_liquid_turret_build_peek_ammo_bridge_state`
- Generated method: `LiquidTurret.java_inner_class_LiquidTurretBuild_method_peekAmmo_6`

## Source Evidence

- `public class LiquidTurretBuild extends TurretBuild{`
- `@Override`
- `public BulletType peekAmmo(){`
- `return ammoTypes.get(liquids.current());`

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
- [x] Read exact upstream Java `LiquidTurretBuild.peekAmmo()`.
- [x] RED status assertion added for `N1202`.
- [x] RED focused test failed as expected with `active != done`: `1 failed, 4 passed in 10.72s`.
- [x] GREEN status flipped to `done` in canonical ledger and both shards.
- [x] Focused tests passed: `5 passed in 0.81s`.
- [x] SSOT validator passed:
  - `module_count=112`
  - `errors=[]`
  - `defense_checked=137`
  - `ledger_checked=1073`
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 393.78s (0:06:33)`.
- [x] Godot MCP runtime startup passed with `errors=[]`.
- [x] TCP runtime proof passed with one socket per call:
  - Water ammo: `matches=true`, `peek_ammo.name=water-bullet`, `peek_ammo.ammoMultiplier=2`.
  - Slag ammo: `matches=true`, `peek_ammo.name=slag-bullet`, `peek_ammo.ammoMultiplier=4`.
  - Null ammo: `matches=true`, `peek_ammo=null`.
  - Ledger proof: `N1202.status=done`, nested `slice.status=done`.
- [x] Godot MCP debug output after runtime proof passed with `errors=[]`.
- [x] Godot MCP stop passed with `finalErrors=[]`.

## Progress After N1202

- Total slices: `1073`
- Done: `899`
- Not done: `174`
- Progress: `83.78%`
- Next slice: `N1203 LiquidTurretBuild.hasAmmo()`
