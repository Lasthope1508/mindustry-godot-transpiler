"""Register schematic placement binding for Tile.setBlock (N2035-N2037)."""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TILE = 'core/src/mindustry/world/Tile.java'
TEAM = 'core/src/mindustry/game/Team.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BUILD = 'core/src/mindustry/world/Build.java'
SCHEMATICS = 'core/src/mindustry/game/Schematics.java'
SCHEMATIC = 'core/src/mindustry/game/Schematic.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/SchematicPlaceProof'
TESTS = ['test_schematic_place_binding_registration', 'test_all_schematic_place_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_schematic_place']
DEFERRED = [
    'Build.validPlace has no runtime equivalent yet (rules visibility, core protection, fog, darkness, unit overlap, canPlaceOn/canReplace); the per-tile valid-place hook is caller-supplied and placement is fail-closed without one.',
    'Schematics.placeLoadout stays open: core-tile anchoring, schematicPriority sort, blocking-build removal pass and registerCore.',
    'Per-block-type config application beyond the tile_config_callback stays open; the callback receives (null, building, config) like Call.tileConfig.',
    'Superclass noSleep, power onProximity hooks, turret unregister, controller pickup, world transitions and remaining Tile/Floor side effects stay open in C01.',
    'C02 inventory/offload/dump/transport and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

SET_BLOCK = 'tile.setBlock(st.block, team, st.rotation);'
TILE_LOOKUP = 'Tile tile = world.tile(st.x + ox, st.y + oy);'
PLACE_GUARD = 'if(tile == null || (!overwrite && !Build.validPlace(st.block, team, tile.x, tile.y, st.rotation))) return;'
VALID_PLACE = '!Build.validPlace(st.block, team, tile.x, tile.y, st.rotation)'
CONFIGURE_ANY = 'tile.build.configureAny(config);'
PLACE_ORIGIN = 'int ox = x - schem.width/2, oy = y - schem.height/2;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=SCHEMATICS, **extra):
        return backed(typ, source, expr, rule, **extra)

    # N2035: one schematic tile through the placement funnel.
    n2035_inputs = {
        'game': f('Object', TILE_LOOKUP, 'Actual game world containing the Tile store, placement index and content catalog.'),
        'stile': f('Dictionary', 'schem.tiles.each(st -> {', 'Actual schematic tile: block, cell offsets, config and rotation.'),
        'origin_cell': f('Vector2i', PLACE_ORIGIN, 'Actual schematic origin cell; stile offsets are added to it.'),
        'team_id': f('int', SET_BLOCK, 'Actual Team id the schematic is placed for; threaded through the placement funnel.'),
        'overwrite': f('bool', PLACE_GUARD, 'Whether placement may replace an existing Building without a valid-place check.'),
        'valid_place_hook': f('Callable', VALID_PLACE, 'Caller-supplied Build.validPlace equivalent; placement is fail-closed without one when overwrite is false.'),
        'tile_config_callback': f('Callable', CONFIGURE_ANY, 'Caller-supplied Call.tileConfig equivalent applied to the placed Building.'),
    }
    n2035_outputs = {
        'cell': f('Vector2i', TILE_LOOKUP, 'Actual placement cell the stile resolved to.'),
        'tile': f('Variant', TILE_LOOKUP, 'Actual resolved world Tile dictionary, or null when the cell is outside the world.'),
        'build': f('Variant', 'if(tile.build != null){', 'The placed Building sprite, or null when the tile was skipped.'),
        'placed': f('bool', SET_BLOCK, 'Whether the stile was placed through the canonical setBlock binding.'),
        'skipped': f('String', PLACE_GUARD, 'Why the stile was skipped, or empty when placed.'),
        'valid_place_checked': f('bool', VALID_PLACE, 'Whether a valid-place hook decided the placement.'),
        'configured': f('bool', CONFIGURE_ANY, 'Whether configureAny ran on the placed Building.'),
    }
    # N2036: the whole-schematic place loop.
    n2036_inputs = {
        'game': f('Object', 'public static void place(Schematic schem, int x, int y, Team team, boolean overwrite){', 'Actual game world the schematic is placed into.'),
        'schematic': f('Dictionary', 'public static void place(Schematic schem, int x, int y, Team team, boolean overwrite){', 'Actual schematic: width, height and stile tiles in source order.'),
        'x': f('int', PLACE_ORIGIN, 'Actual schematic center x; the origin is x minus half the width.'),
        'y': f('int', PLACE_ORIGIN, 'Actual schematic center y; the origin is y minus half the height.'),
        'team_id': f('int', SET_BLOCK, 'Actual Team id the schematic is placed for.'),
        'overwrite': f('bool', PLACE_GUARD, 'Whether placement may replace existing Buildings without a valid-place check.'),
        'valid_place_hook': f('Callable', VALID_PLACE, 'Caller-supplied Build.validPlace equivalent, shared by every stile.'),
        'tile_config_callback': f('Callable', CONFIGURE_ANY, 'Caller-supplied Call.tileConfig equivalent, applied per placed Building.'),
    }
    n2036_outputs = {
        'origin': f('Vector2i', PLACE_ORIGIN, 'Actual schematic origin cell the stiles were offset from.'),
        'placed': f('int', SET_BLOCK, 'Number of stiles placed through the canonical setBlock binding.'),
        'skipped': f('int', PLACE_GUARD, 'Number of stiles skipped by the tile or valid-place guards.'),
        'configured': f('int', CONFIGURE_ANY, 'Number of placed Buildings configureAny ran on.'),
        'results': f('Array', 'schem.tiles.each(st -> {', 'Per-stile result dictionaries in source order.'),
    }
    # N2037: PortGame entry point (4-arg place delegates overwrite=true).
    n2037_inputs = {
        'schematic': f('Dictionary', 'public static void place(Schematic schem, int x, int y, Team team){', 'Actual schematic: width, height and stile tiles in source order.'),
        'x': f('int', 'place(schem, x, y, team, true);', 'Actual schematic center x.'),
        'y': f('int', 'place(schem, x, y, team, true);', 'Actual schematic center y.'),
        'team_id': f('int', SET_BLOCK, 'Actual Team id the schematic is placed for.'),
        'overwrite': f('bool', 'place(schem, x, y, team, true);', 'Whether placement may replace existing Buildings; the 4-arg entry defaults it to true.'),
        'valid_place_hook': f('Callable', VALID_PLACE, 'Caller-supplied Build.validPlace equivalent, shared by every stile.'),
        'tile_config_callback': f('Callable', CONFIGURE_ANY, 'Caller-supplied Call.tileConfig equivalent, applied per placed Building.'),
    }
    n2037_outputs = copy.deepcopy(n2036_outputs)

    entries = [
        ('N2035', 'SourceSchematicPlacementState.source_apply_schematic_tile_state', 'source_apply_schematic_tile_state', SCHEMATICS, 'mindustry.game.Schematics', 'place', n2035_inputs, n2035_outputs, [TILE_LOOKUP, PLACE_GUARD, SET_BLOCK, 'if(tile.build != null){', CONFIGURE_ANY]),
        ('N2036', 'SourceSchematicPlacementState.source_apply_schematic_place_state', 'source_apply_schematic_place_state', SCHEMATICS, 'mindustry.game.Schematics', 'place', n2036_inputs, n2036_outputs, ['public static void place(Schematic schem, int x, int y, Team team, boolean overwrite){', PLACE_ORIGIN, 'schem.tiles.each(st -> {']),
        ('N2037', 'PortGame.source_place_schematic_state', 'source_place_schematic_state', SCHEMATICS, 'mindustry.game.Schematics', 'place', n2037_inputs, n2037_outputs, ['public static void place(Schematic schem, int x, int y, Team team){', 'place(schem, x, y, team, true);']),
    ]
    for sid, owner, prefix, source, cls, method, inputs, outputs, exprs in entries:
        names = []
        for suffix, keys in [('input', inputs)] + ([('result', outputs)] if outputs is not None else []):
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed schematic placement inputs; hooks must be actual source context.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed schematic placement; the result dictionary reports what the canonical setBlock binding did, with no fabricated runtime state.'))
        by_slice[sid] = names
        source_symbols.upsert_source_slice(GODOT, sid, dict(status='done', java_source=source, java_class=cls, java_method=method, godot_owner=owner, exact_exprs=exprs, source_symbols=names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    # N2035 threads team_id through the placement funnel. The funnel keeps
    # its defaulted sharded team for existing callers; the symbol belongs
    # to the funnel slice N2034 (owner matches) and only the schema key is
    # added here.
    funnel_symbol = 'record_placed_block_input.team_id'
    symbols[funnel_symbol] = dict(status='source-backed', godot_owner='SourcePlacedBlockPortBridge.record_placed_block', godot_symbol=funnel_symbol, java_source=BLOCK, java_method='constructFinish', java_expr='Team.sharded.id', rule='Placement funnel team threaded from the schematic caller; defaults to sharded for existing player/scenario placement.', tests=TESTS, runtime_proof=PROOF)
    ledger = json.loads((GODOT / 'src/generated/source_slice_ledger.json').read_text(encoding='utf-8'))
    n2034 = ledger['slices']['N2034']
    if funnel_symbol not in n2034['source_symbols']:
        n2034['source_symbols'].append(funnel_symbol)
    source_symbols.upsert_source_slice(GODOT, 'N2034', n2034)
    schemas = json.loads((GODOT / 'src/generated/source_state_schema.json').read_text(encoding='utf-8'))
    funnel_schema = schemas['schemas']['record_placed_block_input']
    funnel_schema['keys']['team_id'] = dict(type='int', status='source-backed', java_source=BLOCK, java_expr='Team.sharded.id', rule='Placement funnel team threaded from the schematic caller; defaults to sharded for existing player/scenario placement.', used_by=['SourcePlacedBlockPortBridge.record_placed_block'])
    source_symbols.upsert_source_state_schema(GODOT, 'record_placed_block_input', funnel_schema)

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    main()
