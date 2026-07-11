# N1209 BaseTurret.drawPlace Finalize

## Scope

- Slice: `N1209`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java`
- Java method: `drawPlace(int x, int y, int rotation, boolean valid)`
- Godot owner: `PortGame.source_base_turret_draw_place_state`
- Bridge: `/root/Main.generated_base_turret_draw_place_bridge_state`
- Generated method: `BaseTurret.java_method_drawPlace_3`

## Source Evidence

- `@Override`
- `public void drawPlace(int x, int y, int rotation, boolean valid){`
- `super.drawPlace(x, y, rotation, valid);`
- `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, Pal.placing);`
- `if(fogRadiusMultiplier < 0.99f && state.rules.fog){`
- `Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range * fogRadiusMultiplier, Pal.lightishGray);`

## Deferred

- `super.drawPlace(x, y, rotation, valid)` internals stay deferred to Block superclass source.
- `Drawf.dashCircle` rendering side effects stay deferred to rendering source.
- `Pal` color internals stay deferred to palette source.

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
- [x] Read exact upstream Java `BaseTurret.drawPlace(int x, int y, int rotation, boolean valid)`.
- [x] RED status assertion added for `N1209`.
- [x] RED focused test failed as expected with `active != done`: `1 failed, 1064 deselected in 9.94s`.
- [x] GREEN status flipped to `done` in canonical ledger and both shards.
- [x] Focused tests passed: `1 passed, 1064 deselected in 0.49s`.
- [x] SSOT validator passed:
  - `module_count=112`
  - `errors=[]`
  - `defense_checked=137`
  - `ledger_checked=1073`
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 391.85s (0:06:31)`.
- [x] Godot MCP runtime startup passed with `errors=[]`.
- [x] TCP runtime proof passed with one socket per call:
  - Fog on: `matches=true`, `super_draw_place_called=true`, primary circle `x=28`, `y=36`, `radius=80`, `color=Pal.placing`, fog circle `radius=40`, `color=Pal.lightishGray`.
  - Rules fog off: `matches=true`, `super_draw_place_called=true`, primary circle `x=28`, `y=36`, `radius=80`, `color=Pal.placing`, `fog_dash_circle_called=false`.
  - Multiplier gate off: `matches=true`, `super_draw_place_called=true`, primary circle `x=28`, `y=36`, `radius=80`, `color=Pal.placing`, `fog_dash_circle_called=false`.
  - Ledger proof: `N1209.entry.status=done`, nested `entry.slice.status=done`.
- [x] Godot MCP debug output after runtime proof passed with `errors=[]`.
- [x] Godot MCP stop passed with `finalErrors=[]`.

## Progress After N1209

- Total slices: `1073`
- Done: `906`
- Not done: `167`
- Progress: `84.44%`
- Next slice: `N1210 BaseTurret.setStats()`
