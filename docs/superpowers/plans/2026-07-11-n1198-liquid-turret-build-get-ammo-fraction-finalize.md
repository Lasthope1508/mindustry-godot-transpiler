# N1198 LiquidTurretBuild.getAmmoFraction Finalize

## Scope

- Slice: `N1198`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurretBuild.getAmmoFraction()`
- Godot owner: `PortGame.source_liquid_turret_build_get_ammo_fraction_state`
- Runtime proof: `/root/Main.generated_liquid_turret_build_get_ammo_fraction_bridge_state`

## Source Evidence

Exact upstream expressions preserved:

- `public class LiquidTurretBuild extends TurretBuild{`
- `@Override`
- `public float getAmmoFraction(){`
- `return liquids.currentAmount() / liquidCapacity;`

Deferred:

- Liquid module storage behavior.
- Liquid capacity owner integration outside explicit input.
- Divide-by-zero behavior is not guarded because upstream Java has no guard.
- `LiquidTurretBuild.senseObject(LAccess sensor)` starts at `N1199`.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read migration spec entry for `N1198`.
- [x] Read SSOT roots and N1198 shards.
- [x] Read exact upstream Java method.
- [x] Added RED status assertion in `test_generated_liquid_turret_build_get_ammo_fraction_slice_is_registered_with_source_backing`.
- [x] RED failed for expected reason: `active != done`.
- [x] GREEN updated N1198 status in canonical ledger and mirror shards.
- [x] Focused tests passed: `5 passed`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed`.
- [x] Godot MCP runtime started project and returned `errors=[]` before runtime call.
- [x] TCP runtime proof called `/root/Main.generated_liquid_turret_build_get_ammo_fraction_bridge_state`.
- [x] Runtime `(current_amount=5, liquid_capacity=10)` returned `matches=true` and `ammo_fraction=0.5`.
- [x] Runtime `(current_amount=0, liquid_capacity=10)` returned `matches=true` and `ammo_fraction=0`.
- [x] Runtime `(current_amount=7.5, liquid_capacity=3)` returned `matches=true` and `ammo_fraction=2.5`.
- [x] Godot debug output after runtime proof returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Progress

- Total slices: `1073`
- Done: `895`
- Not done: `178`
- Progress: `83.41%`

## Files Updated

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1198-liquid-turret-build-get-ammo-fraction-finalize.md`

## Next

- `N1199`: `LiquidTurretBuild.senseObject(LAccess sensor)`
- Status before next slice: `active`
