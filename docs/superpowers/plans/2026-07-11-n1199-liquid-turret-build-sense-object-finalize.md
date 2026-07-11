# N1199 LiquidTurretBuild.senseObject Finalize

## Scope

- Slice: `N1199`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurretBuild.senseObject(LAccess sensor)`
- Godot owner: `PortGame.source_liquid_turret_build_sense_object_state`
- Runtime proof: `/root/Main.generated_liquid_turret_build_sense_object_bridge_state`

## Source Evidence

Exact upstream expressions preserved:

- `public class LiquidTurretBuild extends TurretBuild{`
- `@Override`
- `public Object senseObject(LAccess sensor){`
- `return switch(sensor){`
- `case currentAmmoType -> liquids.current();`
- `default -> super.senseObject(sensor);`

Deferred:

- `LAccess` enum internals beyond explicit `currentAmmoType` branch.
- `super.senseObject(sensor)` implementation; this slice takes it as explicit input.
- `LiquidTurretBuild.findTarget()` starts at `N1200`.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read migration spec entry for `N1199`.
- [x] Read SSOT roots and N1199 shards.
- [x] Read exact upstream Java method.
- [x] Added RED status assertion in `test_generated_liquid_turret_build_sense_object_slice_is_registered_with_source_backing`.
- [x] RED failed for expected reason: `active != done`.
- [x] GREEN updated N1199 status in canonical ledger and mirror shards.
- [x] Focused tests passed: `5 passed`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed`.
- [x] Godot MCP runtime started project and returned `errors=[]` before runtime call.
- [x] TCP runtime proof called `/root/Main.generated_liquid_turret_build_sense_object_bridge_state`.
- [x] Runtime `sensor="currentAmmoType"` returned `matches=true` and `sense_object_value={name:"water"}` from `current_liquid`.
- [x] Runtime `sensor="health"` returned `matches=true` and `sense_object_value={sensor:"health",value:42}` from `super_sense_object_value`.
- [x] Godot debug output after runtime proof returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Progress

- Total slices: `1073`
- Done: `896`
- Not done: `177`
- Progress: `83.50%`

## Files Updated

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1199-liquid-turret-build-sense-object-finalize.md`

## Next

- `N1200`: `LiquidTurretBuild.findTarget()`
- Status before next slice: `active`
