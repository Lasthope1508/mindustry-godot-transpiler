# N1208 BaseTurret.init Finalize

## Scope

- Slice: `N1208`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java`
- Java method: `init()`
- Godot owner: `PortGame.source_base_turret_init_state`
- Bridge: `/root/Main.generated_base_turret_init_bridge_state`
- Generated method: `BaseTurret.java_method_init_0`

## Source Evidence

- `@Override`
- `public void init(){`
- `if(coolant == null){`
- `coolant = findConsumer(c -> c instanceof ConsumeCoolant);`
- `checkInitCoolant();`
- `if(!disableOverlapCheck){`
- `placeOverlapRange = Math.max(placeOverlapRange, range + placeOverlapMargin);`
- `fogRadius = Math.max(Mathf.round(range / tilesize * fogRadiusMultiplier), fogRadius);`
- `super.init();`

## Deferred

- `findConsumer(c -> c instanceof ConsumeCoolant)` internals stay deferred to Block consumer source.
- `checkInitCoolant()` internals stay owned by `N1207`.
- `super.init()` internals stay deferred to Block superclass source.

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
- [x] Read exact upstream Java `BaseTurret.init()`.
- [x] RED status assertion added for `N1208`.
- [x] RED focused test failed as expected with `active != done`: `1 failed, 1064 deselected in 9.72s`.
- [x] GREEN status flipped to `done` in canonical ledger and both shards.
- [x] Focused tests passed: `1 passed, 1064 deselected in 0.46s`.
- [x] SSOT validator passed:
  - `module_count=112`
  - `errors=[]`
  - `defense_checked=137`
  - `ledger_checked=1073`
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 385.82s (0:06:25)`.
- [x] Godot MCP runtime startup passed with `errors=[]`.
- [x] TCP runtime proof passed with one socket per call:
  - Existing coolant overlap/fog raise: `matches=true`, `coolant_present_after=true`, `find_consumer_called=false`, `check_init_coolant_called=true`, `place_overlap_range_after=136`, `fog_radius_after=10`, `super_init_called=true`.
  - Missing coolant found with larger existing values: `matches=true`, `coolant_present_after=true`, `find_consumer_called=true`, `check_init_coolant_called=true`, `place_overlap_range_after=200`, `fog_radius_after=30`, `super_init_called=true`.
  - Disabled overlap: `matches=true`, `coolant_present_after=true`, `find_consumer_called=false`, `check_init_coolant_called=true`, `place_overlap_range_after=20`, `fog_radius_after=5`, `super_init_called=true`.
  - Ledger proof: `N1208.entry.status=done`, nested `entry.slice.status=done`.
- [x] Godot MCP debug output after runtime proof passed with `errors=[]`.
- [x] Godot MCP stop passed with `finalErrors=[]`.

## Progress After N1208

- Total slices: `1073`
- Done: `905`
- Not done: `168`
- Progress: `84.34%`
- Next slice: `N1209 BaseTurret.drawPlace(int x, int y, int rotation, boolean valid)`
