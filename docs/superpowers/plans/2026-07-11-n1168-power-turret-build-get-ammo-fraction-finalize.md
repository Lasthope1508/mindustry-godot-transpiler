# N1168 PowerTurretBuild.getAmmoFraction finalize

## Scope

- Slice: `N1168`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/PowerTurret.java`
- Java method: `PowerTurretBuild.getAmmoFraction()`
- Godot source owner: `PortGame.source_power_turret_build_get_ammo_fraction_state`
- Runtime proof: `/root/Main.generated_power_turret_build_get_ammo_fraction_bridge_state`

## Source facts

```java
public class PowerTurretBuild extends TurretBuild{

    @Override
    public float getAmmoFraction(){
        return power == null ? 0f : power.status;
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1168 status in canonical ledger and registered shards.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1168 status only.
- [x] Neighbor check: `N1167 done`, `N1168 done`, `N1169 active`.
- [x] Focused tests passed: `5 passed in 0.95s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Godot MCP runtime proof passed on TCP `7777`: null case `matches=True`, `ammo_fraction=0.0`; status case `matches=True`, `ammo_fraction=0.75`; ledger `status=done`; shard `status=done`; nested `status=done`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 415.66s`.

## Totals

- Total slices: `1073`
- Done: `865`
- Not done: `208`
- Progress: `80.62%`
- Next unfinished slice: `N1169 PowerTurret.PowerTurretBuild.sense(LAccess sensor)`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1168-power-turret-build-get-ammo-fraction-finalize.md`
