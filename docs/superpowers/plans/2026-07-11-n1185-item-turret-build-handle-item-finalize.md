# N1185 ItemTurretBuild.handleItem finalize

## Scope

- Slice: `N1185`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurretBuild.handleItem(Building,Item)`
- Godot source owner: `PortGame.source_item_turret_build_handle_item_state`
- Runtime proof: `/root/Main.generated_item_turret_build_handle_item_bridge_state`

## Source facts

```java
public void handleItem(Building source, Item item){
    //TODO instead of all this "entry" crap, turrets could just accept only one type of ammo at a time - simpler for both users and the code

    if(item == Items.pyratite){
        Events.fire(Trigger.flameAmmo);
    }

    if(totalAmmo == 0){
        Events.fire(Trigger.resupplyTurret);
    }

    BulletType type = ammoTypes.get(item);
    if(type == null) return;
    totalAmmo += type.ammoMultiplier;

    //find ammo entry by type
    for(int i = 0; i < ammo.size; i++){
        ItemEntry entry = (ItemEntry)ammo.get(i);

        //if found, put it to the right
        if(entry.item == item){
            entry.amount += type.ammoMultiplier;
            ammo.swap(i, ammo.size - 1);
            return;
        }
    }

    //must not be found
    ammo.add(new ItemEntry(item, (int)type.ammoMultiplier));
}
```

`Events.fire` side effects remain represented as branch booleans in this bridge slice; upstream `source` parameter is not read by this method.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec/checklist context.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1185 status in canonical ledger.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1185 status only.
- [x] Neighbor check: `N1184 done`, `N1185 done`, `N1186 active`.
- [x] Focused tests passed: `5 passed in 0.87s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 387.74s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: generated bridge `matches=true`, `flame_ammo_event_fired=true`, `resupply_turret_event_fired=true`, `total_ammo_after=3`, existing `pyratite` ammo entry `4 -> 7`, `swapped=true`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `882`
- Not done: `191`
- Progress: `82.20%`
- Next unfinished slice: `N1186 ItemTurretBuild.acceptItem(Building,Item)`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1185-item-turret-build-handle-item-finalize.md`
