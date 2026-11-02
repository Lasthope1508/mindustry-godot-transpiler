"""Register typed Item facts, Drill blocked metadata/init and actual Block binding."""
import json
from pathlib import Path
from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
CONTENT = 'core/src/mindustry/ctype/Content.java'
LOADER = 'core/src/mindustry/core/ContentLoader.java'
ITEM = 'core/src/mindustry/type/Item.java'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
CATALOG = 'SourceContentRegistryRuntimeState.source_item_catalog_state'
INIT = 'SourceDrillRuntimeState.source_init_blocked_items_state'
BIND = 'SourceDrillRuntimeState.source_bind_ore_items_state'
PROOF = '/root/DrillOreBindingProof'
TESTS = ['test_blocked_item_parser_preserves_fields_null_and_order', 'test_ancestry_constructor_overrides_and_unresolved_descendants', 'test_real_registry_exports_drill_ancestry_and_blocked_fields', 'test_item_registration_order_and_source_priority_survive_export', 'test_ore_binding_contracts_are_registered_in_own_slices', 'test_real_catalog_drill_binding_in_godot']


def fact(typ, source, expr, rule, **extra):
    return backed(typ, source, expr, rule, **extra)


def main():
    schemas = {
        'source_item_catalog_input': ('N2011', CATALOG, {
            'content_catalog': fact('Object', LOADER, 'contentMap[content.getContentType().ordinal()].add(content);', 'Existing typed catalog; read only item registration order, never global slug lookup or alphabetical sort.'),
        }),
        'source_item_catalog_result': ('N2011', CATALOG, {
            'item_facts_by_name': fact('Dictionary', CONTENT, 'this.id = (short)Vars.content.getBy(getContentType()).size;', 'Transient slug lookup of source_drill_ore_item facts, with numeric id from the existing item sequence and effective typed Item hardness/lowPriority. No persistent registry.'),
            'item_facts_by_field': fact('Dictionary', BLOCKS, 'blockedItem = Items.thorium;', 'Transient Java-field lookup sharing the exact fact dictionary with the slug view. Unresolved references are not synthesized.'),
            'item_names_by_id': fact('Array', CONTENT, 'this.id = (short)Vars.content.getBy(getContentType()).size;', 'Existing item slugs in numeric source registration order; no second numeric-ID assignment owner.'),
        }),
        'source_drill_init_blocked_items_input': ('N2012', INIT, {
            'blocked_items': fact('Variant', DRILL, 'public @Nullable Seq<Item> blockedItems;', 'Explicit nullable Array of canonical numeric Item IDs. Existing empty/nonempty sequence is authoritative.'),
            'blocked_item': fact('Variant', DRILL, 'public @Nullable Item blockedItem;', 'Explicit nullable legacy Item numeric ID; Java reference field starts null.'),
        }),
        'source_drill_init_blocked_items_result': ('N2012', INIT, {
            'blocked_items': fact('Variant', DRILL, 'if(blockedItems == null && blockedItem != null){', 'Only null sequence plus nonnull legacy item allocates [blocked_item], matching Seq.with(blockedItem). Otherwise preserve input sequence/null and identity.'),
        }),
        'source_drill_blocked_definition': ('N2012', BIND, {
            'blockedItem': fact('Variant', DRILL, 'public @Nullable Item blockedItem;', 'Generated immutable source field reference or null, resolved through actual Drill ancestry and constructor/initializer order. Dynamic/nested expressions leave both definition keys absent.'),
            'blockedItems': fact('Variant', DRILL, 'public @Nullable Seq<Item> blockedItems;', 'Generated null or ordered Java Item field list from supported direct Seq.with references. Explicit empty is preserved; source Drill.init conversion happens at runtime.'),
        }),
        'source_drill_bind_ore_items_input': ('N2013', BIND, {
            'block': fact('Object', DRILL, 'public void init(){', 'Actual Block with both source-backed definition keys present. Missing/unresolved definitions assert instead of assuming null.', schema='source_drill_blocked_definition'),
            'item_catalog': fact('Dictionary', CONTENT, 'this.id = (short)Vars.content.getBy(getContentType()).size;', 'Transient typed item view from source_item_catalog_state; Java field resolves to canonical numeric Item.id.', schema='source_item_catalog_result'),
        }),
        'source_drill_bind_ore_items_result': ('N2013', BIND, {
            'blocked_items': fact('Variant', DRILL, 'blockedItems = Seq.with(blockedItem);', 'Resolve source field references, delegate compatibility initialization to the canonical init owner, return null/ordered numeric IDs. Source metadata and Item storage are not mutated or cached.'),
        }),
    }
    symbols = {};by_slice = {}
    for name, (slice_id, owner, keys) in schemas.items():
        for field, meta in keys.items():
            meta['used_by'] = [owner]
            symbol = name+'.'+field
            symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method='Content(); Drill.init()', java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            by_slice.setdefault(slice_id, []).append(symbol)
        source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, keys=keys, runtime_proof=PROOF))
    symbol = 'item.low_priority'
    symbols[symbol] = dict(status='source-backed', godot_owner=CATALOG, godot_symbol='MindustryItem.low_priority', java_source=ITEM, java_method='Item(String name, Color color)', java_expr='public boolean lowPriority;', rule='One typed Item field owns the Java implicit false default, then explicit generated lowPriority initialization overrides it. Catalog facts read that field.', tests=TESTS, runtime_proof=PROOF)
    by_slice['N2011'].append(symbol)
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for slice_id, owner, prefix, source, cls, method, expressions in [
        ('N2011', CATALOG, 'source_item_catalog', CONTENT, 'mindustry.ctype.Content', 'Content()', ['this.id = (short)Vars.content.getBy(getContentType()).size;', 'Vars.content.handleContent(this);']),
        ('N2012', INIT, 'source_drill_init_blocked_items', DRILL, 'mindustry.world.blocks.production.Drill', 'init()', ['if(blockedItems == null && blockedItem != null){', 'blockedItems = Seq.with(blockedItem);']),
        ('N2013', BIND, 'source_drill_bind_ore_items', DRILL, 'mindustry.world.blocks.production.Drill', 'init(); canMine(Tile tile)', ['public @Nullable Item blockedItem;', 'public @Nullable Seq<Item> blockedItems;', 'blockedItems = Seq.with(blockedItem);']),
    ]:
        inputs = schemas[prefix+'_input'][2];outputs = schemas[prefix+'_result'][2]
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=slice_id, java_source=source, source_method=method, params=[dict(name=k,type=v['type'],schema=prefix+'_input.'+k) for k,v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Canonical typed/source initialization prerequisite for live Drill ore selection. Actual Tile.drop/static/world proximity and dominant-item output remain deferred.'))
        source_symbols.upsert_source_slice(GODOT, slice_id, dict(status='done', java_source=source, java_class=cls, java_method=method, godot_owner=owner, exact_exprs=expressions, source_symbols=by_slice[slice_id], tests=TESTS, runtime_proof=PROOF, deferred_exprs=['Actual world Tile.drop/isStatic/getLinkedTilesAs providers and proximity lifecycle.', 'Live mixed-ore output and subclass production, dynamic source expressions and reload invalidation.']))
    manifest = json.loads((GODOT/'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))['modules']
    for canonical in ['content_registry','slice_ledger','api_contracts','state_schema','registry']:
        for name, module in manifest.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    main()
