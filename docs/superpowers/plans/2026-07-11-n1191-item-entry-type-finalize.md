# N1191 ItemEntry.type Finalize

## Scope

- Slice: `N1191`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemEntry.type()`
- Godot owner: `PortGame.source_item_entry_type_state`
- Runtime proof: `/root/Main.generated_item_entry_type_bridge_state`

## Source Evidence

Exact upstream expressions preserved:

- `public class ItemEntry extends AmmoEntry{`
- `@Override`
- `public BulletType type(){`
- `return ammoTypes.get(item);`

Deferred to later slices:

- `ItemEntry.toString()`
- Concrete `ammoTypes` map internals beyond explicit `ammoTypes.get(item)` result input.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read migration spec entry for `N1191`.
- [x] Read SSOT roots and N1191 shards.
- [x] Read exact upstream Java method.
- [x] Added RED status assertion in `test_generated_item_entry_type_slice_is_registered_with_source_backing`.
- [x] RED failed for expected reason: `active != done`.
- [x] GREEN updated N1191 status in canonical ledger and mirror shards.
- [x] Focused tests passed: `5 passed`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed`.
- [x] Godot MCP runtime started project and returned `errors=[]` before runtime call.
- [x] TCP runtime proof called `/root/Main.generated_item_entry_type_bridge_state`.
- [x] Runtime `item="copper", ammo_type={name:"copper-bullet",damage:9}` returned `matches=true` and matching `type`.
- [x] Runtime `item="scrap", ammo_type=null` returned `matches=true` and `type=null`.
- [x] Godot debug output after runtime proof returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Progress

- Total slices: `1073`
- Done: `888`
- Not done: `185`
- Progress: `82.76%`

## Files Updated

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1191-item-entry-type-finalize.md`

## Next

- `N1192`: `ItemEntry.toString()`
- Status before next slice: `active`
