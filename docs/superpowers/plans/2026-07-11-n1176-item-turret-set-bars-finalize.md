# N1176 ItemTurret.setBars finalize

## Scope

- Slice: `N1176`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurret.setBars()`
- Godot source owner: `PortGame.source_item_turret_set_bars_state`
- Runtime proof: `/root/Main.generated_item_turret_set_bars_bridge_state`

## Source facts

```java
@Override
public void setBars(){
    super.setBars();

    addBar("ammo", (ItemTurretBuild entity) ->
        new Bar(
            "stat.ammo",
            Pal.ammo,
            () -> (float)entity.totalAmmo / maxAmmo
        )
    );
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1176 status in canonical ledger and registered shards.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1176 status only.
- [x] Neighbor check: `N1175 done`, `N1176 done`, `N1177 active`.
- [x] Focused tests passed: `5 passed in 0.86s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 385.61s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: bridge `matches=True`, `ammo_bar_fraction=0.3`, exact ammo bar call payload; ledger `status=done`; shard `status=done`; nested `status=done`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `873`
- Not done: `200`
- Progress: `81.36%`
- Next unfinished slice: `N1177 ItemTurret.init()`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1176-item-turret-set-bars-finalize.md`
