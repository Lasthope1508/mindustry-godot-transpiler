# N1182 ItemTurretBuild.acceptStack finalize

## Scope

- Slice: `N1182`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurretBuild.acceptStack(Item,int,Teamc)`
- Godot source owner: `PortGame.source_item_turret_build_accept_stack_state`
- Runtime proof: `/root/Main.generated_item_turret_build_accept_stack_bridge_state`

## Source facts

```java
public int acceptStack(Item item, int amount, Teamc source){
    BulletType type = ammoTypes.get(item);

    if(type == null) return 0;

    return Math.min((int)((maxAmmo - totalAmmo) / ammoTypes.get(item).ammoMultiplier), amount);
}
```

`Teamc source` is not read by the upstream method body. BulletType internals beyond `ammoMultiplier` remain owned by later slices.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec/checklist context.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1182 status in canonical ledger.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1182 status only.
- [x] Neighbor check: `N1181 done`, `N1182 done`, `N1183 active`.
- [x] Focused tests passed: `5 passed in 0.85s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 398.53s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: root ledger `status=done`; shard ledger `status=done`; accept branch `matches=true`, `accept_stack=10`; null branch `matches=true`, `accept_stack=0`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `879`
- Not done: `194`
- Progress: `81.92%`
- Next unfinished slice: `N1183 ItemTurretBuild.handleStack(Item,int,Teamc)`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1182-item-turret-build-accept-stack-finalize.md`
