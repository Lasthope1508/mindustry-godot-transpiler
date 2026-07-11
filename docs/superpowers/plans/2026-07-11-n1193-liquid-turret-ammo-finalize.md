# N1193 LiquidTurret.ammo Finalize

## Scope

- Slice: `N1193`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java`
- Java method: `LiquidTurret.ammo(Object...)`
- Godot owner: `PortGame.source_liquid_turret_ammo_state`
- Runtime proof: `/root/Main.generated_liquid_turret_ammo_bridge_state`

## Source Evidence

Exact upstream expressions preserved:

- `public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();`
- `/** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */`
- `public void ammo(Object... objects){`
- `ammoTypes = ObjectMap.of(objects);`

Deferred:

- `ObjectMap.of(objects)` internals.
- Concrete Liquid/BulletType runtime behavior beyond explicit `objects` snapshot.
- `LiquidTurret.setStats()` starts at `N1194`.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read migration spec entry for `N1193`.
- [x] Read SSOT roots and N1193 shards.
- [x] Read exact upstream Java method.
- [x] Added RED status assertion in `test_generated_liquid_turret_ammo_slice_is_registered_with_source_backing`.
- [x] RED failed for expected reason: `active != done`.
- [x] GREEN updated N1193 status in canonical ledger and mirror shards.
- [x] Focused tests passed: `5 passed`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed`.
- [x] Godot MCP runtime started project and returned `errors=[]` before runtime call.
- [x] TCP runtime proof called `/root/Main.generated_liquid_turret_ammo_bridge_state`.
- [x] Runtime non-empty `objects=["water",{name:"water-bullet",damage:4},"slag",{name:"slag-bullet",damage:7}]` returned `matches=true` and echoed `ammo_types_after`.
- [x] Runtime empty `objects=[]` returned `matches=true` and empty `ammo_types_after`.
- [x] Godot debug output after runtime proof returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Progress

- Total slices: `1073`
- Done: `890`
- Not done: `183`
- Progress: `82.95%`

## Files Updated

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1193-liquid-turret-ammo-finalize.md`

## Next

- `N1194`: `LiquidTurret.setStats()`
- Status before next slice: `active`
