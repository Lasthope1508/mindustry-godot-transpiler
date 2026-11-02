"""Register source constructor terrain facts and canonical Tile/footprint binding."""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BLOCK = 'core/src/mindustry/world/Block.java'
TILE = 'core/src/mindustry/world/Tile.java'
ORE = 'core/src/mindustry/world/blocks/environment/OreBlock.java'
PROVIDER = 'SourceWorldTerrainRuntimeState.source_tile_ore_state'
LINKED = 'SourceWorldTerrainRuntimeState.source_linked_ore_tiles_state'
PROOF = '/root/TileOreProviderProof'
TESTS = ['test_item_constructor_uses_source_name_not_field_slug', 'test_source_ancestry_static_and_explicit_null', 'test_constructor_evaluation_and_unresolved_writes', 'test_creators_keep_source_positions_after_java_text_block', 'test_terrain_contracts_registered', 'test_actual_tile_and_linked_provider_in_godot', 'test_missing_tile_metadata_is_rejected']


def fact(typ, source, expr, rule, **extra):
    return backed(typ, source, expr, rule, **extra)


def main():
    schemas = {
        'source_terrain_block_definition': ('N2014', PROVIDER, {
            'itemDrop': fact('Variant', BLOCK, 'public @Nullable Item itemDrop = null;', 'Source constructor/initializer definition, null or exact Java Item field. Actual inherited constructor signature and delegation are evaluated; unsupported writes stay absent. No slug-derived Item lookup.'),
            'cacheLayer': fact('String', BLOCK, 'public CacheLayer cacheLayer = CacheLayer.normal;', 'Source CacheLayer field suffix through class constructor ancestry/initializer. Unknown conditional/dynamic/late writes leave key absent; never infer static from occupancy or sprite.'),
        }),
        'source_terrain_tile_definition': ('N2015', PROVIDER, {
            'floor': fact('Object', TILE, 'protected Floor floor;', 'Actual source-backed floor Block object; requires explicit itemDrop, including null.', schema='source_terrain_block_definition'),
            'overlay': fact('Object', TILE, 'protected Floor overlay;', 'Actual overlay Block object, preserving source reference identity and explicit itemDrop.', schema='source_terrain_block_definition'),
            'block': fact('Object', TILE, 'protected Block block;', 'Actual occupying Block object with resolved source cacheLayer.', schema='source_terrain_block_definition'),
        }),
        'source_tile_ore_input': ('N2015', PROVIDER, {
            'tile': fact('Dictionary', TILE, 'public @Nullable Item drop(){', 'Explicit source Tile projection with actual floor/overlay/occupying Block objects. Missing definitions assert; no world-map deserialization or live ownership is claimed.', schema='source_terrain_tile_definition'),
            'item_catalog': fact('Dictionary', ORE, 'this.itemDrop = ore;', 'Existing typed Item facts resolve exact Java field references, preserving canonical numeric IDs and fact identity.', schema='source_item_catalog_result'),
            'air_block': fact('Object', TILE, 'overlay == Blocks.air', 'Actual canonical air Block reference. Equality uses identity, never matching a slug or class name.'),
        }),
        'source_tile_ore_result': ('N2015', PROVIDER, {
            'is_static': fact('bool', BLOCK, 'return cacheLayer == CacheLayer.walls;', 'Delegate existing SourceBlockQueryBasicState.is_static_state with actual Block definition.'),
            'drop': fact('Variant', TILE, 'return overlay == Blocks.air || overlay.itemDrop == null ? floor.itemDrop : overlay.itemDrop;', 'Delegate existing SourceBlockGeometry.tile_drop_state; return nullable shared canonical Item fact, without copying.', schema='source_drill_ore_item'),
        }),
        'source_linked_ore_tiles_input': ('N2016', LINKED, {
            'block_is_multiblock': fact('bool', TILE, 'if(block.isMultiblock()){', 'Explicit source geometry fact; lifecycle/init binder is not synthesized.'),
            'block_size': fact('int', TILE, 'int size = block.size, o = block.sizeOffset;', 'Explicit source Block size.'),
            'size_offset': fact('int', TILE, 'int size = block.size, o = block.sizeOffset;', 'Actual initialized Block.sizeOffset supplied by caller; no alternate footprint formula.'),
            'x': fact('int', TILE, 'world.tile(x + dx + o, y + dy + o)', 'Source tile x coordinate.'),
            'y': fact('int', TILE, 'world.tile(x + dx + o, y + dy + o)', 'Source tile y coordinate.'),
            'world_tile_lookup': fact('Callable', TILE, 'Tile other = world.tile(x + dx + o, y + dy + o);', 'Source world provider returning source_terrain_tile_definition or null. World storage/load/mutation ownership remains caller responsibility.'),
            'self_tile': fact('Dictionary', TILE, 'tmpArray.get(this);', 'Actual self tile for the non-multiblock branch; no lookup is performed.', schema='source_terrain_tile_definition'),
            'item_catalog': fact('Dictionary', ORE, 'this.itemDrop = ore;', 'Existing typed source Item facts.', schema='source_item_catalog_result'),
            'air_block': fact('Object', TILE, 'overlay == Blocks.air', 'Actual canonical air reference shared with Tile provider.'),
        }),
        'source_linked_ore_tiles_result': ('N2016', LINKED, {
            'ore_tiles': fact('Array', TILE, 'getLinkedTilesAs(block, tmpArray::add);', 'Delegate existing canonical linked geometry, then Tile provider. Preserve source iteration order and skip only null world tiles. Elements use source_drill_ore_tile; compatible with canonical countOre.', schema='source_drill_ore_tile'),
        }),
    }
    symbols = {};by_slice = {}
    for name, (slice_id, owner, keys) in schemas.items():
        for field, meta in keys.items():
            meta['used_by'] = [owner]
            symbol = name + '.' + field
            symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method='Block constructors; Tile.drop(); Tile.getLinkedTilesAs()', java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            by_slice.setdefault(slice_id, []).append(symbol)
        source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, keys=keys, runtime_proof=PROOF))
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for slice_id, owner, prefix in [('N2015', PROVIDER, 'source_tile_ore'), ('N2016', LINKED, 'source_linked_ore_tiles')]:
        inputs, outputs = schemas[prefix + '_input'][2], schemas[prefix + '_result'][2]
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=slice_id, java_source=TILE, source_method='drop(); getLinkedTilesAs(Block, Seq)', params=[dict(name=k,type=v['type'],schema=prefix + '_input.' + k) for k,v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Actual source-backed object projection delegates existing canonical geometry/static owners. Supplied world callback only; real game world/proximity/output lifecycle remains deferred.'))
    for slice_id, owner, source, cls, method, expressions in [
        ('N2014', PROVIDER, ORE, 'mindustry.world.blocks.environment.OreBlock', 'OreBlock(Item); OreBlock(String, Item); source Block constructors', ['this("ore-" + ore.name, ore);', 'this.itemDrop = ore;']),
        ('N2015', PROVIDER, TILE, 'mindustry.world.Tile', 'drop()', ['return overlay == Blocks.air || overlay.itemDrop == null ? floor.itemDrop : overlay.itemDrop;']),
        ('N2016', LINKED, TILE, 'mindustry.world.Tile', 'getLinkedTilesAs(Block block, Seq<Tile> tmpArray)', ['getLinkedTilesAs(block, tmpArray::add);', 'Tile other = world.tile(x + dx + o, y + dy + o);', 'if(other != null) tmpArray.get(other);']),
    ]:
        source_symbols.upsert_source_slice(GODOT, slice_id, dict(status='done', java_source=source, java_class=cls, java_method=method, godot_owner=owner, exact_exprs=expressions, source_symbols=by_slice[slice_id], tests=TESTS, runtime_proof=PROOF, deferred_exprs=['Real world terrain load/mutation/storage and initialized geometry binder; current projection requires explicit complete source inputs.', 'Drill onProximityUpdate/invalidation, actual dominant production and live mixed-ore gameplay.', 'Arbitrary Java constructor/method interpretation, dynamic terrain definitions and mod reload.']))
    modules = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text())['modules']
    for canonical in ['content_registry', 'slice_ledger', 'api_contracts', 'state_schema', 'registry']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    main()
