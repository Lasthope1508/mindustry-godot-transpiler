# N1184 ItemTurretBuild.removeStack finalize

## Scope

- Slice: `N1184`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurretBuild.removeStack(Item,int)`
- Godot source owner: `PortGame.source_item_turret_build_remove_stack_state`
- Runtime proof: `/root/Main.generated_item_turret_build_remove_stack_bridge_state`

## Source facts

```java
//currently can't remove items from turrets.
public int removeStack(Item item, int amount){
    return 0;
}
```

No item removal state exists in upstream `removeStack`; the method always returns `0`.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec/checklist context.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1184 status in canonical ledger.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1184 status only.
- [x] Neighbor check: `N1183 done`, `N1184 done`, `N1185 active`.
- [x] Focused tests passed: `5 passed in 0.86s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 397.28s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: root ledger `status=done`; shard ledger `status=done`; generated bridge `matches=true`, `removed_stack=0`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `881`
- Not done: `192`
- Progress: `82.11%`
- Next unfinished slice: `N1185 ItemTurretBuild.handleItem(Building,Item)`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1184-item-turret-build-remove-stack-finalize.md`
