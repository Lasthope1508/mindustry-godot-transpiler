# N1197 LiquidTurretBuild.getAmmoContent Finalize

## Scope

- Slice: `N1197`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurretBuild.getAmmoContent()`
- Godot owner: `PortGame.source_liquid_turret_build_get_ammo_content_state`
- Runtime proof: `/root/Main.generated_liquid_turret_build_get_ammo_content_bridge_state`

## Source Evidence

Exact upstream expressions preserved:

- `public class LiquidTurretBuild extends TurretBuild{`
- `@Override`
- `public UnlockableContent getAmmoContent(){`
- `return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;`

Deferred:

- Liquid module implementation internals.
- `UnlockableContent` concrete behavior.
- `LiquidTurretBuild.getAmmoFraction()` starts at `N1198`.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read migration spec entry for `N1197`.
- [x] Read SSOT roots and N1197 shards.
- [x] Read exact upstream Java method.
- [x] Added RED status assertion in `test_generated_liquid_turret_build_get_ammo_content_slice_is_registered_with_source_backing`.
- [x] RED failed for expected reason: `active != done`.
- [x] GREEN updated N1197 status in canonical ledger and mirror shards.
- [x] Focused tests passed: `5 passed`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed`.
- [x] Godot MCP runtime started project and returned `errors=[]` before runtime call.
- [x] TCP runtime proof called `/root/Main.generated_liquid_turret_build_get_ammo_content_bridge_state`.
- [x] Runtime `(liquids_null=false, current_amount=3.5, current_liquid={name:"water"})` returned `matches=true` and `ammo_content={name:"water"}`.
- [x] Runtime `(liquids_null=false, current_amount=0.0, current_liquid={name:"water"})` returned `matches=true` and `ammo_content=null`.
- [x] Runtime `(liquids_null=true, current_amount=3.5, current_liquid={name:"water"})` returned `matches=true` and `ammo_content=null`.
- [x] Godot debug output after runtime proof returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Progress

- Total slices: `1073`
- Done: `894`
- Not done: `179`
- Progress: `83.32%`

## Files Updated

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1197-liquid-turret-build-get-ammo-content-finalize.md`

## Next

- `N1198`: `LiquidTurretBuild.getAmmoFraction()`
- Status before next slice: `active`
