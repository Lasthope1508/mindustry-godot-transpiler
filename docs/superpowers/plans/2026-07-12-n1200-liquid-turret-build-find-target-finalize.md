# N1200 LiquidTurretBuild.findTarget Extinguish Finalize

## Scope

- Slice: `N1200`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurretBuild.findTarget()`
- Godot owner: `PortGame.source_liquid_turret_build_find_target_extinguish_state`
- Bridge: `/root/Main.generated_liquid_turret_build_find_target_extinguish_bridge_state`
- Generated method: `LiquidTurret.java_inner_class_LiquidTurretBuild_method_findTarget_4`

## Source Evidence

- `public class LiquidTurretBuild extends TurretBuild{`
- `@Override`
- `protected void findTarget(){`
- `if(extinguish && liquids.current().canExtinguish()){`
- `Fire result = null;`
- `target = result;`
- `return;`
- `super.findTarget();`

## Deferred

- Tile iteration internals.
- Distance comparison internals.
- `Fires.has` internals.
- Team checks.
- `mindst` update internals.
- Full targeting system.

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
- [x] Read exact upstream Java `LiquidTurretBuild.findTarget()`.
- [x] RED status assertion added for `N1200`.
- [x] RED focused test failed as expected with `active != done`.
- [x] GREEN status flipped to `done` in canonical ledger and both shards.
- [x] Focused tests passed: `5 passed in 0.87s`.
- [x] SSOT validator passed:
  - `module_count=112`
  - `errors=[]`
  - `defense_checked=137`
  - `ledger_checked=1073`
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 384.85s (0:06:24)`.
- [x] Godot MCP runtime startup passed with `errors=[]`.
- [x] TCP runtime proof passed with one socket per call:
  - Disabled extinguish: `should_scan_fires=false`, `target_assigned=false`, `super_find_target_called=true`.
  - Scan no fire: `should_scan_fires=true`, `target_assigned=false`, `super_find_target_called=true`.
  - Scan fire: `should_scan_fires=true`, `target_assigned=true`, `super_find_target_called=false`.
- [x] Godot MCP debug output after runtime proof passed with `errors=[]`.
- [x] Godot MCP stop passed with `finalErrors=[]`.

## Progress After N1200

- Total slices: `1073`
- Done: `897`
- Not done: `176`
- Progress: `83.60%`
- Next slice: `N1201 LiquidTurretBuild.useAmmo()`
