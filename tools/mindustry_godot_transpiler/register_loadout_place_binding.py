"""Register schematic loadout placement binding for placeLoadout (N2038-N2040)."""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TILE = 'core/src/mindustry/world/Tile.java'
BLOCK = 'core/src/mindustry/world/Block.java'
SCHEMATICS = 'core/src/mindustry/game/Schematics.java'
SCHEMATIC = 'core/src/mindustry/game/Schematic.java'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/LoadoutPlaceProof'
TESTS = ['test_loadout_place_binding_registration', 'test_all_loadout_place_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_loadout_place']
DEFERRED = [
    'Teams.registerCore has no runtime equivalent yet (no TeamData.cores registry in the runtime); the register_core_hook is caller-supplied and the result records whether it fired.',
    'schematicPriority is not exported by the content catalog; the priority_hook is caller-supplied and defaults to 0 without one. The sort is not guaranteed stable for equal priorities in GDScript sort_custom (Java Seq.sort is stable).',
    'Build.validPlace stays open; placeLoadout never checks it (Java places after the removal pass).',
    'Superclass noSleep, power onProximity hooks, turret unregister, controller pickup, world transitions and remaining Tile/Floor side effects stay open in C01.',
    'C02 inventory/offload/dump/transport and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

SET_BLOCK = 'tile.setBlock(st.block, team, st.rotation);'
TILE_LOOKUP = 'Tile tile = world.tile(st.x + ox, st.y + oy);'
TILE_NULL = 'if(tile == null) return;'
CORE_FIND = 'Stile coreTile = schem.tiles.find(s -> s.block instanceof CoreBlock);'
CORE_THROW = 'if(coreTile == null) throw new IllegalArgumentException("Loadout schematic has no core tile!");'
LOADOUT_ORIGIN = 'int ox = x - coreTile.x, oy = y - coreTile.y;'
PRIORITY_SORT = 'schem.tiles.copy().sort(s -> -s.block.schematicPriority).each(st -> {'
PRIORITY_LAMBDA = 's -> -s.block.schematicPriority'
CHECK_GUARD = 'if(check && !(st.block instanceof CoreBlock)){'
LINKED_TILES = 'tile.getLinkedTilesAs(st.block, seq);'
AIR_CHECK = 'if(t.block() != Blocks.air){'
REMOVE_TILE = 't.remove();'
CONFIGURE_ANY = 'tile.build.configureAny(config);'
CORE_BUILD = 'if(tile.build instanceof CoreBuild cb){'
REGISTER_CORE = 'state.teams.registerCore(cb);'
PLACE_LOADOUT_5 = 'public static void placeLoadout(Schematic schem, int x, int y, Team team, boolean check){'
PLACE_LOADOUT_4 = 'public static void placeLoadout(Schematic schem, int x, int y, Team team){'
PLACE_LOADOUT_DELEGATE = 'placeLoadout(schem, x, y, team, true);'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=SCHEMATICS, **extra):
        return backed(typ, source, expr, rule, **extra)

    # N2038: one loadout tile through the placement funnel.
    n2038_inputs = {
        'game': f('Object', TILE_LOOKUP, 'Actual game world containing the Tile store, placement index and content catalog.'),
        'stile': f('Dictionary', PRIORITY_SORT, 'Actual schematic tile: block, cell offsets, config and rotation.'),
        'origin_cell': f('Vector2i', LOADOUT_ORIGIN, 'Actual loadout origin cell (the placed core position minus the core stile offsets); stile offsets are added to it.'),
        'team_id': f('int', SET_BLOCK, 'Actual Team id the loadout is placed for; threaded through the placement funnel.'),
        'check': f('bool', CHECK_GUARD, 'Whether the removal pass clears blocking Buildings from the stile footprint before placement.'),
        'tile_config_callback': f('Callable', CONFIGURE_ANY, 'Caller-supplied Call.tileConfig equivalent applied to the placed Building.'),
        'register_core_hook': f('Callable', REGISTER_CORE, 'Caller-supplied Teams.registerCore equivalent, called when the placed Building is a CoreBuild.'),
    }
    n2038_outputs = {
        'cell': f('Vector2i', TILE_LOOKUP, 'Actual placement cell the stile resolved to.'),
        'tile': f('Variant', TILE_LOOKUP, 'Actual resolved world Tile dictionary, or null when the cell is outside the world.'),
        'build': f('Variant', 'if(tile.build != null){', 'The placed Building sprite, or null when the tile was skipped.'),
        'placed': f('bool', SET_BLOCK, 'Whether the stile was placed through the canonical setBlock binding.'),
        'skipped': f('String', TILE_NULL, 'Why the stile was skipped, or empty when placed.'),
        'removed': f('int', REMOVE_TILE, 'Number of blocking non-air tiles the removal pass cleared from the stile footprint.'),
        'configured': f('bool', CONFIGURE_ANY, 'Whether configureAny ran on the placed Building.'),
        'core_placed': f('bool', CORE_BUILD, 'Whether the placed Building is a CoreBuild.'),
        'core_registered': f('bool', REGISTER_CORE, 'Whether the register-core hook fired for the placed CoreBuild.'),
    }
    # N2039: the whole-loadout place loop.
    n2039_inputs = {
        'game': f('Object', PLACE_LOADOUT_5, 'Actual game world the loadout is placed into.'),
        'schematic': f('Dictionary', PLACE_LOADOUT_5, 'Actual loadout schematic: stile tiles in source order, including exactly one core stile.'),
        'x': f('int', LOADOUT_ORIGIN, 'Actual core placement x; the origin is x minus the core stile x.'),
        'y': f('int', LOADOUT_ORIGIN, 'Actual core placement y; the origin is y minus the core stile y.'),
        'team_id': f('int', SET_BLOCK, 'Actual Team id the loadout is placed for.'),
        'check': f('bool', PLACE_LOADOUT_5, 'Whether the removal pass clears blocking Buildings before each non-core stile.'),
        'priority_hook': f('Callable', PRIORITY_LAMBDA, 'Caller-supplied Block.schematicPriority equivalent; stiles are placed in descending priority order.'),
        'tile_config_callback': f('Callable', CONFIGURE_ANY, 'Caller-supplied Call.tileConfig equivalent, applied per placed Building.'),
        'register_core_hook': f('Callable', REGISTER_CORE, 'Caller-supplied Teams.registerCore equivalent, called per placed CoreBuild.'),
    }
    n2039_outputs = {
        'origin': f('Vector2i', LOADOUT_ORIGIN, 'Actual loadout origin cell the stiles were offset from.'),
        'placed': f('int', SET_BLOCK, 'Number of stiles placed through the canonical setBlock binding.'),
        'skipped': f('int', TILE_NULL, 'Number of stiles skipped by the tile guard.'),
        'removed': f('int', REMOVE_TILE, 'Number of blocking non-air tiles the removal passes cleared.'),
        'configured': f('int', CONFIGURE_ANY, 'Number of placed Buildings configureAny ran on.'),
        'cores_registered': f('int', REGISTER_CORE, 'Number of placed CoreBuilds the register-core hook fired for.'),
        'results': f('Array', PRIORITY_SORT, 'Per-stile result dictionaries in priority order.'),
    }
    # N2040: PortGame entry point (4-arg placeLoadout delegates check=true).
    n2040_inputs = {
        'schematic': f('Dictionary', PLACE_LOADOUT_4, 'Actual loadout schematic: stile tiles in source order, including exactly one core stile.'),
        'x': f('int', PLACE_LOADOUT_DELEGATE, 'Actual core placement x.'),
        'y': f('int', PLACE_LOADOUT_DELEGATE, 'Actual core placement y.'),
        'team_id': f('int', SET_BLOCK, 'Actual Team id the loadout is placed for.'),
        'check': f('bool', PLACE_LOADOUT_DELEGATE, 'Whether the removal pass clears blocking Buildings; the 4-arg entry defaults it to true.'),
        'priority_hook': f('Callable', PRIORITY_LAMBDA, 'Caller-supplied Block.schematicPriority equivalent, shared by every stile.'),
        'tile_config_callback': f('Callable', CONFIGURE_ANY, 'Caller-supplied Call.tileConfig equivalent, applied per placed Building.'),
        'register_core_hook': f('Callable', REGISTER_CORE, 'Caller-supplied Teams.registerCore equivalent, called per placed CoreBuild.'),
    }
    n2040_outputs = copy.deepcopy(n2039_outputs)

    entries = [
        ('N2038', 'SourceSchematicPlacementState.source_apply_loadout_tile_state', 'source_apply_loadout_tile_state', SCHEMATICS, 'mindustry.game.Schematics', 'placeLoadout', n2038_inputs, n2038_outputs, [TILE_LOOKUP, TILE_NULL, CHECK_GUARD, LINKED_TILES, AIR_CHECK, REMOVE_TILE, SET_BLOCK, 'if(tile.build != null){', CONFIGURE_ANY, CORE_BUILD, REGISTER_CORE]),
        ('N2039', 'SourceSchematicPlacementState.source_apply_loadout_place_state', 'source_apply_loadout_place_state', SCHEMATICS, 'mindustry.game.Schematics', 'placeLoadout', n2039_inputs, n2039_outputs, [PLACE_LOADOUT_5, CORE_FIND, CORE_THROW, LOADOUT_ORIGIN, PRIORITY_SORT]),
        ('N2040', 'PortGame.source_place_loadout_state', 'source_place_loadout_state', SCHEMATICS, 'mindustry.game.Schematics', 'placeLoadout', n2040_inputs, n2040_outputs, [PLACE_LOADOUT_4, PLACE_LOADOUT_DELEGATE]),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed loadout placement inputs; hooks must be actual source context.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed loadout placement; the result dictionary reports what the canonical setBlock binding did, with no fabricated runtime state.'))
        by_slice[sid] = names
        source_symbols.upsert_source_slice(GODOT, sid, dict(status='done', java_source=source, java_class=cls, java_method=method, godot_owner=owner, exact_exprs=exprs, source_symbols=names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
