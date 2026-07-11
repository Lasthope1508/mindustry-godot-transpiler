# N1196 LiquidTurretBuild.shouldActiveSound Finalize

## Scope

- Slice: `N1196`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurretBuild.shouldActiveSound()`
- Godot owner: `PortGame.source_liquid_turret_build_should_active_sound_state`
- Runtime proof: `/root/Main.generated_liquid_turret_build_should_active_sound_bridge_state`

## Source Evidence

Exact upstream expressions preserved:

- `public class LiquidTurretBuild extends TurretBuild{`
- `@Override`
- `public boolean shouldActiveSound(){`
- `return wasShooting && enabled;`

Deferred:

- Active sound scheduler behavior outside the returned boolean.
- `LiquidTurretBuild.getAmmoContent()` starts at `N1197`.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read migration spec entry for `N1196`.
- [x] Read SSOT roots and N1196 shards.
- [x] Read exact upstream Java method.
- [x] Added RED status assertion in `test_generated_liquid_turret_build_should_active_sound_slice_is_registered_with_source_backing`.
- [x] RED failed for expected reason: `active != done`.
- [x] GREEN updated N1196 status in canonical ledger and mirror shards.
- [x] Focused tests passed: `5 passed`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed`.
- [x] Godot MCP runtime started project and returned `errors=[]` before runtime call.
- [x] TCP runtime proof called `/root/Main.generated_liquid_turret_build_should_active_sound_bridge_state`.
- [x] Runtime `(was_shooting=true, enabled=true)` returned `matches=true` and `should_active_sound=true`.
- [x] Runtime `(true,false)`, `(false,true)`, and `(false,false)` returned `matches=true` and `should_active_sound=false`.
- [x] Godot debug output after runtime proof returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Progress

- Total slices: `1073`
- Done: `893`
- Not done: `180`
- Progress: `83.22%`

## Files Updated

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1196-liquid-turret-build-should-active-sound-finalize.md`

## Next

- `N1197`: `LiquidTurretBuild.getAmmoContent()`
- Status before next slice: `active`
