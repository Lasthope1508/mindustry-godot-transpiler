# N1175 ItemTurret.setStats finalize

## Scope

- Slice: `N1175`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurret.setStats()`
- Godot source owner: `PortGame.source_item_turret_set_stats_state`
- Runtime proof: `/root/Main.generated_item_turret_set_stats_bridge_state`

## Source facts

```java
@Override
public void setStats(){
    super.setStats();

    stats.remove(Stat.itemCapacity);
    stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));
    stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1175 status in canonical ledger and registered shards.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1175 status only.
- [x] Neighbor check: `N1174 done`, `N1175 done`, `N1176 active`.
- [x] Focused tests passed: `5 passed in 0.88s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Godot MCP runtime proof passed on TCP `7777`: bridge `matches=True`, `ammo_capacity=26.6666666666667`, exact stat remove/add call payloads; ledger `status=done`; shard `status=done`; nested `status=done`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 398.74s`.

## Totals

- Total slices: `1073`
- Done: `872`
- Not done: `201`
- Progress: `81.27%`
- Next unfinished slice: `N1176 ItemTurret.setBars()`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1175-item-turret-set-stats-finalize.md`
