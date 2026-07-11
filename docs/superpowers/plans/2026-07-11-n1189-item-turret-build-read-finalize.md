# N1189 ItemTurretBuild.read Finalize

## Scope

- Slice: `N1189`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurretBuild.read(Reads, byte)`
- Godot owner: `PortGame.source_item_turret_build_read_state`
- Runtime proof: `/root/Main.generated_item_turret_build_read_bridge_state`

## Source Evidence

Exact upstream expressions preserved:

- `public class ItemTurretBuild extends TurretBuild{`
- `@Override`
- `public void read(Reads read, byte revision){`
- `super.read(read, revision);`
- `ammo.clear();`
- `totalAmmo = 0;`
- `int amount = read.ub();`
- `for(int i = 0; i < amount; i++){`
- `Item item = Vars.content.item(revision < 2 ? read.ub() : read.s());`
- `int itemAmount = Math.min(read.s(), maxAmmo);`
- `//only add ammo if this is a valid ammo type`
- `if(item != null && ammoTypes.containsKey(item)){`
- `totalAmmo += itemAmount;`
- `ammo.add(new ItemEntry(item, itemAmount));`

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read migration spec entry for `N1189`.
- [x] Read SSOT roots and N1189 shards.
- [x] Read exact upstream Java method.
- [x] Added RED status assertion in `test_generated_item_turret_build_read_slice_is_registered_with_source_backing`.
- [x] RED failed for expected reason: `active != done`.
- [x] GREEN updated N1189 status in canonical ledger and mirror shards.
- [x] Focused tests passed: `5 passed`.
- [x] SSOT validator passed: `module_count=112`, `errors=[]`, `defense_checked=137`, `ledger_checked=1073`.
- [x] Full Python suite passed: `4017 passed, 39290 subtests passed`.
- [x] Godot MCP runtime started project and reported runtime addon connected.
- [x] TCP runtime proof called `/root/Main.generated_item_turret_build_read_bridge_state`.
- [x] Runtime revision `<2` branch used `read.ub();`, clamped `copper` amount `6 -> 4`, skipped invalid/null ammo, and returned `matches=true`.
- [x] Runtime revision `>=2` branch used `read.s();`, added valid `lead`, skipped null ammo, and returned `matches=true`.
- [x] Godot debug output after runtime proof returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Progress

- Total slices: `1073`
- Done: `886`
- Not done: `187`
- Progress: `82.57%`

## Files Updated

- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_modules/defense_slices.json`
- `godot-mindustry/src/generated/source_modules/source_slice_ledger_slices.json`
- `tools/mindustry_godot_transpiler/tests/test_source_symbols.py`
- `docs/superpowers/plans/2026-07-11-n1189-item-turret-build-read-finalize.md`

## Next

- `N1190`: `ItemEntry(Item, int)`
- Status before next slice: `active`
