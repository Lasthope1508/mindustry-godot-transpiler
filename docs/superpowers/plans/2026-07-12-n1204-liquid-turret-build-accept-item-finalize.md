# N1204 LiquidTurretBuild.acceptItem Finalize

## Scope

- Slice: `N1204`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurretBuild.acceptItem(Building source, Item item)`
- Godot owner: `PortGame.source_liquid_turret_build_accept_item_state`
- Bridge: `/root/Main.generated_liquid_turret_build_accept_item_bridge_state`
- Generated method: `LiquidTurret.java_inner_class_LiquidTurretBuild_method_acceptItem_8`

## Source Evidence

- `public class LiquidTurretBuild extends TurretBuild{`
- `@Override`
- `public boolean acceptItem(Building source, Item item){`
- `return false;`

## Deferred

- `Building source` internals.
- `Item item` internals.
- Both parameters stay passthrough because upstream ignores them and returns `false`.

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
- [x] Read exact upstream Java `LiquidTurretBuild.acceptItem(Building source, Item item)`.
- [x] RED status assertion added for `N1204`.
- [x] RED focused test failed as expected with `active != done`: `1 failed, 4 passed in 10.84s`.
- [x] GREEN status flipped to `done` in canonical ledger and both shards.
- [x] Focused tests passed: `5 passed in 0.86s`.
- [x] SSOT validator passed:
  - `module_count=112`
  - `errors=[]`
  - `defense_checked=137`
  - `ledger_checked=1073`
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 394.91s (0:06:34)`.
- [x] Godot MCP runtime startup passed with `errors=[]`.
- [x] TCP runtime proof passed with one socket per call:
  - Sample source/item: `matches=true`, `accept_item=false`, `source_building.id=source-build`, `item.id=copper`.
  - Null source/item: `matches=true`, `accept_item=false`, `source_building=null`, `item=null`.
  - Ledger proof: `N1204.status=done`, nested `slice.status=done`.
- [x] Godot MCP debug output after runtime proof passed with `errors=[]`.
- [x] Godot MCP stop passed with `finalErrors=[]`.

## Progress After N1204

- Total slices: `1073`
- Done: `901`
- Not done: `172`
- Progress: `83.97%`
- Next slice: `N1205 LiquidTurretBuild.acceptLiquid()`
