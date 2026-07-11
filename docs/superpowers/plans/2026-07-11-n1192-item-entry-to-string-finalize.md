# N1192 ItemEntry.toString Finalize

## Scope

- Slice: `N1192`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemEntry.toString()`
- Godot owner: `PortGame.source_item_entry_to_string_state`
- Runtime proof: `/root/Main.generated_item_entry_to_string_bridge_state`

## Source Evidence

Exact upstream expressions preserved:

- `public class ItemEntry extends AmmoEntry{`
- `@Override`
- `public String toString(){`
- `return "ItemEntry{" +`
- `"item=" + item +`
- `", amount=" + amount +`
- `'}';`

Deferred:

- `Item.toString()` internals remain explicit input as `item_string`.
- Wider LiquidTurret slices start at `N1193`.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read migration spec entry for `N1192`.
- [x] Read SSOT roots and N1192 shards.
- [x] Read exact upstream Java method.
- [x] Added RED status assertion in `test_generated_item_entry_to_string_slice_is_registered_with_source_backing`.
- [x] RED failed for expected reason: `active != done`.
- [x] GREEN updated N1192 status in canonical ledger and mirror shards.
- [x] Focused tests passed: `5 passed`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed`.
- [x] Godot MCP runtime started project and returned `errors=[]` before runtime call.
- [x] TCP runtime proof called `/root/Main.generated_item_entry_to_string_bridge_state`.
- [x] Runtime `item_string="copper", amount=7` returned `matches=true` and `to_string="ItemEntry{item=copper, amount=7}"`.
- [x] Runtime `item_string="null", amount=0` returned `matches=true` and `to_string="ItemEntry{item=null, amount=0}"`.
- [x] Godot debug output after runtime proof returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Progress

- Total slices: `1073`
- Done: `889`
- Not done: `184`
- Progress: `82.85%`

## Files Updated

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1192-item-entry-to-string-finalize.md`

## Next

- `N1193`: `LiquidTurret.ammo(Object...)`
- Status before next slice: `active`
