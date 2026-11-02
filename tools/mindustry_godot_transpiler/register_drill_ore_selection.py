"""Register complete Drill canMine/countOre state over explicit source facts."""
import json
from pathlib import Path
from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
ITEM = 'core/src/mindustry/type/Item.java'
TILE = 'core/src/mindustry/world/Tile.java'
CAN = 'SourceDrillRuntimeState.source_can_mine_state'
COUNT = 'SourceDrillRuntimeState.source_count_ore_state'
PROOF = '/root/DrillOreSelectionProof'
TESTS = ['test_ore_selection_contracts_and_source_evidence', 'test_independent_ore_selection_matrix_in_godot']


def fact(typ, source, expr, rule, **extra):
    return backed(typ, source, expr, rule, **extra)


def main():
    tier = fact('int', DRILL, 'public int tier;', 'Explicit source Drill tier; no fallback.')
    blocked = fact('Variant', DRILL, '(blockedItems == null || !blockedItems.contains(drops))', 'Nullable Array of canonical numeric Item IDs, not names or slugs. Caller supplies initialized blockedItems; blockedItem compatibility initialization remains in Drill.init.')
    schemas = {
        'source_drill_ore_item': (COUNT, {
            'id': fact('int', DRILL, 'return Integer.compare(item1.id, item2.id);', 'Canonical numeric Item.id supplied explicitly; never infer from a slug or dictionary iteration.'),
            'hardness': fact('int', ITEM, 'public int hardness = 0;', 'Explicit effective Item hardness; no zero fallback.'),
            'low_priority': fact('bool', DRILL, 'int type = Boolean.compare(!item1.lowPriority, !item2.lowPriority);', 'Explicit effective Item.lowPriority, including the Java false field default; no guessed priority.'),
        }),
        'source_drill_ore_tile': (COUNT, {
            'is_static': fact('bool', DRILL, 'tile.block().isStatic()', 'Explicit result of actual tile Block.isStatic; no inference from occupancy.'),
            'drop': fact('Variant', TILE, 'public @Nullable Item drop(){', 'Nullable Item facts by reference; actual Tile.drop and Drill.getDrop adapters remain caller responsibilities.', schema='source_drill_ore_item'),
        }),
        'source_drill_can_mine_input': (CAN, {
            'tile': fact('Variant', DRILL, 'if(tile == null || tile.block().isStatic()) return false;', 'Nullable explicit Tile projection; no map integration is claimed.', schema='source_drill_ore_tile'),
            'tier': dict(tier), 'blocked_items': dict(blocked),
        }),
        'source_drill_can_mine_result': (CAN, {
            'can_mine': fact('bool', DRILL, 'return drops != null && drops.hardness <= tier && (blockedItems == null || !blockedItems.contains(drops));', 'Source canMine result after null/static guard.'),
        }),
        'source_drill_count_ore_input': (COUNT, {
            'linked_tiles': fact('Array', DRILL, 'for(Tile other : tile.getLinkedTilesAs(this, tempTiles)){', 'Explicit complete linked footprint in caller order; Tile projection uses source_drill_ore_tile. No live-world lookup or proximity invalidation is fabricated.'),
            'tier': dict(tier), 'blocked_items': dict(blocked),
        }),
        'source_drill_count_ore_result': (COUNT, {
            'returnItem': fact('Variant', DRILL, 'returnItem = itemArray.peek();', 'Selected Item facts by reference or null after empty/reset; actual state rather than legacy method-text metadata.', schema='source_drill_ore_item'),
            'returnCount': fact('int', DRILL, 'returnCount = oreCount.get(itemArray.peek(), 0);', 'Selected item count; zero for no mineable tiles.'),
            'oreCount': fact('Dictionary', DRILL, 'oreCount.increment(getDrop(other), 0, 1);', 'Transient counts keyed by canonical numeric Item.id; each eligible linked tile contributes one.'),
            'itemArray': fact('Array', DRILL, 'itemArray.sort((item1, item2) -> {', 'Ascending lowPriority/amount/numeric-ID ordering; peek selects the last. Item references preserved; fresh transient array per call.'),
        }),
    }
    symbols = {}
    for name, (owner, keys) in schemas.items():
        for field, meta in keys.items():
            meta['used_by'] = [owner]
            symbols[name + '.' + field] = dict(status='source-backed', godot_owner=owner, godot_symbol=name+'.'+field, java_source=meta['java_source'], java_method='canMine(Tile); countOre(Tile)', java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
        source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, keys=keys, runtime_proof=PROOF))
    for owner, prefix, method in [(CAN, 'source_drill_can_mine', 'canMine(Tile tile)'), (COUNT, 'source_drill_count_ore', 'countOre(Tile tile)')]:
        inputs = schemas[prefix+'_input'][1];outputs = schemas[prefix+'_result'][1]
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice='N2010', java_source=DRILL, source_method=method, params=[dict(name=k,type=v['type'],schema=prefix+'_input.'+k) for k,v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Canonical source state over explicit initialized source facts. Existing selected-item ore_count preview remains a bounded map counter; live mixed-ore binding/proximity integration is deferred.'))
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.upsert_source_slice(GODOT, 'N2010', dict(status='done', java_source=DRILL, java_class='mindustry.world.blocks.production.Drill', java_method='canMine(Tile tile); countOre(Tile tile)', godot_owner=COUNT, exact_exprs=['if(tile == null || tile.block().isStatic()) return false;', 'int type = Boolean.compare(!item1.lowPriority, !item2.lowPriority);', 'int amounts = Integer.compare(oreCount.get(item1, 0), oreCount.get(item2, 0));', 'return Integer.compare(item1.id, item2.id);', 'returnItem = itemArray.peek();'], source_symbols=list(symbols), tests=TESTS, runtime_proof=PROOF, deferred_exprs=['Live Tile.drop/isStatic/getLinkedTilesAs providers, canonical Item ordinal binding and initialized blockedItems adapter.', 'DrillBuild.onProximityUpdate assignment/invalidation and replacement of the bounded single-ore gameplay projection.']))
    manifest = json.loads((GODOT/'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))['modules']
    for canonical in ['slice_ledger','api_contracts','state_schema','registry']:
        for name, module in manifest.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    main()
