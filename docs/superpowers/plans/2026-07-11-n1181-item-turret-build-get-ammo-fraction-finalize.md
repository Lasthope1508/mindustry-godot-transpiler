# N1181 ItemTurretBuild.getAmmoFraction finalize

## Scope

- Slice: `N1181`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurretBuild.getAmmoFraction()`
- Godot source owner: `PortGame.source_item_turret_build_get_ammo_fraction_state`
- Runtime proof: `/root/Main.generated_item_turret_build_get_ammo_fraction_bridge_state`

## Source facts

```java
public float getAmmoFraction(){
    return (float)totalAmmo / maxAmmo;
}
```

No maxAmmo zero guard is added because the upstream Java return expression has no guard.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec/checklist context.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1181 status in canonical ledger.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1181 status only.
- [x] Neighbor check: `N1180 done`, `N1181 done`, `N1182 active`.
- [x] Focused tests passed: `5 passed in 0.80s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 390.01s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: root ledger `status=done`; shard ledger `status=done`; generated bridge `6.0 / 24.0 = 0.25`; `matches=true`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `878`
- Not done: `195`
- Progress: `81.83%`
- Next unfinished slice: `N1182 ItemTurretBuild.acceptStack(Item,int,Teamc)`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1181-item-turret-build-get-ammo-fraction-finalize.md`
