# N1173 ItemTurret.limitRange default finalize

## Scope

- Slice: `N1173`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurret.limitRange()`
- Godot source owner: `PortGame.source_item_turret_limit_range_default_state`
- Runtime proof: `/root/Main.generated_item_turret_limit_range_default_bridge_state`

## Source facts

```java
/** Limits bullet range to this turret's range value. */
public void limitRange(){
    limitRange(9f);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1173 status in canonical ledger and registered shards.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1173 status only.
- [x] Neighbor check: `N1172 done`, `N1173 done`, `N1174 active`.
- [x] Focused tests passed: `5 passed in 0.92s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Godot MCP runtime proof passed on TCP `7777`: bridge `matches=True`, `margin=9.0`, `limit_range_called=True`; ledger `status=done`; shard `status=done`; nested `status=done`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 400.46s`.

## Totals

- Total slices: `1073`
- Done: `870`
- Not done: `203`
- Progress: `81.08%`
- Next unfinished slice: `N1174 ItemTurret.limitRange(float margin)`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1173-item-turret-limit-range-default-finalize.md`
