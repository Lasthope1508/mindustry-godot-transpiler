# N1186 ItemTurretBuild.acceptItem finalize

## Scope

- Slice: `N1186`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurretBuild.acceptItem(Building,Item)`
- Godot source owner: `PortGame.source_item_turret_build_accept_item_state`
- Runtime proof: `/root/Main.generated_item_turret_build_accept_item_bridge_state`

## Source facts

```java
@Override
public boolean acceptItem(Building source, Item item){
    return ammoTypes.get(item) != null && totalAmmo + ammoTypes.get(item).ammoMultiplier <= maxAmmo;
}
```

Upstream `source` parameter is not read by this method. Acceptance is exactly the known-ammo guard plus max-ammo capacity guard.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec/checklist context.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1186 status in canonical ledger.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1186 status only.
- [x] Neighbor check: `N1185 done`, `N1186 done`, `N1187 active`.
- [x] Focused tests passed: `5 passed in 0.84s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 387.62s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: accepted case `matches=true`, `accept_item=true`; capped case `matches=true`, `accept_item=false`, `28 + 5 > 30`; null-type case `matches=true`, `accept_item=false`, `ammo_type_null=true`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `883`
- Not done: `190`
- Progress: `82.29%`
- Next unfinished slice: `N1187 ItemTurretBuild.version()`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1186-item-turret-build-accept-item-finalize.md`
