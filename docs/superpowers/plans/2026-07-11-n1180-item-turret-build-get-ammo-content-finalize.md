# N1180 ItemTurretBuild.getAmmoContent finalize

## Scope

- Slice: `N1180`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurretBuild.getAmmoContent()`
- Godot source owner: `PortGame.source_item_turret_build_get_ammo_content_state`
- Runtime proof: `/root/Main.generated_item_turret_build_get_ammo_content_bridge_state`

## Source facts

```java
public UnlockableContent getAmmoContent(){
    return ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec N1180 row.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1180 status in canonical ledger and registered shards.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1180 status only.
- [x] Neighbor check: `N1179 done`, `N1180 done`, `N1181 active`.
- [x] Focused tests passed: `5 passed in 0.89s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 382.96s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: ledger `status=done`; shard `status=done`; nested `status=done`; ammo branch `matches=True`, `ammo_content=copper`; empty branch `matches=True`, `ammo_content=null`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `877`
- Not done: `196`
- Progress: `81.73%`
- Next unfinished slice: `N1181 ItemTurretBuild.getAmmoFraction()`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1180-item-turret-build-get-ammo-content-finalize.md`
