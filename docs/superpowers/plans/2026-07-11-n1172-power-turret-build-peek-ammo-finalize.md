# N1172 PowerTurretBuild.peekAmmo finalize

## Scope

- Slice: `N1172`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/PowerTurret.java`
- Java method: `PowerTurretBuild.peekAmmo()`
- Godot source owner: `PortGame.source_power_turret_build_peek_ammo_state`
- Runtime proof: `/root/Main.generated_power_turret_build_peek_ammo_bridge_state`

## Source facts

```java
public BulletType peekAmmo(){
    return shootType;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1172 status in canonical ledger and registered shards.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1172 status only.
- [x] Neighbor check: `N1171 done`, `N1172 done`, `N1173 active`.
- [x] Focused tests passed: `5 passed in 1.00s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Godot MCP runtime proof passed on TCP `7777`: bridge `matches=True`, `shoot_type=laser-bolt`; ledger `status=done`; shard `status=done`; nested `status=done`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 416.63s`.

## Totals

- Total slices: `1073`
- Done: `869`
- Not done: `204`
- Progress: `80.99%`
- Next unfinished slice: `N1173 ItemTurret.limitRange()`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1172-power-turret-build-peek-ammo-finalize.md`
