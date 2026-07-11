# N1166 PowerTurret.setStats finalize

## Scope

- Slice: `N1166`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/PowerTurret.java`
- Java method: `PowerTurret.setStats()`
- Godot source owner: `PortGame.source_power_turret_set_stats_state`
- Runtime proof: `/root/Main.generated_power_turret_set_stats_bridge_state`

## Source facts

```java
public void setStats(){
    super.setStats();
    stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1166 status in canonical ledger and registered shards.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1166 status only.
- [x] Neighbor check: `N1165 done`, `N1166 done`, `N1167 active`.
- [x] Focused tests passed: `5 passed in 0.97s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Godot MCP runtime proof passed on TCP `7777`: bridge `matches=True`, `shoot_type=laser-bolt`, ledger `status=done`, shard `status=done`, nested `status=done`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 422.52s`.

## Totals

- Total slices: `1073`
- Done: `863`
- Not done: `210`
- Progress: `80.43%`
- Next unfinished slice: `N1167 PowerTurret.limitRange(float margin)`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1166-power-turret-set-stats-finalize.md`
