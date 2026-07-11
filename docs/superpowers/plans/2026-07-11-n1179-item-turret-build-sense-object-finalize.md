# N1179 ItemTurretBuild.senseObject finalize

## Scope

- Slice: `N1179`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurretBuild.senseObject(LAccess sensor)`
- Godot source owner: `PortGame.source_item_turret_build_sense_object_state`
- Runtime proof: `/root/Main.generated_item_turret_build_sense_object_bridge_state`

## Source facts

```java
public Object senseObject(LAccess sensor){
    return switch(sensor){
        case currentAmmoType -> ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;
        default -> super.senseObject(sensor);
    };
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec N1179 row.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1179 status in canonical ledger and registered shards.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1179 status only.
- [x] Neighbor check: `N1178 done`, `N1179 done`, `N1180 active`.
- [x] Focused tests passed: `5 passed in 0.84s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 382.14s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: ledger `status=done`; shard `status=done`; nested `status=done`; current ammo branch `matches=True`, `sense_object_value=copper`; empty ammo branch `matches=True`, `sense_object_value=null`; default branch `matches=True`, `sense_object_value=fallback`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `876`
- Not done: `197`
- Progress: `81.64%`
- Next unfinished slice: `N1180 ItemTurretBuild.getAmmoContent()`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1179-item-turret-build-sense-object-finalize.md`
