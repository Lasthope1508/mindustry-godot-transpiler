"""Register canonical geometry composition, dense Tile storage and real bootstrap wiring.

Field/proxy projection is intentionally narrower than complete Tile.setBlock lifecycle.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TILE = 'core/src/mindustry/world/Tile.java'
TILES = 'core/src/mindustry/world/Tiles.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
WORLD = 'core/src/mindustry/core/World.java'
SAVE = 'core/src/mindustry/io/SaveVersion.java'
PROOF = '/root/WorldTileLifecycleProof'
TESTS = ['test_world_tile_lifecycle_contracts', 'test_actual_world_bootstrap_and_placement', 'test_unknown_map_content_rejected', 'test_incomplete_map_terrain_rejected']
OWNER = 'SourceWorldTerrainRuntimeState.'
DEFERRED = ['Tile.setBlock overlapping entity removal, changeBuild, events, recache, team and proximity lifecycle.', 'setFloor/setOverlay notifications, pickup/removal/reload invalidation and save/network persistence.', 'Drill onProximityUpdate and actual dominant-item production/output; legacy rendering ore projection remains a compatibility path.']


def fact(typ, source, expr, rule, **extra):
    return backed(typ, source, expr, rule, **extra)


def main():
    definitions = {}
    contracts = []
    by_slice = {}
    symbols = {}

    def schema(name, owner, slice_id, fields):
        definitions[name] = (owner, fields)
        for key, meta in fields.items():
            meta['used_by'] = [owner]
            symbol = name + '.' + key
            symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method='Tiles.fill/get; Tile fields/getLinkedTilesAs; Block.init; SaveVersion.readMap', java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            by_slice.setdefault(slice_id, []).append(symbol)
        source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=slice_id, keys=fields, runtime_proof=PROOF))

    def register(method, slice_id, source, source_method, params, outputs=None, owner=None):
        owner = owner or OWNER + method
        prefix = 'source_' + method.removeprefix('source_')
        schema(prefix + '_input', owner, slice_id, params)
        if outputs is not None:
            schema(prefix + '_result', owner, slice_id, outputs)
        contracts.append((owner, slice_id, source, source_method, prefix, params, outputs))

    def block():
        return fact('Object', TILE, 'this.block = type;', 'Actual typed canonical Block; unresolved definitions are rejected.', schema='source_terrain_block_definition')

    def scale():
        return fact('float', BLOCK, 'offset = ((size + 1) % 2) * tilesize / 2f;', 'Existing source tilesize input passed to canonical Block.init offset owner; no second formula.')

    def catalog():
        return fact('Object', SAVE, 'Block block = content.block(stream.readShort());', 'Actual loaded typed content catalog. Resolve exact map content ID or source field; no slug conversion or fabricated Block.')

    def world():
        return fact('Dictionary', WORLD, 'public Tiles tiles = new Tiles(0, 0);', 'Single dense source Tile storage; placed_blocks remains the Building sprite index, never a competing terrain/ore owner.', schema='source_world_tiles_state_result')

    def coord(axis):
        return fact('int', TILES, 'array[y*width + x]', 'Source Tile ' + axis + ' coordinate.')

    def world_fields():
        return {
            'width': fact('int', TILES, 'this.width = width;', 'Actual logical map width; independent of viewport background.'),
            'height': fact('int', TILES, 'this.height = height;', 'Actual logical map height.'),
            'array': fact('Array', TILES, 'this.array = new Tile[width * height];', 'Dense y*width+x storage of actual Tile dictionaries preserving Block identity. Coordinates and nullable ore facts have existing canonical providers.', schema='source_world_tile_definition'),
        }

    register('source_block_geometry_state', 'N2017', BLOCK, 'init(); isMultiblock()', {'block': block(), 'source_tilesize': scale()}, {
        'size': fact('int', BLOCK, 'public int size = 1;', 'Reuse existing SourceBlockMetadataState.block_size source default and definition.'),
        'size_offset': fact('int', BLOCK, 'sizeOffset = -((size - 1) / 2);', 'Reuse existing SourceBlockInitPlacementState.offset_state; no separate formula or stale geometry cache.'),
        'is_multiblock': fact('bool', BLOCK, 'return size > 1;', 'Reuse existing SourceBlockQueryBasicState.is_multiblock_state.'),
    })
    schema('source_world_tile_definition', OWNER + 'source_world_tiles_state', 'N2018', {
        'x': fact('int', TILES, 'new Tile(i % width, i / width)', 'Source logical x coordinate.'),
        'y': fact('int', TILES, 'new Tile(i % width, i / width)', 'Source logical y coordinate.'),
        **{key: fact('Object', TILE, 'block = floor = overlay = (Floor)Blocks.air;', 'Actual ' + key + ' reference, source air at fill; exact loaded definition on materialization.', schema='source_terrain_block_definition') for key in ['floor', 'overlay', 'block']},
    })
    register('source_world_tiles_state', 'N2018', TILES, 'Tiles(int width, int height); fill()', {
        'width': fact('int', TILES, 'this.width = width;', 'Positive logical map width.'),
        'height': fact('int', TILES, 'this.height = height;', 'Positive logical map height.'),
        'air_block': fact('Object', TILE, 'block = floor = overlay = (Floor)Blocks.air;', 'Actual canonical air reference; never inferred from id equality.'),
    }, world_fields())
    register('source_world_tile', 'N2018', TILES, 'get(int x, int y)', {'world_tiles': world(), 'x': coord('x'), 'y': coord('y')})
    register('source_record_world_block', 'N2019', TILE, 'setBlock(Block type, Team team, int rotation, Prov<Building> entityprov)', {'world_tiles': world(), 'block': block(), 'x': coord('x'), 'y': coord('y'), 'source_tilesize': scale()})
    register('source_world_block_by_field', 'N2018', BLOCKS, 'load()', {'content_catalog': catalog(), 'field': fact('String', BLOCKS, 'public static Block', 'Exact registered source field identifier, not a slug-derived guess.')})
    register('source_campaign_world_tiles_state', 'N2018', SAVE, 'readMap(DataInput stream, WorldContext context)', {
        'campaign_map_tile_state': fact('Dictionary', SAVE, 'context.create(x, y, floorid, oreid, (short)0);', 'Existing decoded map dimensions, complete ordered floor runs and center/static block placements; validate full coverage before claiming materialization.'),
        'content_catalog': catalog(), 'source_tilesize': scale(),
    }, world_fields())
    register('source_game_world_tiles_state', 'N2019', WORLD, 'resize(int width, int height)', {
        'game': fact('Object', WORLD, 'public Tiles tiles = new Tiles(0, 0);', 'Actual game bootstrap owner with loaded content and source tilesize.'),
        'initial_build_state': fact('Dictionary', SAVE, 'context.resize(width, height);', 'Existing canonical initial build plan: consumed campaign map wins; otherwise explicit builtin scenario source field bindings and logical layout, independent of textures.'),
    }, world_fields())
    register('game_world_tile', 'N2019', WORLD, 'tile(int x, int y)', {'x': coord('x'), 'y': coord('y')}, owner='PortGame.source_world_tile')
    register('source_world_linked_ore_tiles', 'N2019', TILE, 'getLinkedTilesAs(Block block, Seq<Tile> tmpArray)', {'block': block(), 'x': coord('x'), 'y': coord('y'), 'item_catalog': fact('Dictionary', TILE, 'return overlay == Blocks.air || overlay.itemDrop == null ? floor.itemDrop : overlay.itemDrop;', 'Shared typed numeric Item catalog supplied to existing Tile ore provider.', schema='source_item_catalog_result')}, {'ore_tiles': fact('Array', TILE, 'getLinkedTilesAs(block, tmpArray::add);', 'Actual world lookup plus canonical geometry/static/drop composition; no new ore-selection or production algorithm.', schema='source_drill_ore_tile')}, owner='PortGame.source_world_linked_ore_tiles_state')
    for name, value, expr in [('AIR', 'air', 'air = new AirBlock("air");'), ('STONE', 'stone', 'stone = new Floor("stone");'), ('SCENARIO_ORE', 'oreCopper', 'oreCopper = new OreBlock(Items.copper){{')]:
        symbol = 'world_tile_source_fields.' + value
        symbols[symbol] = dict(status='source-backed', godot_owner=OWNER + 'source_game_world_tiles_state', godot_symbol='SourceWorldTerrainRuntimeState.SOURCE_WORLD_' + name + '_FIELD', java_source=BLOCKS, java_method='load()', java_expr=expr, value=value, rule='Source field identity for air/SaveVersion air-floor replacement and existing explicit copper scenario. Not an allowlist or inference for arbitrary map content.', tests=TESTS, runtime_proof=PROOF)
        by_slice.setdefault('N2019', []).append(symbol)
    storage_symbol = 'world_tile_game_storage.tiles'
    symbols[storage_symbol] = dict(status='source-backed', godot_owner=OWNER + 'source_game_world_tiles_state', godot_symbol='PortGame.source_world_tiles', java_source=WORLD, java_method='World.tile(int x, int y)', java_expr='public Tiles tiles = new Tiles(0, 0);', rule='One authoritative dense Tile container per actual game world, initialized before static/dynamic placement. Sprite indexes remain Building references.', tests=TESTS, runtime_proof=PROOF)
    by_slice['N2019'].append(storage_symbol)
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for owner, slice_id, source, method, prefix, inputs, outputs in contracts:
        # Catalog contracts describe Dictionary results. Scalar/void helpers retain
        # source-backed input symbols/schemas without fabricating a result wrapper.
        if outputs is None:
            continue
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=slice_id, java_source=source, source_method=method, params=[dict(name=key, type=meta['type'], schema=prefix + '_input.' + key) for key, meta in inputs.items()], return_keys=list(outputs or {}), tests=TESTS, runtime_proof=PROOF, rule='Canonical geometry/dense Tile field projection and real bootstrap/placement wiring only. Complete entity removal, proximity, persistence and dominant production remain explicitly deferred.'))
    for slice_id, owner, source, cls, method, expressions in [
        ('N2017', OWNER + 'source_block_geometry_state', BLOCK, 'mindustry.world.Block', 'init(); isMultiblock()', ['sizeOffset = -((size - 1) / 2);', 'return size > 1;']),
        ('N2018', OWNER + 'source_campaign_world_tiles_state', SAVE, 'mindustry.io.SaveVersion', 'readMap(DataInput stream, WorldContext context)', ['context.resize(width, height);', 'if(content.block(floorid) == Blocks.air) floorid = Blocks.stone.id;', 'context.create(x, y, floorid, oreid, (short)0);']),
        ('N2019', OWNER + 'source_game_world_tiles_state', TILE, 'mindustry.world.Tile', 'setBlock(Block type, Team team, int rotation, Prov<Building> entityprov)', ['this.block = type;', 'other.block = block;']),
    ]:
        source_symbols.upsert_source_slice(GODOT, slice_id, dict(status='done', java_source=source, java_class=cls, java_method=method, godot_owner=owner, exact_exprs=expressions, source_symbols=by_slice[slice_id], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))
    source_symbols.write_source_symbol_audit_report(GODOT)
    modules = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text())['modules']
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    main()
