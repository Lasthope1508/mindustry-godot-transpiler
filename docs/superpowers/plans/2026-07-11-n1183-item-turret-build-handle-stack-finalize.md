# N1183 ItemTurretBuild.handleStack finalize

## Scope

- Slice: `N1183`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurretBuild.handleStack(Item,int,Teamc)`
- Godot source owner: `PortGame.source_item_turret_build_handle_stack_state`
- Runtime proof: `/root/Main.generated_item_turret_build_handle_stack_bridge_state`

## Source facts

```java
public void handleStack(Item item, int amount, Teamc source){
    for(int i = 0; i < amount; i++){
        handleItem(null, item);
    }
}
```

`Teamc source` is not read by the upstream method body. `handleItem(Building,Item)` mutation semantics remain owned by the handleItem slice.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec/checklist context.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1183 status in canonical ledger.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1183 status only.
- [x] Neighbor check: `N1182 done`, `N1183 done`, `N1184 active`.
- [x] Focused tests passed: `5 passed in 0.81s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 399.92s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: root ledger `status=done`; shard ledger `status=done`; amount `3` branch `matches=true`, `handle_item_call_count=3`; amount `0` branch `matches=true`, `handle_item_call_count=0`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `880`
- Not done: `193`
- Progress: `82.01%`
- Next unfinished slice: `N1184 ItemTurretBuild.removeStack(Item,int)`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1183-item-turret-build-handle-stack-finalize.md`
