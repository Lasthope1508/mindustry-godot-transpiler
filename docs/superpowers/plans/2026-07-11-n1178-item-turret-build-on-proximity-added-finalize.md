# N1178 ItemTurretBuild.onProximityAdded finalize

## Scope

- Slice: `N1178`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurretBuild.onProximityAdded()`
- Godot source owner: `PortGame.source_item_turret_build_on_proximity_added_state`
- Runtime proof: `/root/Main.generated_item_turret_build_on_proximity_added_bridge_state`

## Source facts

```java
public void onProximityAdded(){
    super.onProximityAdded();

    //add first ammo item to cheaty blocks so they can shoot properly
    if(!hasAmmo() && cheating() && ammoTypes.size > 0){
        handleItem(this, ammoTypes.keys().next());
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec N1178 row.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1178 status in canonical ledger and registered shards.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1178 status only.
- [x] Neighbor check: `N1177 done`, `N1178 done`, `N1179 active`.
- [x] Focused tests passed: `5 passed in 0.84s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 380.94s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: ledger `status=done`; shard `status=done`; nested `status=done`; true branch `matches=True`, `should_handle_first_ammo=True`, `handle_item_call.item=copper`; false branches `has_ammo=True` and `ammo_types_size=0` returned `matches=True`, `should_handle_first_ammo=False`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `875`
- Not done: `198`
- Progress: `81.55%`
- Next unfinished slice: `N1179 ItemTurretBuild.senseObject(LAccess sensor)`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1178-item-turret-build-on-proximity-added-finalize.md`
