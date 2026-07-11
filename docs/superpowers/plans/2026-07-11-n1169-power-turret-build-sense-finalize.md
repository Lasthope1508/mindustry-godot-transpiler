# N1169 PowerTurretBuild.sense finalize

## Scope

- Slice: `N1169`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/PowerTurret.java`
- Java method: `PowerTurretBuild.sense(LAccess sensor)`
- Godot source owner: `PortGame.source_power_turret_build_sense_state`
- Runtime proof: `/root/Main.generated_power_turret_build_sense_bridge_state`

## Source facts

```java
public class PowerTurretBuild extends TurretBuild{

    @Override
    public double sense(LAccess sensor){
        return switch(sensor){
            case ammo -> power == null ? 0f : power.status;
            case ammoCapacity -> 1;
            default -> super.sense(sensor);
        };
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1169 status in canonical ledger and registered shards.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1169 status only.
- [x] Neighbor check: `N1168 done`, `N1169 done`, `N1170 active`.
- [x] Focused tests passed: `5 passed in 0.95s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Godot MCP runtime proof passed on TCP `7777`: `ammo` null `matches=True`, `sense_value=0.0`; `ammo` status `matches=True`, `sense_value=0.75`; `ammoCapacity` `matches=True`, `sense_value=1.0`; default `matches=True`, `sense_value=42.0`; ledger `status=done`; shard `status=done`; nested `status=done`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 414.84s`.

## Totals

- Total slices: `1073`
- Done: `866`
- Not done: `207`
- Progress: `80.71%`
- Next unfinished slice: `N1170 PowerTurret.PowerTurretBuild.useAmmo()`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1169-power-turret-build-sense-finalize.md`
