# N1188 ItemTurretBuild.write finalize

## Scope

- Slice: `N1188`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurretBuild.write(Writes)`
- Godot source owner: `PortGame.source_item_turret_build_write_state`
- Runtime proof: `/root/Main.generated_item_turret_build_write_bridge_state`

## Source facts

```java
@Override
public void write(Writes write){
    super.write(write);
    write.b(ammo.size);
    for(AmmoEntry entry : ammo){
        ItemEntry i = (ItemEntry)entry;
        write.s(i.item.id);
        write.s(i.amount);
    }
}
```

This slice records ordered write-call state only. It does not invent binary `Writes` internals or adjacent `read(Reads, byte)` behavior.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec/checklist context.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1188 status in canonical ledger.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1188 status only.
- [x] Neighbor check: `N1187 done`, `N1188 done`, `N1189 active`.
- [x] Focused tests passed: `5 passed in 0.87s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 396.32s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: non-empty branch `matches=true`, `ammo_size=2`, entry writes `{1,3}` and `{2,5}`, ordered calls `super.write(write);`, `write.b(ammo.size);`, `write.s(i.item.id);`, `write.s(i.amount);`; empty branch `matches=true`, `ammo_size=0`, empty entry writes, superclass plus size write only.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `885`
- Not done: `188`
- Progress: `82.48%`
- Next unfinished slice: `N1189 ItemTurretBuild.read(Reads, byte)`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1188-item-turret-build-write-finalize.md`
