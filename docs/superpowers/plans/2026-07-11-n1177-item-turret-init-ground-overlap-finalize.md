# N1177 ItemTurret.init ground overlap finalize

## Scope

- Slice: `N1177`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurret.init()`
- Godot source owner: `PortGame.source_item_turret_init_ground_overlap_state`
- Runtime proof: `/root/Main.generated_item_turret_init_ground_overlap_bridge_state`

## Source facts

```java
public void init(){
    consume(new ConsumeItemFilter(i -> ammoTypes.containsKey(i)){
        @Override
        public void build(Building build, Table table){
            MultiReqImage image = new MultiReqImage();
            content.items().each(i -> filter.get(i) && i.unlockedNow(),
            item -> image.add(new ReqImage(new Image(item.uiIcon),
            () -> build instanceof ItemTurretBuild it && !it.ammo.isEmpty() && ((ItemEntry)it.ammo.peek()).item == item)));

            table.add(image).size(8 * 4);
        }

        @Override
        public float efficiency(Building build){
            //valid when it can shoot
            return build instanceof ItemTurretBuild it && it.ammo.size > 0 && (it.ammo.peek().amount >= ammoPerShot || it.cheating()) ? 1f : 0f;
        }

        @Override
        public void display(Stats stats){
            //don't display
        }
    });

    if(targetGround){
        ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));
    }

    super.init();
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec N1177 row.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1177 status in canonical ledger and registered shards.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1177 status only.
- [x] Neighbor check: `N1176 done`, `N1177 done`, `N1178 active`.
- [x] Focused tests passed: `5 passed in 0.87s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 381.92s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: ledger `status=done`; shard `status=done`; nested `status=done`; true branch `matches=True`, `place_overlap_range_after=133.0`, `place_overlap_update_count=3`; false branch `matches=True`, `place_overlap_range_after=72.0`, `place_overlap_update_count=0`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `874`
- Not done: `199`
- Progress: `81.45%`
- Next unfinished slice: `N1178 ItemTurretBuild.onProximityAdded()`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1177-item-turret-init-ground-overlap-finalize.md`
