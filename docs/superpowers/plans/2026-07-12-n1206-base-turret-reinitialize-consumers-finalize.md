# N1206 BaseTurret.reinitializeConsumers Finalize

## Scope

- Slice: `N1206`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java`
- Java method: `reinitializeConsumers()`
- Godot owner: `PortGame.source_base_turret_reinitialize_consumers_state`
- Bridge: `/root/Main.generated_base_turret_reinitialize_consumers_bridge_state`
- Generated method: `BaseTurret.java_method_reinitializeConsumers_1`

## Source Evidence

- `@Override`
- `public void reinitializeConsumers(){`
- `checkInitCoolant();`
- `super.reinitializeConsumers();`

## Deferred

- `checkInitCoolant()` internals stay owned by `BaseTurret.checkInitCoolant()` slices.
- Superclass consumer reinitialization internals stay deferred to `Block` superclass source.

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
- [x] Read exact upstream Java `BaseTurret.reinitializeConsumers()`.
- [x] RED status assertion added for `N1206`.
- [x] RED focused test failed as expected with `active != done`: `1 failed, 1064 deselected in 9.65s`.
- [x] GREEN status flipped to `done` in canonical ledger and both shards.
- [x] Focused tests passed: `1 passed, 1064 deselected in 0.47s`.
- [x] SSOT validator passed:
  - `module_count=112`
  - `errors=[]`
  - `defense_checked=137`
  - `ledger_checked=1073`
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 397.28s (0:06:37)`.
- [x] Godot MCP runtime startup passed with `errors=[]`.
- [x] TCP runtime proof passed with one socket per call:
  - Bridge proof: `matches=true`, `check_init_coolant_called=true`, `super_reinitialize_consumers_called=true`.
  - Source expressions: `check_init_coolant_expr="checkInitCoolant();"`, `super_reinitialize_consumers_expr="super.reinitializeConsumers();"`.
  - Ledger proof: `N1206.entry.status=done`, nested `entry.slice.status=done`.
- [x] Godot MCP debug output after runtime proof passed with `errors=[]`.
- [x] Godot MCP stop passed with `finalErrors=[]`.

## Progress After N1206

- Total slices: `1073`
- Done: `903`
- Not done: `170`
- Progress: `84.16%`
- Next slice: `N1207 BaseTurret.checkInitCoolant()`
