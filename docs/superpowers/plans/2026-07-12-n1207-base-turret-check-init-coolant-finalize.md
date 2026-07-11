# N1207 BaseTurret.checkInitCoolant Finalize

## Scope

- Slice: `N1207`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java`
- Java method: `checkInitCoolant()`
- Godot owner: `PortGame.source_base_turret_check_init_coolant_state`
- Bridge: `/root/Main.generated_base_turret_check_init_coolant_bridge_state`
- Generated method: `BaseTurret.java_method_checkInitCoolant_2`

## Source Evidence

- `void checkInitCoolant(){`
- `if(coolant != null){`
- `coolant.update = false;`
- `coolant.booster = true;`
- `coolant.optional = true;`
- `if(!hasConsumer(coolant)) consume(coolant);`

## Deferred

- Concrete `ConsumeLiquidBase` object internals stay owned by consumer/source API slices.
- `hasConsumer(coolant)` and `consume(coolant)` internal storage stay owned by consumer registry slices.

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
- [x] Read exact upstream Java `BaseTurret.checkInitCoolant()`.
- [x] RED status assertion added for `N1207`.
- [x] RED focused test failed as expected with `active != done`: `1 failed, 1064 deselected in 9.65s`.
- [x] GREEN status flipped to `done` in canonical ledger and both shards.
- [x] Focused tests passed: `1 passed, 1064 deselected in 0.45s`.
- [x] SSOT validator passed:
  - `module_count=112`
  - `errors=[]`
  - `defense_checked=137`
  - `ledger_checked=1073`
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 380.73s (0:06:20)`.
- [x] Godot MCP runtime startup passed with `errors=[]`.
- [x] TCP runtime proof passed with one socket per call:
  - No coolant: `matches=true`, `update_after=null`, `booster_after=null`, `optional_after=null`, `consume_called=false`.
  - Coolant already registered: `matches=true`, `update_after=false`, `booster_after=true`, `optional_after=true`, `consume_called=false`.
  - Coolant consume missing: `matches=true`, `update_after=false`, `booster_after=true`, `optional_after=true`, `consume_called=true`.
  - Ledger proof: `N1207.entry.status=done`, nested `entry.slice.status=done`.
- [x] Godot MCP debug output after runtime proof passed with `errors=[]`.
- [x] Godot MCP stop passed with `finalErrors=[]`.

## Progress After N1207

- Total slices: `1073`
- Done: `904`
- Not done: `169`
- Progress: `84.25%`
- Next slice: `N1208 BaseTurret.init()`
