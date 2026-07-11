# N1187 ItemTurretBuild.version finalize

## Scope

- Slice: `N1187`
- Upstream Java: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurretBuild.version()`
- Godot source owner: `PortGame.source_item_turret_build_version_state`
- Runtime proof: `/root/Main.generated_item_turret_build_version_bridge_state`

## Source facts

```java
@Override
public byte version(){
    return 2;
}
```

This slice covers only the upstream `version()` return value. Adjacent `write(Writes write)` serialization remains `N1188`.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler spec/checklist context.
- [x] Read SSOT roots and module shards.
- [x] Read upstream Java source.
- [x] RED test added for N1187 status in canonical ledger.
- [x] RED verified: expected `AssertionError: 'active' != 'done'`.
- [x] GREEN changed N1187 status only.
- [x] Neighbor check: `N1186 done`, `N1187 done`, `N1188 active`.
- [x] Focused tests passed: `5 passed in 0.85s`.
- [x] SSOT validator passed: `errors=[]`, `module_count=112`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed in 388.76s`.
- [x] Godot MCP runtime proof passed on TCP `7777`: generated bridge `matches=true`, generated version `2`, canonical version `2`, exact return expr `return 2;`.
- [x] Godot MCP debug output checked: `errors=[]`.
- [x] Godot project stopped: `finalErrors=[]`.

## Totals

- Total slices: `1073`
- Done: `884`
- Not done: `189`
- Progress: `82.39%`
- Next unfinished slice: `N1188 ItemTurretBuild.write(Writes)`

## Files

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1187-item-turret-build-version-finalize.md`
