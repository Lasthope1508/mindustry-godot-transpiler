# N1174 ItemTurret.limitRange entries finalize

## Scope

- Slice: `N1174`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurret.limitRange(float margin)`
- Godot source owner: `PortGame.source_item_turret_limit_range_entries_state`
- Runtime proof: `/root/Main.generated_item_turret_limit_range_entries_bridge_state`

## Source facts

```java
/** Limits bullet range to this turret's range value. */
public void limitRange(float margin){
    for(var entry : ammoTypes.entries()){
        limitRange(entry.value, margin);
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1174 status in canonical ledger and registered shards.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1174 status only.
- [x] Neighbor check: `N1173 done`, `N1174 done`, `N1175 active`.
- [x] Focused tests passed: `5 passed in 0.92s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Godot MCP runtime proof passed on TCP `7777`: bridge `matches=True`, `margin=5.0`, `limit_range_call_count=3`; ledger `status=done`; shard `status=done`; nested `status=done`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 390.58s`.

## Totals

- Total slices: `1073`
- Done: `871`
- Not done: `202`
- Progress: `81.17%`
- Next unfinished slice: `N1175 ItemTurret.setStats()`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1174-item-turret-limit-range-entries-finalize.md`
