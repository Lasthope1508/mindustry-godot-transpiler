# N1190 ItemEntry Constructor Finalize

## Scope

- Slice: `N1190`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemEntry(Item, int)`
- Godot owner: `PortGame.source_item_entry_constructor_state`
- Runtime proof: `/root/Main.generated_item_entry_constructor_bridge_state`

## Source Evidence

Exact upstream expressions preserved:

- `public class ItemEntry extends AmmoEntry{`
- `public Item item;`
- `ItemEntry(Item item, int amount){`
- `this.item = item;`
- `this.amount = amount;`

Deferred to later slices:

- `ItemEntry.type()`
- `ItemEntry.toString()`

## Checklist

- [x] Read `AGENTS.md` earlier this run.
- [x] Read migration spec entry for `N1190`.
- [x] Read SSOT roots and N1190 shards.
- [x] Read exact upstream Java constructor.
- [x] Added RED status assertion in `test_generated_item_entry_constructor_slice_is_registered_with_source_backing`.
- [x] RED failed for expected reason: `active != done`.
- [x] GREEN updated N1190 status in canonical ledger and mirror shards.
- [x] Focused tests passed: `5 passed`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed`.
- [x] Godot MCP runtime started project and returned `errors=[]` before runtime call.
- [x] TCP runtime proof called `/root/Main.generated_item_entry_constructor_bridge_state`.
- [x] Runtime `item="copper", amount=7` returned `matches=true`, `item_after="copper"`, `amount_after=7`.
- [x] Runtime `item=null, amount=0` returned `matches=true`, `item_after=null`, `amount_after=0`.
- [x] Godot debug output after runtime proof returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Progress

- Total slices: `1073`
- Done: `887`
- Not done: `186`
- Progress: `82.67%`

## Files Updated

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1190-item-entry-constructor-finalize.md`

## Next

- `N1191`: `ItemEntry.type()`
- Status before next slice: `active`
